#!/bin/bash
set -euo pipefail

repo_dir=$(cd "$(dirname "$0")/.." && pwd -P)

# The macOS administration workflow must be discoverable from this repository,
# not depend on an individual agent's global skill installation.
skill_file="$repo_dir/.agents/skills/macos-sysadmin/SKILL.md"
grep -Fq '.agents/skills/macos-sysadmin/SKILL.md' "$repo_dir/AGENTS.md"
if grep -Fq '~/.codex/skills/macos-sysadmin' "$repo_dir/AGENTS.md"; then
	printf '%s\n' 'AGENTS.md must use the repository-owned macos-sysadmin skill.' >&2
	exit 1
fi
[[ -f $skill_file ]]
grep -Eq '^name: macos-sysadmin$' "$skill_file"
grep -Eq '^description: .+' "$skill_file"
grep -Fq 'docs/setup-levels.md' "$skill_file"

tmp=$(mktemp -d "${TMPDIR:-/tmp}/dotmac-test.XXXXXX")
trap 'rm -rf "$tmp"' EXIT
fakebin="$tmp/bin"
home_dir="$tmp/home"
mkdir -p "$fakebin" "$home_dir/Applications/Rectangle.app" "$home_dir/Applications/1Password.app"

cat > "$fakebin/brew" <<'EOF'
#!/bin/bash
printf '%s|skip=%s\n' "$*" "${HOMEBREW_BUNDLE_CASK_SKIP:-}" >> "$DOTMAC_BREW_LOG"
case "$1" in
	list)
		if [[ ${MOCK_BREW_ALL_INSTALLED:-0} == 1 ]]; then
			case " $* " in
				*" --formula "*) printf 'git\nripgrep\n' ;;
				*" --cask "*) printf '1password\n' ;;
			esac
			exit 0
		fi
		exit 1
		;;
	bundle)
		case "$2" in
			check)
				printf 'mock bundle check\n'
				if [[ -n ${MOCK_BREW_CHECK_FIRST_STATUS:-} && ! -e $DOTMAC_BREW_CHECK_MARKER ]]; then
					: > "$DOTMAC_BREW_CHECK_MARKER"
					exit "$MOCK_BREW_CHECK_FIRST_STATUS"
				fi
				exit "${MOCK_BREW_CHECK_STATUS:-0}"
				;;
			install)
				printf 'mock bundle install\n'
				exit "${MOCK_BREW_INSTALL_STATUS:-0}"
				;;
			upgrade)
				printf 'mock bundle upgrade\n'
				: > "$DOTMAC_UPGRADE_MARKER"
				exit "${MOCK_BREW_UPGRADE_STATUS:-0}"
				;;
			list)
				if [[ " $* " == *" --formula "* ]]; then
					printf 'git\nripgrep\n'
				else
					printf '1password\n'
				fi
				exit 0
				;;
			dump)
				printf 'brew "git"\ncask "1password"\n'
				exit 0
				;;
		esac
		;;
	outdated)
		last=''
		for last in "$@"; do :; done
		if [[ ! -e $DOTMAC_UPGRADE_MARKER ]]; then
			case $last in
				ripgrep|1password) printf '%s\n' "$last"; exit 1 ;;
			esac
		fi
		exit 0
		;;
esac
exit 64
EOF
chmod +x "$fakebin/brew"

cat > "$fakebin/op" <<'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "$fakebin/op"

cat > "$fakebin/stow" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >> "$DOTMAC_STOW_LOG"
if [[ ${1:-} == -n && ${MOCK_STOW_PREVIEW_STATUS:-0} != 0 ]]; then
	printf 'mock stow conflict\n'
	exit "$MOCK_STOW_PREVIEW_STATUS"
fi
printf 'mock stow ok\n'
EOF
chmod +x "$fakebin/stow"

