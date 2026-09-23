# Dotmac

Agent-led setup for my personal Macs. Dotmac manages a small Homebrew baseline and five home configuration files; Codex handles the setup and checks the current Mac before applying them.

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

   > Set up this Mac using `AGENTS.md` and `README.md`. Inspect the current state. If Homebrew is missing, review its current [official installation instructions](https://docs.brew.sh/Installation) and install it. Run `brew bundle check --no-upgrade --file Brewfile`, then `brew bundle --no-upgrade --file Brewfile` to install missing tools without upgrading. Preview the Stow package, preserve conflicts outside this repo, apply it, and verify all five links, Zsh startup, and Vim. Update `docs/worklog.md` and `.agent-local/handoff.md`. You are authorized to complete these standard tool and dotfile steps without routine confirmation. Stop before optional apps or macOS/security changes, or if a conflict cannot be safely preserved.

## Scope

The core setup installs Git, GitHub CLI, and GNU Stow, then applies `stow/home`. Existing conflicting files are preserved outside the repo. Optional apps and system preferences are handled separately when requested.

GitHub Actions scans pushes and pull requests with Gitleaks. GitHub secret scanning and push protection are enabled; see [secret scanning](https://docs.github.com/en/code-security/concepts/secret-security/secret-scanning) and [push protection](https://docs.github.com/en/code-security/concepts/secret-security/push-protection).
