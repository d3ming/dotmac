# Worklog

## Current goal

Make Dotmac a portable, layered way to reproduce the current development setup through a small, safe CLI while keeping the essential level quick.

## Known state

- `scripts/dotmac` lists, plans, and applies the `essential`, `development`, `gui-apps`, and `data` profiles; it also previews/applies Stow links and delegates explicit macOS preference actions. JSON output is available with `--json`.
- The essential Brewfile contains Git, GitHub CLI, GNU Stow, ripgrep, uv, Ghostty, Rectangle, and 1Password. Optional Brewfiles cover development tools (including 1Password CLI), GUI apps (Zed and Obsidian), and data work.
- Dotmac now defines seven managed home files, including portable Git and Ghostty defaults. On **this** Mac they are not linked: a 2026-09-23 Stow preview found conflicts with the current Zsh files and old-dotfiles Git/Vim links. `.editorconfig` and `.inputrc` are absent. The earlier linked-files claim was stale. Ghostty's separate macOS config may override the managed XDG file until migrated.
- The repository is hosted publicly at https://github.com/d3ming/dotmac. GitHub secret scanning and push protection were enabled at initial publish, when alert count was zero; that alert count has not been rechecked in this update. GitHub Actions runs Gitleaks for pushes, pull requests, and manual scans; `.agent-local/` remains excluded from Git.
- The README gives one clone command, one local Codex setup path, and a reusable prompt that uses the Dotmac CLI for the essential level. `docs/setup-levels.md` explains profiles and safe backup scope.
- `AGENTS.md` now tells agents to commit and push completed, publishable changes by default, then check CI and security scans.
- The current Mac's Git config still links to the old dotfiles checkout; its aliases and ignore rules need a separate review before migration. Zed, shell, and macOS preferences are prioritized backup candidates, not automatically copied.
- Four current Finder/Dock choices now have an opt-in `scripts/macos-preferences` check/apply/restore path. It is not part of essential setup and has not been applied to this Mac.

## Completed on this Mac — 2026-09-24

- Added `scripts/dotmac` with explicit profile `plan`/`apply`, `home check`/`apply`, `preferences`, `profiles`, `--help`, `--version`, and optional JSON output. Package applies check first and install missing entries with Homebrew Bundle `--no-upgrade`; home applies rerun the Stow preview and stop on conflicts.
- Renamed the optional Brewfiles to `Brewfile.development` and `Brewfile.gui-apps`. Rectangle and the 1Password app are essential; 1Password CLI is optional in development. The source Mac already has Rectangle installed unmanaged, and 1Password plus `1password-cli` are Homebrew-managed. The CLI skips known unmanaged app bundles or commands without taking ownership.
- Added the 1Password app to essential and `1password-cli` to optional development. Both casks are already Homebrew-managed on this Mac, so no install or upgrade was needed; no sign-in or Bitwarden vault migration was attempted.
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

Use `scripts/dotmac plan --profile essential` on an unrestricted Mac before setup; apply only as part of an explicitly authorized setup. Rectangle is already present but unmanaged on this Mac, so the CLI skips it without adopting it. Preserve the known Stow conflicts before any `home apply`. Review the current shell and Git aliases separately before migrating them.