cat > "$fakebin/defaults" <<'EOF'
#!/bin/bash
case "$*" in
	'read com.apple.finder ShowPathbar')
		if [[ ${MOCK_DEFAULTS_MISMATCH:-0} == 1 ]]; then printf '0\n'; else printf '1\n'; fi
		;;
	'read com.apple.finder ShowStatusBar') printf '1\n' ;;
	'read com.apple.finder FXPreferredViewStyle') printf 'Nlsv\n' ;;
	'read com.apple.dock orientation') printf 'left\n' ;;
	*) exit 1 ;;
esac
EOF
chmod +x "$fakebin/defaults"

export PATH="$fakebin:$PATH"
export HOME="$home_dir"
export DOTMAC_BREW_LOG="$tmp/brew.log"
export DOTMAC_STOW_LOG="$tmp/stow.log"
export DOTMAC_BREW_CHECK_MARKER="$tmp/brew-check.marker"
export DOTMAC_UPGRADE_MARKER="$tmp/brew-upgraded.marker"
: > "$DOTMAC_BREW_LOG"
: > "$DOTMAC_STOW_LOG"

profiles=$("$repo_dir/scripts/dotmac" --json profiles)
[[ $profiles == *'"name":"gui-apps"'* ]]
[[ $profiles == *'Rectangle'* ]]
[[ $profiles == *'1Password'* ]]
[[ $profiles == *'1Password CLI'* ]]
[[ $profiles == *'diagnostics'* ]]

plan=$("$repo_dir/scripts/dotmac" --json plan --profile essential)
[[ $plan == *'"ok":true'* ]]
[[ $plan == *'app bundle Rectangle.app'* ]]
[[ $plan == *'app bundle 1Password.app'* ]]
grep -q 'bundle check --no-upgrade' "$DOTMAC_BREW_LOG"
grep -q 'skip=.*rectangle' "$DOTMAC_BREW_LOG"
grep -q 'skip=.*1password' "$DOTMAC_BREW_LOG"

gui_plan=$("$repo_dir/scripts/dotmac" --json plan --profile gui-apps)
[[ $gui_plan == *'"ok":true'* ]]

diagnostics_plan=$("$repo_dir/scripts/dotmac" --json plan --profile diagnostics)
[[ $diagnostics_plan == *'"ok":true'* ]]

dev_plan=$("$repo_dir/scripts/dotmac" --json plan --profile development)
[[ $dev_plan == *'command op on PATH'* ]]
grep -q 'skip=.*1password-cli' "$DOTMAC_BREW_LOG"

: > "$DOTMAC_BREW_LOG"
apply=$("$repo_dir/scripts/dotmac" --json apply --profile essential)
[[ $apply == *'"status":"already-satisfied"'* ]]
! grep -q 'bundle install' "$DOTMAC_BREW_LOG"

: > "$DOTMAC_BREW_LOG"
if plan_missing=$(MOCK_BREW_CHECK_STATUS=1 "$repo_dir/scripts/dotmac" --json plan --profile development); then
	printf 'expected an incomplete profile plan to exit nonzero\n' >&2
	exit 1
fi
[[ $plan_missing == *'"status":"incomplete"'* ]]
! grep -q 'bundle install' "$DOTMAC_BREW_LOG"

: > "$DOTMAC_BREW_LOG"
# The initial check finds a missing entry; installation is followed by a
# second check so a successful Brew exit alone cannot claim the profile is ready.
rm -f "$DOTMAC_BREW_CHECK_MARKER"
install_result=$(MOCK_BREW_CHECK_FIRST_STATUS=1 "$repo_dir/scripts/dotmac" --json apply --profile development 2>"$tmp/install.stderr")
[[ $install_result == *'"status":"verified"'* ]]
grep -q 'bundle install --no-upgrade' "$DOTMAC_BREW_LOG"
[[ $(grep -c 'bundle check --no-upgrade' "$DOTMAC_BREW_LOG") == 2 ]]
grep -q 'skip=.*1password-cli' "$DOTMAC_BREW_LOG"
grep -q 'mock bundle install' "$tmp/install.stderr"

: > "$DOTMAC_BREW_LOG"
rm -f "$DOTMAC_BREW_CHECK_MARKER"
if install_unverified=$(MOCK_BREW_CHECK_FIRST_STATUS=1 MOCK_BREW_CHECK_STATUS=1 "$repo_dir/scripts/dotmac" --json apply --profile development 2>/dev/null); then
	printf 'expected failed post-install verification to exit nonzero\n' >&2
	exit 1
