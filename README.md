# Dotmac

Agent-led setup for my personal Macs. Dotmac has a fast essential setup and independent optional profiles for development, GUI apps, and research. Use [`scripts/dotmac`](scripts/dotmac) to inspect profiles, plan changes, and apply them safely. See [setup levels and backup priorities](docs/setup-levels.md).

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

   > Set up the essential level on this Mac using `AGENTS.md`, `README.md`, and `docs/setup-levels.md`. Inspect current state. If Homebrew is missing, review its current [official installation instructions](https://docs.brew.sh/Installation) and install it. Run `scripts/dotmac plan --profile essential`, then `scripts/dotmac apply --profile essential`. Run `scripts/dotmac home check`; preserve any conflicts outside this repo, then run `scripts/dotmac home apply`. Verify the managed files plus Zsh, Vim, Git, and Ghostty behavior. Update `docs/worklog.md` and `.agent-local/handoff.md`. You are authorized to complete these standard tool and dotfile steps without routine confirmation. Stop before optional profiles, signing into 1Password, migrating Bitwarden vault data, or macOS/security changes; also stop if a conflict cannot be safely preserved.

## Choose a level

The essential `Brewfile` installs Git, GitHub CLI, GNU Stow, ripgrep, uv, Ghostty (the default terminal), Rectangle for window management, and the 1Password app. Installing 1Password does not sign in or migrate Bitwarden vault data; handle account and vault migration separately. `stow/home` manages Zsh, Vim, EditorConfig, Readline, Git, and a small Ghostty config. Keep Git identity and signing preferences in the untracked `~/.gitconfig.local`; use a secure credential manager for credentials. Existing conflicting home files must be reviewed and preserved before Stow runs.

For a Mac that needs more, list profiles with `scripts/dotmac profiles` and select only the appropriate one:

| Profile | Plan / apply | Adds |
| --- | --- | --- |
| Development | `scripts/dotmac plan --profile development` / `scripts/dotmac apply --profile development` | CLI helpers, pnpm, Poetry, and 1Password CLI (`op`) |
| GUI apps | `scripts/dotmac plan --profile gui-apps` / `scripts/dotmac apply --profile gui-apps` | Zed and Obsidian |
| Data and research | `scripts/dotmac plan --profile data` / `scripts/dotmac apply --profile data` | Dolt, DuckDB, ImageMagick, and Poppler |

`plan --profile NAME` checks for missing entries, and `outdated --profile NAME` previews outdated installed entries in that Brewfile. `apply --profile NAME` installs missing entries with Homebrew Bundle `--no-upgrade`, then verifies them with `brew bundle check --no-upgrade`; it does not deliberately upgrade existing packages. Homebrew may still update a dependency when an installation requires it.

`upgrade --profile NAME` explicitly installs missing entries and upgrades outdated dependencies in only that profile; it never removes packages outside the Brewfile. Review `plan` and `outdated` first. `inventory` streams Homebrew Bundle's machine-specific installed manifest to stdout without saving it; it does not capture every Mac app (including unmanaged apps such as Rectangle), and should not be committed to this public repo. Each optional profile assumes the essential level is already installed. Use `scripts/dotmac --json profiles` for machine-readable results, and see [setup levels](docs/setup-levels.md) for selection criteria and backup guidance.

Four current Finder and Dock preferences have a separate [opt-in, previewable profile](docs/macos-preferences.md). Run `scripts/dotmac preferences check` to compare a Mac before choosing `scripts/dotmac preferences apply`. These settings are not part of the essential setup.

GitHub Actions scans pushes and pull requests with Gitleaks. GitHub secret scanning and push protection are enabled; see [secret scanning](https://docs.github.com/en/code-security/concepts/secret-security/secret-scanning) and [push protection](https://docs.github.com/en/code-security/concepts/secret-security/push-protection).
