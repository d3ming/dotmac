# Worklog

## Current goal

Keep Dotmac's portable setup small and safe. Current focus: establish an optional local-LLM evaluation harness, then choose one real workflow pilot before selecting a permanent model or changing agent defaults.

## Known state

- `evals/local-llm/` provides an opt-in Promptfoo harness: six deterministic workflow tasks, a separate native tool-call probe with no execution, and thirteen offline assertion checks. It fixes local Ollama calls to 8K context, serial execution, thinking off, and per-request unloading; telemetry/sharing are disabled and results/logs stay in ignored `.agent-local/llm/`. No model grader or agent-default change is involved.
- `scripts/dotmac` lists, plans, and applies the `essential`, `development`, `diagnostics`, `gui-apps`, and `data` profiles; it previews outdated entries, explicitly upgrades one selected profile, and streams a local Homebrew inventory on demand. Package apply post-validates the selected profile. It also previews/applies Stow links and delegates explicit macOS preference actions. JSON output is available with `--json`.
- OS-level scheduled automation is outside Dotmac's package profiles. Inspect live cron/launchd/login-item state, find the owning repo, and keep detailed per-Mac inventories out of tracked public docs.
- The essential Brewfile contains Git, GitHub CLI, GNU Stow, ripgrep, uv, Ghostty, Rectangle, and 1Password. Optional Brewfiles cover development tools (including 1Password CLI), read-only-first diagnostics (Mole, btop, dua, and jq), GUI apps (Zed and Obsidian), and data work.
- Dotmac defines eight managed home files, including portable Git defaults, a global Git ignore, and Ghostty appearance. On **this** Mac all are linked as of 2026-10-02; machine-specific Git and Zsh settings live in untracked `~/.gitconfig` and `~/.zshrc.local` (Git moved to the XDG layout on 2026-10-03). Ghostty's separate macOS config may still override the managed XDG file until migrated.
- The repository is hosted publicly at https://github.com/d3ming/dotmac. GitHub secret scanning and push protection were enabled at initial publish, when alert count was zero; that alert count has not been rechecked in this update. GitHub Actions runs Gitleaks for pushes, pull requests, and manual scans; `.agent-local/` remains excluded from Git.
- The optional `diagnostics` profile and `docs/diagnostics-tools.md` standardize read-only-first memory/disk triage around Mole, btop, dua, jq, and native macOS commands. No profile apply or cleanup was run.
- Machine-local agent context uses `.agent-local/INDEX.md` plus dated, project-coded workstream handoffs; the naming and update rules are in `AGENTS.md` and `docs/decisions.md`.
- The README gives one clone command, one local Codex setup path, and a reusable prompt that uses the Dotmac CLI for the essential level. `docs/setup-levels.md` explains profiles and safe backup scope. The project-owned macOS administration skill now lives at `.agents/skills/macos-sysadmin/SKILL.md`; `AGENTS.md` points there instead of a personal skill path, and `tests/test-dotmac.sh` protects discovery (passed, as did Bash syntax, Brewfile Ruby syntax, and `git diff --check`).
- `AGENTS.md` now tells agents to commit and push completed, publishable changes by default, then check CI and security scans.
- The old Holman `~/.dotfiles` checkout is no longer sourced by this Mac's shell or Git config; it remains on disk as a reference. Promoting pieces of `~/.zshrc.local` (fzf, `codex-as`, venv hook) is deferred. Zed and macOS preferences remain prioritized backup candidates, not automatically copied.
- Four current Finder/Dock choices now have an opt-in `scripts/macos-preferences` check/apply/restore path. It is not part of essential setup and has not been applied to this Mac.

## Completed on this Mac — 2026-10-03

- Disk-space incident: free space fell from about 163 GiB (2026-09-25) to 13 GiB. Removed 50 leaked temporary git stores (16.6 GiB) from the user temp dir; each was a full copy of `~/.hermes`, and the creator is not yet identified. Removing one Claude subagent worktree freed only 115 MB, so worktrees share dependencies through APFS clones as intended. About 70 GiB of growth is accounted for (Ollama models, the Claude desktop VM, agent homes, caches); the rest needs a snapshot diff to find.
- Added `scripts/dotmac disk snapshot|diff` (dua-based, output in `.agent-local/disk/`) with tests. Installed `dua-cli`. dm.core schedules a weekly snapshot and a per-minute guard that traps and cleans leaked temporary git stores; see its `agents/launchd/`.

## Completed on this Mac — 2026-10-02

- Migrated home config from the old Holman dotfiles to Dotmac with user approval. Backed up every replaced file (and link target) outside the repo, moved the originals aside, created real `~/.gitconfig.local` and `~/.zshrc.local`, then ran `home check` and `home apply`; all eight links were created with no conflicts. Shell parity was checked first with a scratch `ZDOTDIR`. Verified HTTPS `git push --dry-run` through the gh credential helper, global ignore matching, `git log` through the pager, vim loading `~/.vimrc`, and an interactive login zsh in a TTY with no startup errors.

## Completed on this Mac — 2026-09-29

