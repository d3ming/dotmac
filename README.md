# Dotmac

Dotmac is the source of truth for setting up and caring for my personal Macs. It combines a small set of dotfiles, a repeatable setup path, instructions for a local agent, and an ongoing record of decisions. The agent inspects each Mac and works through setup with me; this repo does not apply a large collection of defaults on its own.

## 1. Get a local agent running

On a new Mac, install the [ChatGPT desktop app](https://learn.chatgpt.com/docs/quickstart) from OpenAI, sign in, and open this Dotmac folder as a local project. The [Codex CLI](https://learn.chatgpt.com/docs/codex/cli) is another option; if Homebrew is already available, install it with `brew install --cask codex`, then run `codex` in this folder and sign in. Review current vendor instructions before installing because these steps can change.

Use `~/projects/dotmac` as this project's location. On a new Mac, create the parent directory with `mkdir -p "$HOME/projects"`, then clone the public repository:

```sh
git clone https://github.com/d3ming/dotmac.git "$HOME/projects/dotmac"
```

Open `README.md` and `AGENTS.md` with the agent. A useful first request is:

> Read AGENTS.md, README.md, docs/worklog.md, and docs/decisions.md. Inspect this Mac, compare it with Dotmac's setup state, and take the next safe, reversible step. Keep the worklog current.

This first step is intentionally human assisted: the agent needs the signed-in local app and this repository opened before it can help with the rest.

## 2. Install the core tools

If Homebrew is missing, have the agent review the [official Homebrew installation instructions](https://docs.brew.sh/Installation) and guide the install. `Brewfile` contains only Git, GitHub CLI, and GNU Stow. Once Homebrew is available, review the file and run:

```sh
brew bundle check --no-upgrade --file Brewfile
brew bundle --no-upgrade --file Brewfile
```

`--no-upgrade` keeps this first setup focused on missing entries; review updates separately. The public repository can be cloned without GitHub authentication. Set up GitHub authentication when you are ready to push changes.

## 3. Create required directories and apply the dotfiles

The `p` shortcut goes to `~/projects`. Ensure that directory exists during setup, before using the shortcut:

```sh
mkdir -p "$HOME/projects"
```

This command is safe to rerun and leaves an existing directory and its contents alone. Dotmac does not need a separate `~/Projects` directory. If `~/projects` already exists as a file or link, inspect it before changing it.

The `stow/home` package manages `.zprofile`, `.zshrc`, `.editorconfig`, `.inputrc`, and `.vimrc`. Preview its links from the project root:

```sh
stow --simulate --verbose --dir "$PWD/stow" --target "$HOME" home
```

[GNU Stow](https://www.gnu.org/software/stow/manual/stow.html) stops before applying anything if it finds an existing file it does not own. Have the agent inspect each conflict and preserve it in a private backup directory outside this repo. Preview again, then apply:

```sh
stow --verbose --dir "$PWD/stow" --target "$HOME" home
```

Rerunning the same Stow command is safe: links already pointing to Dotmac remain in place. Do not use `stow --adopt`; that option copies home files into the source package and can silently change this repo.

The Zsh files use built-in history, completion, and Git branch display. `.zprofile` initializes Homebrew when present. Machine-specific customizations can go in an untracked `~/.zshrc.local`; never put secrets in Dotmac.

## 4. Continue setup with the agent

Ask the agent to work from [the worklog](docs/worklog.md), record lasting choices in [the decision log](docs/decisions.md), and update this README when the setup path changes. The current backlog comes from a rough [Notion new Mac checklist](https://app.notion.com/p/3e41a22572cc80adb146cb3b84d37e2f): password manager, display and keyboard preferences, window management, browser, and developer tools. Each item needs a fresh check of the Mac and current sources before action. The [Mac admin tools collection](https://github.com/smashism/awesome-macadmin-tools) is a discovery reference, not an install list.

## Verify and recover

`brew bundle check --no-upgrade --file Brewfile` reports whether core tools are present. A repeat Stow preview should show no planned changes. Inspect the five home links and open a new Zsh login shell to check startup. If you need to remove the Dotmac links, run:

```sh
stow --delete --dir "$PWD/stow" --target "$HOME" home
```

Restore any preserved pre-Dotmac files from their backup only after checking that the target path is clear. Backups remain outside this repo.

GitHub Actions runs Gitleaks on every push, pull request, and manual dispatch. It scans the full Git history and fails if it finds a secret. GitHub's native secret scanning and push protection are enabled too: public repositories are scanned automatically, and push protection blocks supported secrets from being pushed. See [GitHub's secret scanning documentation](https://docs.github.com/en/code-security/concepts/secret-security/secret-scanning) and [push protection documentation](https://docs.github.com/en/code-security/concepts/secret-security/push-protection). Do not commit a secret with the intent to delete it later, because it remains in Git history.

## Repository map

- `AGENTS.md`: working rules for any local agent.
- `Brewfile`: the small package baseline required by this setup.
- `stow/home/`: reviewed home-directory dotfiles managed by GNU Stow.
- `docs/worklog.md`: current goal and setup state.
- `docs/decisions.md`: durable choices and their reasons.
- `.agent-local/handoff.md`: ignored, machine-local notes for the next agent session. The agent creates and updates it after meaningful work; it is never the only record of a lasting decision.

There is no custom bootstrap script. `mkdir -p`, Homebrew, and Stow provide the needed repeatable operations.
