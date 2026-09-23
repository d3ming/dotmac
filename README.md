# Dotmac

Agent-led setup for my personal Macs. Dotmac has a fast essential setup and independent optional profiles for a fuller development, desktop, or research Mac. See [setup levels and backup priorities](docs/setup-levels.md).

## New Mac quick start

1. Install and sign in to the [ChatGPT desktop app](https://learn.chatgpt.com/docs/quickstart), then choose **Codex**.
2. Open Terminal and clone Dotmac:

   ```sh
   mkdir -p "$HOME/projects"
   git clone https://github.com/d3ming/dotmac.git "$HOME/projects/dotmac"
   ```

   If `git` is unavailable, run `xcode-select --install`, finish the Apple prompt, then retry the clone. The public repo does not require GitHub sign-in to clone.

3. In Codex, open `~/projects/dotmac` as a **Local** project and start a chat. The desktop app can work with the local folder you open; see the [Codex quick start](https://learn.chatgpt.com/docs/quickstart).
4. Paste this request:

   > Set up the essential level on this Mac using `AGENTS.md`, `README.md`, and `docs/setup-levels.md`. Inspect current state. If Homebrew is missing, review its current [official installation instructions](https://docs.brew.sh/Installation) and install it. Check and apply `Brewfile` with `brew bundle --no-upgrade`. Preview `stow/home`, preserve conflicts outside this repo, apply it, and verify all six links plus Zsh, Vim, and Git startup. Update `docs/worklog.md` and `.agent-local/handoff.md`. You are authorized to complete these standard tool and dotfile steps without routine confirmation. Stop before optional profiles or macOS/security changes, or if a conflict cannot be safely preserved.

## Choose a level

The essential `Brewfile` installs Git, GitHub CLI, GNU Stow, ripgrep, and uv. `stow/home` manages six portable files: `.zprofile`, `.zshrc`, `.vimrc`, `.editorconfig`, `.inputrc`, and `.gitconfig`. Keep Git identity and signing preferences in the untracked `~/.gitconfig.local`; use a secure credential manager for credentials. Existing conflicting home files must be reviewed and preserved before Stow runs.

For a Mac that needs more, select only the appropriate optional profile:

| Profile | Command | Adds |
| --- | --- | --- |
| Daily development | `brew bundle --no-upgrade --file Brewfile.dev` | CLI helpers, pnpm, and Poetry |
| Desktop | `brew bundle --no-upgrade --file Brewfile.desktop` | Ghostty, Zed, and Obsidian |
| Data and research | `brew bundle --no-upgrade --file Brewfile.data` | Dolt, DuckDB, ImageMagick, and Poppler |

Run `brew bundle check --no-upgrade --file NAME` before applying a profile. Each optional file is independent and assumes the essential level is already installed. See [setup levels](docs/setup-levels.md) for selection criteria and what belongs in a separate encrypted backup.

GitHub Actions scans pushes and pull requests with Gitleaks. GitHub secret scanning and push protection are enabled; see [secret scanning](https://docs.github.com/en/code-security/concepts/secret-security/secret-scanning) and [push protection](https://docs.github.com/en/code-security/concepts/secret-security/push-protection).
