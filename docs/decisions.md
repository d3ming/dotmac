# Decisions

Record choices that should guide the next agent or the next Mac. Revisit them when evidence or preferences change.

## 2026-10-03 — Manage Git's XDG config; keep ~/.gitconfig local

Dotmac now links `~/.config/git/config` instead of `~/.gitconfig`, and `home apply` creates an empty, private `~/.gitconfig` when absent. Git reads the XDG file first and `~/.gitconfig` second, so local identity and credentials still override portable defaults without an include. `git config --global`, `gh auth setup-git`, and `git lfs install` write to `~/.gitconfig` whenever it exists; with the old layout they wrote through the symlink into this public repo. This supersedes the `~/.gitconfig.local` file and the write-with-`--file` workaround in the 2026-10-02 entry below.

Evidence: in a scratch home, the effective config matched the live one; a `--global` write landed in `~/.gitconfig`, and without that file it landed in the tracked XDG file, which is why apply creates it. Mocked CLI tests cover creation, `0600` mode, read-only check, and preserving an existing file.

## 2026-10-02 — Split Git and Zsh config into portable Stow files and untracked local files

Dotmac's Stow files hold portable defaults only. `~/.gitconfig` (tracked) holds reviewed aliases, including the destructive `rh`, `rop`, `db`, and `sweep`, and a delta pager that falls back to `less` when the development profile is absent. It includes `~/.gitconfig.local` last. That real, untracked file holds identity, credential helpers (gh for GitHub HTTPS, osxkeychain), `safe.directory`, Git LFS, and service-specific settings. Global ignores use Git's default `~/.config/git/ignore`, so no `core.excludesFile` is needed. Because `git config --global` and installers such as `gh auth setup-git` or `git lfs install` write through the `~/.gitconfig` symlink into this public repo, write machine settings with `git config --file ~/.gitconfig.local` and review `git status` after such tools run. Machine-specific shell setup lives in an untracked `~/.zshrc.local`, sourced last; promote a piece only after reviewing it.

Evidence: on the source Mac, zsh history showed the old `$ZSH/bin` helpers (`git done`, `git promote`, `git wtf`, `git rank-contributors`) unused, so they were dropped rather than ported. The effective Git config before and after differed only in intended ways. HTTPS push auth through gh, pager output, vim, and an interactive login zsh with no startup errors were verified after `home apply`.

## 2026-09-29 — Evaluate local models before choosing workflow roles

Use the opt-in [Promptfoo harness](../evals/local-llm/README.md), not another custom benchmark runner, for small shared Ollama tests. Keep calls loopback-only and serial, with fixed context/decoding settings, per-request unloading, deterministic grading, and ignored local results. Do not add model graders, cloud calls, tool execution, or an essential package/profile requirement. Keep agent defaults unchanged until a real workflow earns adoption.

Evidence: the first matched run exposed different content, formatting, and native-tool behavior across candidate artifacts; a larger model did not automatically satisfy the strict output contract. Promptfoo's tested Ollama provider did not forward per-test tool settings, so the native-call suite places schemas in provider config and rejects text imitations. The thirteen prerecorded checks validate grading independently of inference. Fixed-seed repetitions and cold-start timings are smoke-test evidence, not a model/runtime ranking or a warm-performance claim.

## 2026-09-29 — Use dated, project-coded local handoffs

Keep ignored `.agent-local/INDEX.md` as a short router to active workstreams. Give each ongoing investigation a stable project/workstream code (derived from its owning repo, such as `DOTMAC-LLM-001`) and store dated snapshots under `.agent-local/handoffs/<PROJECT-CODE>/<PROJECT-CODE>-<AREA>-NNN--<slug>/YYYY-MM-DD.md`. The index records status, latest snapshot, and next action; IDs are never reused, and older snapshots remain historical rather than competing with current state. Each repository owns its own local notes. Keep transcripts, secrets, credentials, and sensitive machine inventories out of handoffs; put durable reusable decisions in tracked docs.

Evidence: the prior single ignored handoff had grown into a long chronological mix of unrelated workstreams and historical host state, making it hard to route a new agent. A small index plus scoped, dated snapshots makes concurrent threads discoverable while retaining useful handoff history.

## 2026-09-25 — Standardize read-only memory and disk diagnostics

Use the optional `diagnostics` profile for Mole (`mo`), `btop`, `dua`, and `jq`. Start incidents with `mo status --json`, Apple’s `memory_pressure`/`vm_stat`/`top`, and `df`/`diskutil`; use `mo analyze --json` and `dua aggregate` for focused directory scans. Reconcile APFS snapshots and deleted-but-open files before proposing cleanup. Keep Mole cleanup, GUI visualizers, Apple-Silicon-only telemetry, and experimental `disky` on-demand rather than essential: the first pass must be portable, read-only, and easy for an agent to parse.

