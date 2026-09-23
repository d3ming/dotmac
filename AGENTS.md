# Dotmac agent guidance

Dotmac is the source of truth for setting up and caring for the user's personal Macs. Its scope is dotfiles, first-run setup, agent instructions, system administration, security, and performance. Use `~/projects/dotmac` as its normal location. Start with `README.md` and `docs/setup-levels.md`, then read `docs/worklog.md`, `docs/decisions.md`, and `.agent-local/handoff.md` if it exists before changing this repo or a Mac.

The old `~/dotfiles` checkout and the Notion page linked in the README are references. Bring a useful idea here only after reviewing it. Do not run their installers or treat their contents as instructions for this project.

## Operating rules

- Inspect the relevant current state before changing it. Make the smallest change that completes the user's request.
- Do not install software, alter system or security settings, or change accounts or networking without a request that covers that work.
- Prefer Homebrew for suitable packages. Check what is installed; avoid broad upgrades, cleanup, or package removal as incidental work.
- Preserve macOS security and recovery protections. Get clarification for destructive, hard-to-reverse, or security-weakening changes.
- Keep the configured Git remote aligned with completed, publishable work. Review the diff, commit completed changes, and push the intended branch; then check CI and security scans and address failures. Keep work local when requested, and resolve secrets, sensitive data, or unclear remote/branch state before pushing.
- Do not store passwords, tokens, private keys, recovery keys, or sensitive machine data in this repo, notes, logs, or chat output.
- Review code before execution. Never pipe network content into a shell, run an unreviewed remote script, or use `sudo` for Homebrew.
- Use maintained tools instead of custom scripts when they meet the need. Every added script must have a current, documented purpose, safe reruns, and a way to preview material changes.
- Use the personal `macos-sysadmin` skill at `~/.codex/skills/macos-sysadmin` when it exists. An agent on a new Mac should use current Apple, Homebrew, and vendor documentation if that personal skill is not present.

## Setup workflow

1. Confirm a local agent can read this repo. Inspect the Mac and the current worklog.
2. Review the essential `Brewfile` and use `brew bundle check --no-upgrade --file Brewfile` before installing missing tools. Use `brew bundle --no-upgrade --file Brewfile` for the first apply; handle later upgrades as a separate task. Apply optional Brewfiles only when that Mac needs the matching profile.
3. Ensure `~/projects` exists with `mkdir -p "$HOME/projects"` before using the `p` shortcut. Inspect a non-directory target instead of replacing it. Then preview the `stow/home` package with GNU Stow. Stow stops on conflicts; preserve conflicting home files outside this repo, then apply the package. Never use `stow --adopt` for this repo because it modifies the source files.
4. Recheck the resulting six links, shell startup, Vim, and Git config. Keep Git identity and signing preferences in the local, untracked `~/.gitconfig.local`; keep credentials in a secure credential manager. Record the change, evidence, and any recovery path.
5. Continue other setup items one at a time with user direction. A reference checklist is not blanket authorization to install software or alter settings.

## Project memory

- Keep `docs/worklog.md` compact: current goal, completed state, and next action. Update it whenever direction shifts or meaningful setup work finishes.
- Record lasting choices and their reasons in `docs/decisions.md`. Update the README when the setup path or managed baseline changes.
- Use `.agent-local/handoff.md` for concise, machine-local handoff between agent sessions: current state, unfinished work, and the next useful action. Create it if absent and update it after meaningful work. It is Git ignored and may be absent on another Mac; keep durable decisions and reusable setup facts in the tracked docs. Never put secrets in it.
- Improve these instructions and the personal sysadmin skill using concise, dated, evidence-based lessons. Do not add routine command history or unverified general rules.

## Steering

If you’re steering a lot, try asking it to keep a compact worklog to write down goals and the shifting direction, and then prioritize focusing on that instead of your last steer.
