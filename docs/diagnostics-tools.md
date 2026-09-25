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