Evidence: the 2026-09-25 tool review found Mole strongest as an all-in-one first responder but observed that installed Mole 1.55 returned an empty memory-pressure field on this Mac while native `memory_pressure` worked. `tobi/disktree` is promising for visual exploration but does not replace APFS-level accounting. The detailed workflow is in [`docs/diagnostics-tools.md`](diagnostics-tools.md).

## 2026-09-24 — Keep the macOS sysadmin skill project-scoped

Dotmac's administration guidance must not depend on `~/.codex/skills/macos-sysadmin`, which is personal and absent on this machine. Codex's first-party [Agent Skills](https://developers.openai.com/codex/skills) and [Customization](https://developers.openai.com/codex/concepts/customization) docs define repo skills under `.agents/skills/<skill-name>/SKILL.md`; local skills in `dot-agents/master/skills/` use the same `SKILL.md` package shape. Keep the portable `macos-sysadmin` workflow in Dotmac's `.agents/skills/`, route to it from `AGENTS.md`, and guard this discovery contract in `tests/test-dotmac.sh`. Do not create or modify a personal/global skill as part of project work.

## 2026-09-24 — Separate profile setup, local inventory, and upgrades

`apply` installs missing profile entries without deliberate upgrades and verifies their presence afterward. `outdated` previews only installed entries in a selected profile. `upgrade` explicitly runs Homebrew Bundle for only that profile; because Bundle upgrade also installs missing entries, it is a user-directed action, and it never cleans up undeclared packages. `inventory` prints Homebrew Bundle's machine-specific installed snapshot to stdout without tracking it. Brewfiles remain portable desired state, not a dump of one Mac's installed packages.

## 2026-09-24 — Keep scheduled OS automation under its owner

Cron jobs, LaunchAgents/LaunchDaemons, and login/background items are per-Mac runtime behavior, separate from package profiles and preferences. Before managing one, inspect the live state and locate its source-of-truth repo; use that repo's plan/doctor/apply workflow. Keep vendor jobs inventory-only and do not copy detailed schedules, arguments, environment values, logs, or full machine inventories into public Dotmac documentation.

## 2026-09-24 — Use a preview-first CLI and make Rectangle essential

`scripts/dotmac` is the repository-local interface for listing profiles, planning/applying Homebrew profiles, checking/applying Stow links, and invoking macOS preference actions. Profile names are `essential`, `development`, `gui-apps`, and `data`; `gui-apps` replaces the ambiguous `desktop` label. Keep preferences separate from app profiles. Plans are read-only, package applies use Homebrew Bundle `--no-upgrade`, and home applies repeat the Stow conflict preview. `--json` provides machine-readable status while command diagnostics remain available to agents.

Rectangle belongs in the essential profile because the user wants it on every managed Mac. Its Accessibility permission remains user-approved and is never granted by Dotmac. When a known app bundle exists in `/Applications` or `~/Applications`, or a known CLI command is on `PATH`, without a Homebrew cask record, the CLI skips the cask without taking ownership or changing that artifact. On the source Mac, `/Applications/Rectangle.app` is present but not Homebrew-managed. Optional `gui-apps` contains Zed and Obsidian.

## 2026-09-24 — Install 1Password everywhere; keep its CLI optional

The user wants the 1Password app in the essential profile while considering a future move from Bitwarden. Install [`1password`](https://formulae.brew.sh/cask/1password) as a Homebrew cask on every managed Mac. Keep [`1password-cli`](https://formulae.brew.sh/cask/1password-cli) in the optional development profile because the `op` command is only needed for CLI workflows. On the source Mac both casks are already Homebrew-managed. Installing the app does not authorize sign-in, vault import/migration, or Bitwarden removal; those remain separate user-directed account actions. Never store vault contents or credentials in Dotmac.

## 2026-09-23 — Automate only four observed user-level macOS preferences

Finder path/status bars, Finder list view, and Dock position are set on this Mac and have narrow `defaults` keys. `scripts/macos-preferences` provides a read-only check, an opt-in apply that changes only differing keys, read-back verification, and a local selective backup/restore. It does not run during essential setup or restart Finder/Dock. Older dotfiles and public setup repos were used as references, but their broad scripts include stale or unrelated settings; the reviewed sources and exclusions are in `docs/macos-preferences.md`.

Ghostty is the default terminal, so its portable appearance settings are part of essential Stow. The current macOS-specific Ghostty config remains live on this Mac and is not changed here; it loads after Dotmac's XDG config and may override it. Display P3 and very large scrollback remain machine-local until there is a cross-Mac reason to manage them.

## 2026-09-23 — Layer the desired setup instead of copying every installed package

The essential level adds ripgrep and uv to Git, GitHub CLI, and GNU Stow because code search and Python project setup are broad, portable needs here. The user confirmed Ghostty is now the default terminal, so its cask is essential too. Independent optional Brewfiles cover daily development CLI tools, GUI apps, and data/research tools. Heavy services, provider accounts, version managers, and narrowly owned tools stay out until a Mac needs them. The inventory and rationale live in `docs/setup-levels.md`; installed state and long-range shell history are evidence, not a full usage measure.

The home package now includes a sanitized Git config with the portable defaults observed on this Mac. Name, email, and signing preferences stay in `~/.gitconfig.local`; credentials stay in a secure manager. The old Git aliases and global ignore file were reviewed and promoted on 2026-10-02 (see that decision).

## 2026-09-23 — Dotmac owns personal Mac setup

The current project is Dotmac. It owns the desired dotfiles, agent guidance, setup flow, and administration notes. The old `~/dotfiles` checkout and the Notion checklist are inputs for review, not competing sources of truth. This keeps the next agent's starting point clear.

## 2026-09-23 — Start with a thin, agent-led flow

Getting a signed-in local agent able to read Dotmac is Step 1. A human may need to install and sign in to the agent, then clone the public repository on a new Mac. The agent inspects the Mac and handles later tasks one at a time; the raw checklist does not authorize every install or system change.

## 2026-09-23 — Minimize time to local Codex setup

The README uses the ChatGPT desktop app's local Codex project flow, one clone command, and one reusable setup prompt. The prompt authorizes installing the small Brewfile baseline and applying reviewed Stow links, so Codex can complete the core setup without routine approval stops. Optional apps and macOS or security settings remain separately requested.

## 2026-09-23 — Keep the configured remote current

When a remote is configured, agents should commit and push completed, publishable work by default so the GitHub copy stays close to the local source of truth. They check CI and security scans after pushing. Local-only requests, unresolved secrets or sensitive data, and unclear branch or remote state are reasons to hold the push.

## 2026-09-23 — Use Homebrew and GNU Stow

`Brewfile` names only Git, GitHub CLI, and GNU Stow. Stow provides preview, repeatable linking, conflict detection, and removal without a custom installer. Existing home files are preserved outside the repo before first application. `stow --adopt` is excluded because it modifies the package source.

Homebrew Bundle upgrades outdated listed packages by default, so setup uses `--no-upgrade`. Package updates remain a separate reviewed action.

Evidence: the [GNU Stow manual](https://www.gnu.org/software/stow/manual/stow.html) describes its conflict preflight and repeatable link behavior; the current Mac's first preview stopped on five existing targets, and a repeat apply after migration made no changes.

## 2026-09-23 — Publish Dotmac with automated secret scanning

Dotmac is hosted as a public GitHub repository at `d3ming/dotmac` so a new Mac can clone it directly. The README gives the HTTPS clone command; authentication is needed only to push changes.

The GitHub Actions workflow runs Gitleaks on pushes, pull requests, and manual dispatches, fetching full Git history so prior commits are scanned too. It uses commit-pinned actions and disables PR comments and artifact uploads so findings are not copied into extra surfaces. GitHub's native secret scanning and push protection are enabled on the public repository; the initial alert check returned zero findings. See the [GitHub secret scanning documentation](https://docs.github.com/en/code-security/concepts/secret-security/secret-scanning) and [push protection documentation](https://docs.github.com/en/code-security/concepts/secret-security/push-protection).

## 2026-09-23 — Keep the first dotfile set small

Dotmac manages Zsh, EditorConfig, Readline, and Vim. The Zsh setup uses built-in features and no plugin framework. The old Vim theme bundle and broad macOS or Homebrew scripts are not part of the managed state. New files or scripts need a demonstrated purpose and a safe rerun path.

## 2026-09-23 — Create only directories required by the managed setup

The `p` alias targets lowercase `~/projects`, so the bootstrap flow creates it with `mkdir -p` before the alias is used. This is safe to rerun and needs no custom installer. Uppercase `~/Projects` is not required by Dotmac.

## 2026-09-23 — Put Dotmac under projects and keep local agent handoff outside Git

The normal checkout location is `~/projects/dotmac`, under the directory opened by `p`. The setup instructions create `~/projects` before cloning. Agent handoffs live in ignored `.agent-local/` so machine-local session context does not enter Git; the tracked worklog and decisions remain the durable source for future Macs, because ignored files do not travel with a clone. The dated project/workstream index convention is recorded in the 2026-09-29 decision above.
