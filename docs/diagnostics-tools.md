# macOS diagnostics toolkit

Dotmac uses a small, read-only-first toolkit for answering two different
questions quickly:

1. **Is the Mac under resource pressure right now?**
2. **Which files or directories are consuming disk space?**

Do not confuse memory pressure or disk I/O with directory usage. A live
monitor can show a busy process, while a disk analyzer finds the files that
consume capacity.

## Standard tools

The optional `diagnostics` profile installs the command-line tools used for
routine triage:

| Tool | Standard role | Safe first entry points |
| --- | --- | --- |
| `mo` / Mole | One-command Mac snapshot and disk overview; JSON for agents | `mo status --json`, `mo analyze --json PATH` |
| `btop` | Interactive process, CPU, memory, network, and disk-I/O view | `btop` |
| `dua` | Fast directory usage scan and interactive browser | `dua aggregate --depth 2 PATH` |
| `jq` | Filter structured Mole output | `mo status --json \| jq ...` |

The profile is optional because Mole also contains cleanup, uninstall, purge,
and optimization commands. Those commands are never part of diagnosis and
require a separate user request. `dua aggregate` is read-only; its interactive
mode can delete files and must not be used as an automatic cleanup step.

macOS already provides the authoritative low-level commands, so they are part
of the standard procedure even though they need no package installation:

- **Memory:** `memory_pressure`, `vm_stat`, `top`, and `vmmap PID`
- **Filesystem capacity:** `df` and `diskutil`
- **Open/deleted files:** `lsof +L1`
- **APFS snapshots:** `diskutil apfs listSnapshots /`

## Standard read-only workflow

### 1. Memory pressure and processes

Start with a structured Mole snapshot, then cross-check it with Apple’s
memory-pressure and virtual-memory counters:

```sh
mo status --json
memory_pressure
vm_stat -c 5 1
top -l 1 -o mem -n 20
```

Use **memory pressure**, compression, and paging trends—not free RAM alone—to
decide whether memory is actually a problem. If one process is suspicious,
inspect it separately with `vmmap PID` rather than treating its virtual size as
physical memory consumption.

### 2. Filesystem capacity and directory usage

First establish the volume-level numbers:

```sh
df -h /
diskutil apfs list
```

Then scan a deliberately chosen directory, normally the home directory or
one of its large children:

```sh
mo analyze --json "$HOME"
dua aggregate --depth 2 "$HOME"
```

Narrow the scan before widening it. For example, inspect `"$HOME/Library"`, a
project root, or `"$HOME/Downloads"` instead of repeatedly scanning `/`.

### 3. Reconcile surprising differences

A directory scan and `df` are expected to disagree on APFS when purgeable data,
local snapshots, sparse files, or clones are involved. If the numbers do not
make sense, inspect snapshots and deleted-but-open files:

```sh
diskutil apfs listSnapshots /
lsof +L1
```

`lsof +L1` may need elevated access for a complete result. Do not delete a
snapshot or an open file as part of the first diagnostic pass.

## Snapshots: know where space went

A one-off scan cannot say what grew. Keep dated snapshots and diff them:

```sh
scripts/dotmac disk snapshot          # $HOME and the user temp dir, depth 3, via dua
scripts/dotmac disk diff              # two newest snapshots: free-space change + top 25 movers
scripts/dotmac disk diff OLD.tsv NEW.tsv
```

Snapshots are machine-specific, so they go to the ignored `.agent-local/disk/`
(override with `DOTMAC_DISK_DIR`). They are read-only for the scanned paths.
Scheduling belongs to the repo that owns this Mac's LaunchAgents, not to this
public repo.

Two lessons from the 2026-10-03 incident:

- **`du` overstates APFS clones.** `uv` and `pnpm` clone files copy-on-write, so
  each worktree's `.venv` and `node_modules` looked like 2.2 GB, but removing
  one freed 115 MB. Before blaming duplicated directories, measure the change
  in `df` when one is removed, or use a tool that shows physical size.
- **Check the user temp dir** (`getconf DARWIN_USER_TEMP_DIR`). It is not under
  `$HOME`, and it held 16.6 GB of leaked temporary git stores.

One lesson from 2026-10-04: a snapshot that ran fine the day before hung for
5.5+ hours at 0% CPU. The cause was **iCloud's "Desktop & Documents" sync**:
`stat()` on an evicted placeholder under `~/Documents` does a network round
trip, so any full-tree scanner blocks there, however large or small the real
directory is. `~/projects` and `~/.local` (where a leaking project's data
lived) are plain-but-large and finished in well under a minute on their own —
file count was not the problem.

The fix uses `dua`'s own flags rather than a custom scanner:
`disk_snapshot()` passes `--ignore-dirs` for `~/Documents` and
`~/Library/Mobile Documents` (override with `DOTMAC_DISK_IGNORE_DIRS`, a
space-separated list), and wraps the whole call in the standard `timeout`
command (default 600s, override with `DOTMAC_DISK_SNAPSHOT_TIMEOUT`) as a
safety net for any future slow path not on that list. A snapshot that timed
out is still saved, marked `# TIMEOUT after <n>s; snapshot is partial`.

## Visual tools and alternatives

These are useful on demand, but are not part of the default CLI profile:

- **GrandPerspective:** established macOS treemap with filtering, saved scans,
  and Full Disk Access support.
- **`tobi/disktree`:** newer native treemap with physical-size display,
  review-before-delete, and macOS Trash support. It is promising, but local
  snapshots and APFS clone accounting still require reconciliation with
  `diskutil`.
- **`ncdu`:** mature, portable interactive disk browser when a simple TUI is
  preferable.
- **`dust`:** quick human-readable tree output; useful when `dua` is not
  available.
- **`disky`:** interesting agent-native JSON and snapshot/diff project, but it
  is not currently in the standard Homebrew profile and remains experimental.
- **`macmon`:** optional Apple-Silicon power, temperature, GPU, and ANE monitor;
  it is not a directory-space analyzer.

## Safety boundary

The first pass must not run cleanup or deletion commands. In particular, do
not run `mo clean`, `mo purge`, `mo uninstall`, `mo optimize`, `mo remove`,
`dua i`, or a disk analyzer’s delete action unless the user has explicitly
requested that operation and the targets have been reviewed. Do not run Mole
under `sudo`; let it request narrowly scoped access if an authorized action
needs it.

Grant Full Disk Access only when a complete scan is wanted and the user has
approved that system privacy change. A partial scan with clearly reported
permission gaps is safer than silently expanding privileges.

See Apple’s [Activity Monitor memory guidance](https://support.apple.com/guide/activity-monitor/view-memory-usage-actmntr1004/10.14/mac/15.0),
[virtual-memory tools](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/ManagingMemory/Articles/VMPages.html),
and [Time Machine local-snapshot guidance](https://support.apple.com/en-ie/102154)
for platform semantics.
