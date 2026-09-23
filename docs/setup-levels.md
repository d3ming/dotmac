# Setup levels and backup priorities

Dotmac records **desired, portable setup**, not a dump of everything installed on one Mac. Each Brewfile is independent: apply the essential `Brewfile` first, then only the optional profiles wanted on that Mac. `brew bundle --no-upgrade` installs missing entries without deliberately upgrading existing ones; Homebrew is rolling release software, so these files do not pin exact versions. See the [Homebrew Bundle guide](https://docs.brew.sh/Brew-Bundle-and-Brewfile).

| Level | What it restores | Why it belongs here |
| --- | --- | --- |
| **Essential — every development Mac** | `Brewfile`: Git, GitHub CLI, GNU Stow, ripgrep, uv, Ghostty; `stow/home`: Zsh, Vim, Readline, EditorConfig, and safe Git defaults | Portable tools needed to get a repo, search code, run the active Python projects, and restore the shell in the user's default terminal. No service is started and no account is signed in by this level. |
| **Optional — daily development** | `Brewfile.dev`: fd, fzf, git-delta, Gitleaks, Glow, jq, pnpm, Poetry, yq | Useful across current coding work, but not needed on a basic Mac. Poetry supports older projects; uv is the default new-Mac Python tool. |
| **Optional — desktop** | `Brewfile.desktop`: Zed, Obsidian | Editor and notes choices. They add app downloads and may require sign-in or preference review. |
| **Optional — data and research** | `Brewfile.data`: Dolt, DuckDB, ImageMagick, Poppler | Relevant to research and document workflows, not general Mac setup. No database service is started. |

To inspect one level, run `brew bundle check --no-upgrade --file Brewfile.dev` (replace the filename as needed). To apply it, run `brew bundle --no-upgrade --file Brewfile.dev`. Run these commands from the Dotmac checkout. The essential Stow package must be previewed with `stow -n -v -d stow -t "$HOME" home` before applying it. Stow stops on conflicts; preserve a conflicting home file before replacing it, and never use `stow --adopt` here.

## Why these levels

This selection was reviewed on the source Mac on 2026-09-23. Installed Homebrew leaves and casks show what is available, not what is used. Direct Zsh history from 2024-11 through 2026-09 strongly favors Git (1,063 commands), Poetry (519), and `make` (325); it also shows uv (125), while the last 90 days are sparse. Agent-run commands do not appear in that history. Current project manifests include many Python projects and several JavaScript projects. These are signals for the level choices, not a complete usage meter. The user confirmed Ghostty is now the default terminal, so it belongs in the essential level despite being a GUI app. Other essential entries are portable, broadly useful on a new development Mac, and inexpensive to install and maintain.

Several installed tools stay out of the default profiles. Docker Desktop, PostgreSQL, cloud CLIs, language version managers, AI provider CLIs, browser automation tools, speech tools, and finance-specific libraries have larger downloads, service or account setup, platform constraints, or narrow project ownership. Add one only when that Mac has the matching job; document the chosen install and restore steps then. Do not automatically copy the source Mac's full `brew bundle dump` into an installable Brewfile.

## What else is worth preserving

| Priority | Candidate | Repo treatment |
| --- | --- | --- |
| High | Git defaults, aliases, global ignore rules | The safe portable defaults are now in `stow/home/.gitconfig`. The current Mac's fuller config still comes from the old dotfiles checkout. Review aliases and ignore rules for paths, identity, and executable dependencies before moving them; keep name, email, and signing preferences in `~/.gitconfig.local`, and credentials in a secure manager. |
| High | Active Zsh behavior and tool initialization | Compare the real `~/.zshrc` and `~/.zprofile` with Dotmac's files. Port only the features still used. Keep tokens, machine paths, and private environment variables in `~/.zshrc.local` or another private store. |
| Medium | Zed keymap, theme, and selected settings; Ghostty preferences if customized | Track reviewed, portable preferences in separate Stow packages. Exclude API keys, account state, workspace history, and backup copies. |
| Medium | Small tool preferences, such as direnv and micro | Promote only settings that are still used and safe on a fresh Mac. Avoid history and cache files. |
| Per Mac | Keyboard, trackpad, Dock, Finder, display, accessibility, and login item choices | Keep a human-readable checklist after checking each setting. Displays, input devices, and permissions vary; do not run a blanket `defaults write` script. |

The source Mac currently has regular `~/.zshrc` and `~/.zprofile` files, an old-dotfiles `~/.vimrc` link, and an old-dotfiles `~/.gitconfig` link. Dotmac's Stow package is **not active** there as of this review. Its first preview reports conflicts for the Zsh files and the Git/Vim links. Do not overwrite those files just to make the repo appear installed.

Passwords, tokens, SSH/private keys, recovery codes, browser profiles, cloud credentials, app databases, and raw `~/Library` data do **not** belong in this public Git repository. Use a password manager and an encrypted computer backup. Apple's [Migration Assistant](https://support.apple.com/guide/mac-help/transfer-your-information-from-another-computer-mh27921/mac) can transfer apps, user accounts, documents, and settings when a full Mac migration is wanted; Dotmac remains the reproducible development setup.
