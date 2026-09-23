# Worklog

## Current goal

Make Dotmac a portable, layered way to reproduce the current development setup while keeping the all-Mac essential level quick and safe.

## Known state

- The essential Brewfile contains Git, GitHub CLI, GNU Stow, ripgrep, and uv. Optional Brewfiles cover daily development, desktop, and data work.
- Dotmac now defines six managed home files, including portable Git defaults. On **this** Mac they are not linked: a 2026-09-23 Stow preview found conflicts with the current Zsh files and old-dotfiles Vim link. `.editorconfig` and `.inputrc` are absent. The earlier linked-files claim was stale.
- The repository is hosted publicly at https://github.com/d3ming/dotmac. GitHub secret scanning and push protection were enabled at initial publish, when alert count was zero; that alert count has not been rechecked in this update. GitHub Actions runs Gitleaks for pushes, pull requests, and manual scans; `.agent-local/` remains excluded from Git.
- The README gives one clone command, one local Codex setup path, and a reusable prompt for the essential level. `docs/setup-levels.md` explains optional profiles and safe backup scope.
- `AGENTS.md` now tells agents to commit and push completed, publishable changes by default, then check CI and security scans.
- The current Mac's Git config still links to the old dotfiles checkout; its aliases and ignore rules need a separate review before migration. Zed, shell, and macOS preferences are prioritized backup candidates, not automatically copied.

## Completed on this Mac — 2026-09-23

- Prior setup recorded installing GNU Stow through the original three-entry Brewfile. The current Mac has Git and GitHub CLI too. Future bundle applies use `--no-upgrade` so package updates remain separate.
- A prior session recorded applying the original home package, but the current 2026-09-23 preview proves those links are not present now. Treat the current home files as the source for a reviewed migration.
- Restored the useful project and directory shortcuts in the managed Zsh config, and documented creating `~/projects` before using the `p` shortcut on a new Mac.
- Created the initial Git commit, published Dotmac to GitHub, and added automated Gitleaks scanning before making the repository public.
- Replaced the long README setup walkthrough with a short new-Mac quick start that delegates the standard setup to Codex.
- Added a default remote-sync rule for agents, with safeguards for local-only requests, secrets, sensitive data, and unclear branch state.
- Added essential and optional setup levels, portable Git defaults, and a backup-priority guide. All Brewfiles passed Ruby syntax checks; Zsh/Vim/Git config checks passed; a clean-target Stow preview showed six links; Gitleaks found no secrets in the working tree. A live-home Stow preview still stops on four conflicts.

## Next action

Review the current shell and Git aliases against the new portable defaults before changing live home files. Run Homebrew Bundle checks on an unrestricted Mac; this Codex sandbox denied Homebrew cache/Cellar writes during a check, although the installed essential packages were present. Apply optional profiles only on Macs with the corresponding work.