fi
[[ $install_unverified == *'"status":"verification-failed"'* ]]

: > "$DOTMAC_BREW_LOG"
inventory=$("$repo_dir/scripts/dotmac" --json inventory)
[[ $inventory == *'"status":"snapshot"'* ]]
[[ $inventory == *'brew'*'git'* ]]
grep -q 'bundle dump --file=-' "$DOTMAC_BREW_LOG"

: > "$DOTMAC_BREW_LOG"
outdated=$(MOCK_BREW_ALL_INSTALLED=1 "$repo_dir/scripts/dotmac" --json outdated --profile essential)
[[ $outdated == *'"status":"updates-available"'* ]]
[[ $outdated == *'formula ripgrep'* && $outdated == *'cask 1password'* ]]
! grep -q 'bundle install\|bundle upgrade\|bundle cleanup' "$DOTMAC_BREW_LOG"

: > "$DOTMAC_BREW_LOG"
upgrade_result=$(MOCK_BREW_ALL_INSTALLED=1 "$repo_dir/scripts/dotmac" --json upgrade --profile essential 2>"$tmp/upgrade.stderr")
[[ $upgrade_result == *'"status":"verified"'* ]]
grep -Fq "bundle upgrade --file $repo_dir/Brewfile|" "$DOTMAC_BREW_LOG"
! grep -q 'bundle cleanup' "$DOTMAC_BREW_LOG"

: > "$DOTMAC_BREW_LOG"
upgrade_noop=$(MOCK_BREW_ALL_INSTALLED=1 "$repo_dir/scripts/dotmac" --json upgrade --profile essential)
[[ $upgrade_noop == *'"status":"already-current"'* ]]
! grep -q 'bundle upgrade' "$DOTMAC_BREW_LOG"

: > "$DOTMAC_STOW_LOG"
check_home=$("$repo_dir/scripts/dotmac" --json home check)
[[ $check_home == *'"status":"clean"'* ]]
grep -q '^-n ' "$DOTMAC_STOW_LOG"
# check stays read-only.
[[ ! -e $home_dir/.gitconfig ]]

: > "$DOTMAC_STOW_LOG"
home_apply=$("$repo_dir/scripts/dotmac" --json home apply)
[[ $home_apply == *'"status":"applied"'* ]]
[[ $(wc -l < "$DOTMAC_STOW_LOG" | tr -d ' ') == 2 ]]
# apply creates a private, untracked ~/.gitconfig so `git config --global` never writes into the repo.
[[ -f $home_dir/.gitconfig && ! -L $home_dir/.gitconfig ]]
[[ $(stat -f %Lp "$home_dir/.gitconfig") == 600 ]]
[[ $home_apply == *'Created ~/.gitconfig'* ]]
printf '[user]\n\tname = Test\n' >> "$home_dir/.gitconfig"
home_reapply=$("$repo_dir/scripts/dotmac" --json home apply)
grep -q 'name = Test' "$home_dir/.gitconfig"
[[ $home_reapply != *'Created ~/.gitconfig'* ]]

: > "$DOTMAC_STOW_LOG"
if MOCK_STOW_PREVIEW_STATUS=1 "$repo_dir/scripts/dotmac" --json home apply >/dev/null; then
	printf 'expected Stow conflict to block home apply\n' >&2
	exit 1
fi
[[ $(wc -l < "$DOTMAC_STOW_LOG" | tr -d ' ') == 1 ]]

prefs=$(DOTMAC_DEFAULTS_CMD="$fakebin/defaults" "$repo_dir/scripts/dotmac" --json preferences check)
[[ $prefs == *'"ok":true'* ]]
if differing_prefs=$(MOCK_DEFAULTS_MISMATCH=1 DOTMAC_DEFAULTS_CMD="$fakebin/defaults" "$repo_dir/scripts/dotmac" --json preferences check); then
	printf 'expected differing preferences to exit nonzero\n' >&2
	exit 1
