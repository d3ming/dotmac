# Decisions

Record choices that should guide the next agent or the next Mac. Revisit them when evidence or preferences change.

## 2026-09-23 — Layer the desired setup instead of copying every installed package

The essential level adds ripgrep and uv to Git, GitHub CLI, and GNU Stow because code search and Python project setup are broad, portable needs here. The user confirmed Ghostty is now the default terminal, so its cask is essential too. Independent optional Brewfiles cover daily development CLI tools, other desktop apps, and data/research tools. Heavy services, provider accounts, version managers, and narrowly owned tools stay out until a Mac needs them. The inventory and rationale live in `docs/setup-levels.md`; installed state and long-range shell history are evidence, not a full usage measure.

The home package now includes a sanitized Git config with the portable defaults observed on this Mac. Name, email, and signing preferences stay in `~/.gitconfig.local`; credentials stay in a secure manager. The old Git aliases and global ignore file need review before promotion. A current Stow preview contradicts the earlier claim that Dotmac's home files remain linked on this Mac, so no live home files were replaced during this change.

## 2026-09-23 — Dotmac owns personal Mac setup

The current project is Dotmac. It owns the desired dotfiles, agent guidance, setup flow, and administration notes. The old `~/dotfiles` checkout and the Notion checklist are inputs for review, not competing sources of truth. This keeps the next agent's starting point clear.

## 2026-09-23 — Start with a thin, agent-led flow

Getting a signed-in local agent able to read Dotmac is Step 1. A human may need to install and sign in to the agent, then clone the public repository on a new Mac. The agent inspects the Mac and handles later tasks one at a time; the raw checklist does not authorize every install or system change.

## 2026-09-23 — Minimize time to local Codex setup

The README uses the ChatGPT desktop app's local Codex project flow, one clone command, and one reusable setup prompt. The prompt authorizes installing the small Brewfile baseline and applying reviewed Stow links, so Codex can complete the core setup without routine approval stops. Optional apps and macOS or security settings remain separately requested.

## 2026-09-23 — Keep the configured remote current

When a remote is configured, agents should commit and push completed, publishable work by default so the GitHub copy stays close to the local source of truth. They check CI and security scans after pushing. Local-only requests, unresolved secrets or sensitive data, and unclear branch or remote state are reasons to hold the push.

## 2026-09-23 — Use Homebrew and GNU Stow

`Brewfile` names only Git, GitHub CLI, and GNU Stow. Stow provides preview, repeatable linking, conflict detection, and removal without a custom installer. Existing home files are preserved outside the repo before first application. `stow --adopt` is excluded because it modifies the package source.

Homebrew Bundle upgrades outdated listed packages by default, so setup uses `--no-upgrade`. Package updates remain a separate reviewed action.

Evidence: the [GNU Stow manual](https://www.gnu.org/software/stow/manual/stow.html) describes its conflict preflight and repeatable link behavior; the current Mac's first preview stopped on five existing targets, and a repeat apply after migration made no changes.

## 2026-09-23 — Publish Dotmac with automated secret scanning

Dotmac is hosted as a public GitHub repository at `d3ming/dotmac` so a new Mac can clone it directly. The README gives the HTTPS clone command; authentication is needed only to push changes.

The GitHub Actions workflow runs Gitleaks on pushes, pull requests, and manual dispatches, fetching full Git history so prior commits are scanned too. It uses commit-pinned actions and disables PR comments and artifact uploads so findings are not copied into extra surfaces. GitHub's native secret scanning and push protection are enabled on the public repository; the initial alert check returned zero findings. See the [GitHub secret scanning documentation](https://docs.github.com/en/code-security/concepts/secret-security/secret-scanning) and [push protection documentation](https://docs.github.com/en/code-security/concepts/secret-security/push-protection).

## 2026-09-23 — Keep the first dotfile set small

Dotmac manages Zsh, EditorConfig, Readline, and Vim. The Zsh setup uses built-in features and no plugin framework. The old Vim theme bundle and broad macOS or Homebrew scripts are not part of the managed state. New files or scripts need a demonstrated purpose and a safe rerun path.

## 2026-09-23 — Create only directories required by the managed setup

The `p` alias targets lowercase `~/projects`, so the bootstrap flow creates it with `mkdir -p` before the alias is used. This is safe to rerun and needs no custom installer. Uppercase `~/Projects` is not required by Dotmac.

## 2026-09-23 — Put Dotmac under projects and keep local agent handoff outside Git

The normal checkout location is `~/projects/dotmac`, under the directory opened by `p`. The setup instructions create `~/projects` before cloning. Agents keep a concise `.agent-local/handoff.md` for session-specific context; Git ignores that directory. The tracked worklog and decisions remain the durable source for future Macs, because ignored files do not travel with a clone.
