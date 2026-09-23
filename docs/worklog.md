# Worklog

## Current goal

Keep Dotmac as the source of truth for personal Mac setup, make new-Mac onboarding quick and agent-led, and keep its configured remote current.

## Known state

- The Brewfile baseline contains Git, GitHub CLI, and GNU Stow; `brew bundle check --no-upgrade --file Brewfile` succeeded after setup.
- Dotmac's five managed home files are linked through GNU Stow. A repeat preview showed no planned changes, and Zsh and Vim startup were checked.
- The repository is hosted publicly at https://github.com/d3ming/dotmac. GitHub secret scanning and push protection are enabled, with zero initial alerts. GitHub Actions runs Gitleaks for pushes, pull requests, and manual scans; `.agent-local/` remains excluded from Git.
- The README now gives one clone command, one local Codex setup path, and a reusable prompt that authorizes the standard tools and dotfiles.
- `AGENTS.md` now tells agents to commit and push completed, publishable changes by default, then check CI and security scans.
- The optional setup backlog includes password management, display and keyboard preferences, window management, browser, and developer tools. None is part of the baseline.

## Completed on this Mac — 2026-09-23

- Installed GNU Stow through the three-entry Brewfile; Git and GitHub CLI were already present. Future bundle applies use `--no-upgrade` so package updates remain separate.
- Previewed the home package, preserved existing conflicting files outside the repository, applied the package, and verified all five links and shell startup.
- Restored the useful project and directory shortcuts in the managed Zsh config, and documented creating `~/projects` before using the `p` shortcut on a new Mac.
- Created the initial Git commit, published Dotmac to GitHub, and added automated Gitleaks scanning before making the repository public.
- Replaced the long README setup walkthrough with a short new-Mac quick start that delegates the standard setup to Codex.
- Added a default remote-sync rule for agents, with safeguards for local-only requests, secrets, sensitive data, and unclear branch state.

## Next action

Use the README quick start on a new Mac. Keep optional apps and system preferences separate so they can be requested after the core setup; push completed repository updates by default.
