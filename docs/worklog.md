# Worklog

## Current goal

Keep Dotmac as the source of truth for personal Mac setup and make the setup path reusable from a new Mac.

## Known state

- The Brewfile baseline contains Git, GitHub CLI, and GNU Stow; `brew bundle check --no-upgrade --file Brewfile` succeeded after setup.
- Dotmac's five managed home files are linked through GNU Stow. A repeat preview showed no planned changes, and Zsh and Vim startup were checked.
- The repository is hosted publicly at https://github.com/d3ming/dotmac. GitHub secret scanning and push protection are enabled, with zero initial alerts. GitHub Actions runs Gitleaks for pushes, pull requests, and manual scans; `.agent-local/` remains excluded from Git.
- The optional setup backlog includes password management, display and keyboard preferences, window management, browser, and developer tools. None is part of the baseline.

## Completed on this Mac — 2026-09-23

- Installed GNU Stow through the three-entry Brewfile; Git and GitHub CLI were already present. Future bundle applies use `--no-upgrade` so package updates remain separate.
- Previewed the home package, preserved existing conflicting files outside the repository, applied the package, and verified all five links and shell startup.
- Restored the useful project and directory shortcuts in the managed Zsh config, and documented creating `~/projects` before using the `p` shortcut on a new Mac.
- Created the initial Git commit, published Dotmac to GitHub, and added automated Gitleaks scanning before making the repository public.

## Next action

Continue one requested setup item at a time. For a new Mac, clone the public repository and follow the README. Before applying optional tools or settings, inspect the current Mac and check current vendor guidance.
