# Portable macOS preferences

This is an **opt-in** user-level profile for a few Finder and Dock choices observed on the source Mac on 2026-09-23 (macOS 27). It uses Apple's `defaults` utility. It does not run during the essential setup, require `sudo`, change security settings, or restart apps. Apple documents the [Finder path and status bars](https://support.apple.com/guide/mac-help/mchlp1774/mac) and the [Dock position](https://support.apple.com/guide/mac-help/change-desktop-dock-settings-mchlp1119/mac) in System Settings.

| Preference | Current value | Restore intent |
| --- | --- | --- |
| Finder path bar | Shown | Keep the current folder path visible. |
| Finder status bar | Shown | Keep item count and free space visible. |
| Finder default view | List (`Nlsv`) | Make file details easy to scan. |
| Dock position | Left | Match the source Mac's current workspace layout. |

From the Dotmac checkout:

```sh
scripts/macos-preferences check
scripts/macos-preferences apply
```

`check` is read-only and exits with status 1 if any value differs. `apply` prints each difference, changes only those keys, reads them back, and stores the previous values in an ignored `.agent-local/macos-preferences/` file with private permissions. It is safe to rerun: matching keys are untouched. To restore the saved values, use the exact backup path printed by `apply`:

```sh
scripts/macos-preferences restore /path/printed/by/apply.tsv
```

Finder and Dock may need to be restarted or the user may need to sign out before the interface reflects a change. The script does not force either action. If the Mac has managed preferences, a read-back failure stops the script; use the Mac's management policy instead of forcing the value.

## What was considered

The older `~/.dotfiles/macos/set-defaults.sh` was reviewed as historical data. Its keyboard-repeat and hot-corner values no longer match this Mac, and its Safari/debug and network settings are outside this profile. We also compared [Mathias Bynens's macOS defaults](https://github.com/mathiasbynens/dotfiles/blob/main/.macos), [a flag-gated Ansible workstation setup](https://github.com/mtharpe/ansible-macos-workstation), and [a dotfiles setup with dry-run and backup behavior](https://github.com/avelinoschz/dotfiles). The Finder key names and the preview/backup pattern were useful references; no external installer or broad settings script was copied.

Keyboard repeat, press-and-hold, Dock size, hot corners, trackpad, display, screenshots, login items, browser defaults, network, security/privacy permissions, and accessibility settings are excluded for now. Some vary by device or language, some have no explicit current value to preserve, and some need user or system approval. Prefer the visible System Settings control for those until there is a specific, verified cross-Mac reason to automate one.

## Other app settings

The default terminal's safe appearance choices are now in `stow/home/.config/ghostty/config.ghostty`. The source Mac's older macOS-specific Ghostty file must be reviewed before changing the live setup because it loads after the new XDG file. [Ghostty documents that load order](https://ghostty.org/docs/config). Zed has a custom keymap, theme, and settings with agent-server configuration; those need a focused portability and privacy review before copying. Direnv and cmux config contain machine-specific paths or commands. Micro's bindings file is empty. None of those files was bulk-copied into this public repo.