fi
[[ $differing_prefs == *'"status":"different"'* ]]

# disk snapshot/diff: a fake dua reports sizes that grow between snapshots.
cat > "$fakebin/dua" <<'EOF'
#!/bin/bash
# Mimics `dua aggregate --depth` with one input: the input's children as an
# indented tree, then a non-zero exit for unreadable files.
scale=${MOCK_DUA_SCALE:-1}
printf '%12s b a\n' $((1073741824 * scale))
printf '%12s b   deep\n' $((1073741824 * scale))
printf '%12s b b dir <2 IO Errors>\n' 2147483648
exit 1
EOF
chmod +x "$fakebin/dua"
export DOTMAC_DISK_DIR="$tmp/disk"
snap1=$("$repo_dir/scripts/dotmac" --json disk snapshot /h)
[[ $snap1 == *'"ok":true'* ]]
sleep 1
snap2=$(MOCK_DUA_SCALE=4 "$repo_dir/scripts/dotmac" --json disk snapshot /h)
[[ $snap2 == *'"ok":true'* ]]
newest=$(ls -1 "$DOTMAC_DISK_DIR"/*.tsv | tail -1)
grep -Fq $'2147483648\t/h/b dir' "$newest"
grep -Fq $'/h/a/deep' "$newest"
if grep -q 'total' "$newest"; then
	printf 'snapshot must drop the dua total line\n' >&2
	exit 1
fi
disk_diff=$("$repo_dir/scripts/dotmac" disk diff)
[[ $disk_diff == *'free space change:'* ]]
[[ $disk_diff == *'+3.00 GB'*'/h/a'* ]]
if [[ $disk_diff == *'/h/b dir'* ]]; then
	printf 'unchanged paths must not appear in disk diff\n' >&2
	exit 1
fi
# disk snapshot: --ignore-dirs skips a path and records it; the comment lines
# disk diff already ignores (see /^#/ { next }) make this safe to verify there.
sleep 1
export DOTMAC_DISK_IGNORE_DIRS="$tmp/skip-me"
mkdir -p "$tmp/skip-me"
snap_ignored=$("$repo_dir/scripts/dotmac" --json disk snapshot /h)
[[ $snap_ignored == *'"ok":true'* ]]
newest=$(ls -1 "$DOTMAC_DISK_DIR"/*.tsv | tail -1)
grep -Fq "# ignored: -i $tmp/skip-me" "$newest"
unset DOTMAC_DISK_IGNORE_DIRS

# disk snapshot: a dua that hangs past the timeout is killed, not left to
# block forever or abort the script (set -e + pipefail would otherwise trip
# on dua's own non-zero exit from unreadable files, let alone a timeout).
sleep 1
cat > "$fakebin/dua" <<'EOF'
#!/bin/bash
sleep 30
EOF
chmod +x "$fakebin/dua"
export DOTMAC_DISK_SNAPSHOT_TIMEOUT=1
snap_timeout=$("$repo_dir/scripts/dotmac" --json disk snapshot /h)
unset DOTMAC_DISK_SNAPSHOT_TIMEOUT
[[ $snap_timeout == *'"ok":true'* ]]
newest=$(ls -1 "$DOTMAC_DISK_DIR"/*.tsv | tail -1)
grep -Fq '# TIMEOUT after 1s' "$newest"

disk_diff_json=$("$repo_dir/scripts/dotmac" --json disk diff)

if command -v ruby >/dev/null 2>&1; then
	printf '%s\n' "$profiles" "$plan" "$gui_plan" "$diagnostics_plan" "$dev_plan" "$apply" "$plan_missing" "$install_result" "$install_unverified" "$inventory" "$outdated" "$upgrade_result" "$upgrade_noop" "$check_home" "$home_apply" "$home_reapply" "$prefs" "$differing_prefs" "$snap1" "$snap2" "$disk_diff_json" | ruby -rjson -e 'STDIN.each_line { |line| JSON.parse(line) }'
fi

printf 'dotmac CLI tests passed\n'
