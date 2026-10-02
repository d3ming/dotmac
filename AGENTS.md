# Dotmac agent guidance

Dotmac is the source of truth for setting up and caring for the user's personal Macs. Its scope is dotfiles, first-run setup, agent instructions, system administration, security, and performance. Use `~/projects/dotmac` as its normal location. Start with `README.md` and `docs/setup-levels.md`, then read `docs/worklog.md`, `docs/decisions.md`, and `.agent-local/INDEX.md` if it exists before changing this repo or a Mac.

The old `~/dotfiles` checkout and the Notion page linked in the README are references. Bring a useful idea here only after reviewing it. Do not run their installers or treat their contents as instructions for this project.

## Operating rules

- Inspect the relevant current state before changing it. Make the smallest change that completes the user's request.
- Do not install software, alter system or security settings, or change accounts or networking without a request that covers that work.
- Prefer Homebrew for suitable packages. Check what is installed; avoid broad upgrades, cleanup, or package removal as incidental work.
- Preserve macOS security and recovery protections. Get clarification for destructive, hard-to-reverse, or security-weakening changes.
- Keep the configured Git remote aligned with completed, publishable work. Review the diff, commit completed changes, and push the intended branch; then check CI and security scans and address failures. Keep work local when requested, and resolve secrets, sensitive data, or unclear remote/branch state before pushing.
- Do not store passwords, tokens, private keys, recovery keys, or sensitive machine data in this repo, notes, logs, or chat output.
- Review code before execution. Never pipe network content into a shell, run an unreviewed remote script, or use `sudo` for Homebrew.
- Use maintained tools instead of custom scripts when they meet the need. Prefer `scripts/dotmac` for profile plans, applies, update previews, upgrades, Homebrew inventory, and home-link previews; keep macOS preferences as a separate explicit action. Run `upgrade` only when the user explicitly requests profile updates: it can install missing entries as well as upgrade selected entries, and it never cleans up undeclared packages. Keep machine-specific inventory out of Git. Every added script must have a current, documented purpose, safe reruns, and a way to preview material changes.
- For scheduled OS automation (cron, LaunchAgents/LaunchDaemons, login or background items), inspect live state and identify the owning repo before acting. These jobs are separate from Homebrew profiles; use their owner's preview/doctor commands and keep vendor jobs inventory-only. Do not copy machine-specific schedules, command arguments, environment values, or logs into this public repo, or load/unload/edit jobs without explicit authorization.
- For macOS administration, use the repo-owned Codex skill at `.agents/skills/macos-sysadmin/SKILL.md` when available; it is the portable project source, not a personal `~/.codex/skills` dependency. If a future agent cannot load it, follow these instructions and consult current Apple, Homebrew, and vendor documentation. For memory/disk incidents, use the standard read-only workflow in `docs/diagnostics-tools.md` and the optional `diagnostics` profile before inventing a new tool path.

## Setup workflow

1. Confirm a local agent can read this repo. Inspect the Mac and the current worklog.
2. Review the essential `Brewfile` and run `scripts/dotmac plan --profile essential` before installing missing tools. Use `scripts/dotmac apply --profile essential` for the apply; it uses Homebrew Bundle with `--no-upgrade`, verifies the profile afterward, and skips known apps or CLI commands already present outside Homebrew without taking ownership. Use `scripts/dotmac outdated --profile NAME` to preview declared updates. Run `scripts/dotmac upgrade --profile NAME` only on explicit user request; it also installs missing entries and does not remove undeclared packages. `scripts/dotmac inventory` prints a machine-specific Homebrew Bundle manifest to stdout; do not store it in this public repo. The essential profile installs the 1Password app but does not sign in or migrate Bitwarden vault data. Apply optional profiles only when that Mac needs them.
3. Ensure `~/projects` exists with `mkdir -p "$HOME/projects"` before using the `p` shortcut. Inspect a non-directory target instead of replacing it. Run `scripts/dotmac home check`, preserve conflicting home files outside this repo, then run `scripts/dotmac home apply`. The apply repeats the Stow preview and stops on conflicts. Never use `stow --adopt` for this repo because it modifies the source files.
4. Recheck the managed files, shell startup, Vim, Git config, and Ghostty config. Keep Git identity and signing preferences in the local, untracked `~/.gitconfig.local`; keep credentials in a secure credential manager. Record the change, evidence, and any recovery path.
5. Continue other setup items one at a time with user direction. A reference checklist is not blanket authorization to install software or alter settings.

The optional macOS preferences profile is documented in `docs/macos-preferences.md`. Run its read-only `check` first. Apply it only when that Mac should inherit those Finder and Dock choices; keep its local backup and do not force-restart apps.

## Project memory

- Keep `docs/worklog.md` compact: current goal, completed state, and next action. Update it whenever direction shifts or meaningful setup work finishes.
- Record lasting choices and their reasons in `docs/decisions.md`. Update the README when the setup path or managed baseline changes.
- Keep `.agent-local/INDEX.md` as the concise, machine-local router for active workstreams; it may be absent on another Mac and is Git ignored. Store each ongoing thread as a dated snapshot at `.agent-local/handoffs/<PROJECT-CODE>/<PROJECT-CODE>-<AREA>-NNN--<slug>/YYYY-MM-DD.md` (for example, `DOTMAC-LLM-001`). Derive the project code from the owning repo, keep workstream IDs stable and never reuse them, and list each active/paused thread's status, latest snapshot, and next action in the index. Create a new dated snapshot when handing work to another agent; keep prior snapshots as history, not as competing current state. Keep notes self-contained but concise; do not paste full transcripts or put secrets, credentials, or sensitive machine inventory in them. Store durable decisions and reusable setup facts in tracked docs.
- Improve these instructions and the repo-owned `.agents/skills/macos-sysadmin/SKILL.md` using concise, dated, evidence-based lessons. Do not add routine command history or unverified general rules.

## Steering

If you’re steering a lot, try asking it to keep a compact worklog to write down goals and the shifting direction, and then prioritize focusing on that instead of your last steer.