- Installed Promptfoo through Homebrew with user authorization (required dependencies were updated; no broad upgrade or cleanup). Validated the three harness configs and passed all thirteen prerecorded assertion checks. Ran two uncached repetitions per configured candidate for workflow and native-tool tests; API calls completed without errors, but models failed some strict correctness/formatting checks. Detailed measurements remain local. Ollama had no model resident afterward. These are smoke tests, not a coding/agent ranking.
- Replaced the monolithic local handoff with a short index and separate dated handoffs for Ollama model evaluation and the paused scheduled-automation follow-up. Preserved the old mixed note as a historical archive; documented the stable ID and naming convention in `AGENTS.md` and `docs/decisions.md`.

## Completed on this Mac — 2026-09-25

- Standardized the memory and disk diagnostic toolkit in a new optional `diagnostics` Brewfile/profile, the repo-owned macOS skill, `AGENTS.md`, README, setup guide, and `docs/diagnostics-tools.md`. Added tests for profile discovery and planning. The workflow starts with read-only Mole/native snapshots, uses btop/dua for focused follow-up, and reconciles APFS snapshots or deleted-open files before any cleanup. No tools were installed or upgraded.

## Completed on this Mac — 2026-09-24

- Added `scripts/dotmac` with explicit profile `plan`/`apply`, `home check`/`apply`, `preferences`, `profiles`, `--help`, `--version`, and optional JSON output. Package applies check first and install missing entries with Homebrew Bundle `--no-upgrade`; home applies rerun the Stow preview and stop on conflicts.
- Renamed the optional Brewfiles to `Brewfile.development` and `Brewfile.gui-apps`. Rectangle and the 1Password app are essential; 1Password CLI is optional in development. The source Mac already has Rectangle installed unmanaged, and 1Password plus `1password-cli` are Homebrew-managed. The CLI skips known unmanaged app bundles or commands without taking ownership.
- Added the 1Password app to essential and `1password-cli` to optional development. Both casks are already Homebrew-managed on this Mac, so no install or upgrade was needed; no sign-in or Bitwarden vault migration was attempted.
- Hardened `apply` with a post-install Homebrew Bundle check. Added profile-scoped `outdated` and explicit `upgrade` commands, plus `inventory` output via `brew bundle dump --file=-`; the inventory is not saved. Mocked CLI tests cover post-check success/failure, update scope, repeat no-op, and JSON inventory. No actual inventory dump or package upgrade was run.
- Updated the README, setup guide, and agent workflow to use the CLI. Mocked CLI tests, Bash syntax checks, and Ruby Brewfile syntax checks passed. The live read-only preferences check matched; `home check` correctly reports the known Zsh/Git/Vim conflicts. No app, package, preference, account, or home link was changed.

## Completed on this Mac — 2026-09-23

- Prior setup recorded installing GNU Stow through the original three-entry Brewfile. The current Mac has Git and GitHub CLI too. Future bundle applies use `--no-upgrade` so package updates remain separate.
- A prior session recorded applying the original home package, but the current 2026-09-23 preview proves those links are not present now. Treat the current home files as the source for a reviewed migration.
- Restored the useful project and directory shortcuts in the managed Zsh config, and documented creating `~/projects` before using the `p` shortcut on a new Mac.
- Created the initial Git commit, published Dotmac to GitHub, and added automated Gitleaks scanning before making the repository public.
- Replaced the long README setup walkthrough with a short new-Mac quick start that delegates the standard setup to Codex.
- Added a default remote-sync rule for agents, with safeguards for local-only requests, secrets, sensitive data, and unclear branch state.
- Added essential and optional setup levels, portable Git defaults, and a backup-priority guide. All Brewfiles passed Ruby syntax checks; Zsh/Vim/Git config checks passed; the original clean-target Stow preview showed six files before Ghostty was added; Gitleaks found no secrets in that working tree. A live-home Stow preview still stops on four conflicts.
- Pushed the two setup commits through `f838bb5`; the GitHub Secret scan completed successfully and native secret scanning reported zero alerts. Compared this Mac's settings with the old dotfiles script and public GitHub setup repos, then added a four-key optional macOS profile. The read-only check matched this Mac; isolated apply, rerun, and restore checks passed with a fake `defaults` command. Added a portable Ghostty appearance config: its Vesper theme is present in the installed app, and Stow previews cleanly on an empty target. Ghostty's CLI config check exited 1 without output in this sandbox, so a live Ghostty load remains unverified. No live settings were changed.

## Next action

Pick one real, bounded workflow (for example sanitized handoff extraction or note routing), add representative cases and a validation/fallback path, and evaluate before adoption. Keep the existing agent defaults unchanged. A disposable patch-and-test task and MLX grammar-constrained output/API comparisons remain separate follow-ups; the basic suite does not validate them.

Use `scripts/dotmac plan --profile essential` on an unrestricted Mac before setup; apply only as part of an explicitly authorized setup. Use `scripts/dotmac plan --profile diagnostics` when memory or disk triage is needed; apply it only when the user authorizes optional tool installation. Rectangle is already present but unmanaged on this Mac, so the CLI skips it without adopting it. Home links are applied on this Mac; review `~/.zshrc.local` pieces before promoting any to Dotmac.
