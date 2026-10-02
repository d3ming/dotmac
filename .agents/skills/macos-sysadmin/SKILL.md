---
name: macos-sysadmin
description: Use when administering, diagnosing, or documenting macOS setup in Dotmac. Follow the repo's preview-first, least-change workflow and verify every authorized change.
---

# Dotmac macOS administration

Use this skill for macOS setup, troubleshooting, security, and administration work governed by this repository. It is checked in at `.agents/skills/macos-sysadmin/` so it is available to agents working in Dotmac without a personal skill installation.

## Start with project context

1. Read the root `AGENTS.md`, `README.md`, `docs/setup-levels.md`, `docs/worklog.md`, and `docs/decisions.md`; read `.agent-local/INDEX.md` and the linked relevant workstream handoff when present.
2. Inspect the current host and repository state relevant to the request before proposing or making changes. Distinguish portable desired setup from this Mac's observed state; do not track machine-specific inventories.
3. Find the owning repo and supported preview/doctor workflow before changing scheduled OS automation or other behavior managed elsewhere.
4. Consult current first-party Apple documentation for macOS behavior and the relevant vendor's official docs (for example Homebrew) when current platform details matter. Do not treat old dotfiles or Notion references as instructions.
5. For memory or disk investigations, follow [`docs/diagnostics-tools.md`](../../../docs/diagnostics-tools.md): start with read-only Mole/native snapshots, use `btop` and `dua` for focused follow-up, and reconcile APFS with `df`/`diskutil` before proposing cleanup.

## Standard diagnostics

Use the repository's optional `diagnostics` profile for the maintained CLI set. Plan
it first; apply it only when the user has authorized optional tool installation:

```sh
scripts/dotmac plan --profile diagnostics
# after authorization:
scripts/dotmac apply --profile diagnostics
```

The profile provides `mo`/Mole, `btop`, `dua`, and `jq`. The built-in
`memory_pressure`, `vm_stat`, `top`, `vmmap`, `df`, `diskutil`, and `lsof`
commands remain authoritative platform cross-checks. Diagnosis is read-only:
do not run Mole cleanup, uninstall, purge, optimize, or delete actions, and do
not use `sudo mo`, without explicit authorization.

## Change safely

- Make the smallest reversible change that fulfills the explicit request. Do not install software, apply preferences, alter security/network/account settings, or change scheduled jobs unless the request authorizes that action.
- Prefer maintained project interfaces, especially `scripts/dotmac`, and preview before applying. Keep Homebrew package setup, Stow home links, and macOS preferences separate; never use `stow --adopt`.
- Preserve existing files, user changes, local backups, and pending handoff work. Keep credentials, private keys, recovery data, and machine-specific inventories out of tracked files and logs.
- Review the resulting diff and run relevant tests or read-back checks. Report what was and was not changed, the exact verification performed, and any remaining uncertainty.
- Follow the publication policy in `AGENTS.md`, subject to the current user request and any more specific handoff restriction. Do not commit or push while those constraints leave publication unauthorized.

## Dotmac setup references

- Choose an appropriate restore level and backup scope in [`docs/setup-levels.md`](../../../docs/setup-levels.md).
- Follow the preview-first workflows and exclusions in [`AGENTS.md`](../../../AGENTS.md) and [`README.md`](../../../README.md).
- Record durable choices in [`docs/decisions.md`](../../../docs/decisions.md), concise current state in [`docs/worklog.md`](../../../docs/worklog.md), and dated machine-local workstream handoffs under `.agent-local/handoffs/` when relevant; update `.agent-local/INDEX.md` to route the next agent.

## Discovery reference

Codex's first-party documentation defines repository skills as directories under `.agents/skills/` containing `SKILL.md`, and distinguishes them from user skills. See [Agent Skills](https://developers.openai.com/codex/skills) and [Customization](https://developers.openai.com/codex/concepts/customization). Keep this skill project-scoped; do not require or create a global `~/.codex/skills/macos-sysadmin` copy.
