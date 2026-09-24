#!/bin/bash
set -euo pipefail

repo_dir=$(cd "$(dirname "$0")/.." && pwd -P)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/dotmac-test.XXXXXX")
trap 'rm -rf "$tmp"' EXIT
fakebin="$tmp/bin"
home_dir="$tmp/home"
mkdir -p "$fakebin" "$home_dir/Applications/Rectangle.app" "$home_dir/Applications/1Password.app"

cat > "$fakebin/brew" <<'EOF'
#!/bin/bash
printf '%s|skip=%s\n' "$*" "${HOMEBREW_BUNDLE_CASK_SKIP:-}" >> "$DOTMAC_BREW_LOG"
case "$1" in
	list) exit 1 ;;
	bundle)
		case "$2" in
			check)
				printf 'mock bundle check\n'
				exit "${MOCK_BREW_CHECK_STATUS:-0}"
				;;
			install)
				printf 'mock bundle install\n'
				exit "${MOCK_BREW_INSTALL_STATUS:-0}"
				;;
		esac
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
: > "$DOTMAC_BREW_LOG"
: > "$DOTMAC_STOW_LOG"

profiles=$("$repo_dir/scripts/dotmac" --json profiles)
[[ $profiles == *'"name":"gui-apps"'* ]]
[[ $profiles == *'Rectangle'* ]]
[[ $profiles == *'1Password'* ]]
[[ $profiles == *'1Password CLI'* ]]

plan=$("$repo_dir/scripts/dotmac" --json plan --profile essential)
[[ $plan == *'"ok":true'* ]]
[[ $plan == *'app bundle Rectangle.app'* ]]
[[ $plan == *'app bundle 1Password.app'* ]]
grep -q 'bundle check --no-upgrade' "$DOTMAC_BREW_LOG"
grep -q 'skip=.*rectangle' "$DOTMAC_BREW_LOG"
grep -q 'skip=.*1password' "$DOTMAC_BREW_LOG"

gui_plan=$("$repo_dir/scripts/dotmac" --json plan --profile gui-apps)
[[ $gui_plan == *'"ok":true'* ]]

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
# The fake check reports missing and the fake installer succeeds, so the CLI
# should report success and retain Homebrew's no-upgrade behavior.
install_result=$(MOCK_BREW_CHECK_STATUS=1 "$repo_dir/scripts/dotmac" --json apply --profile development 2>"$tmp/install.stderr")
[[ $install_result == *'"status":"applied"'* ]]
grep -q 'bundle install --no-upgrade' "$DOTMAC_BREW_LOG"
grep -q 'skip=.*1password-cli' "$DOTMAC_BREW_LOG"
grep -q 'mock bundle install' "$tmp/install.stderr"

: > "$DOTMAC_STOW_LOG"
check_home=$("$repo_dir/scripts/dotmac" --json home check)
[[ $check_home == *'"status":"clean"'* ]]
grep -q '^-n ' "$DOTMAC_STOW_LOG"

: > "$DOTMAC_STOW_LOG"
home_apply=$("$repo_dir/scripts/dotmac" --json home apply)
[[ $home_apply == *'"status":"applied"'* ]]
[[ $(wc -l < "$DOTMAC_STOW_LOG" | tr -d ' ') == 2 ]]

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

if command -v ruby >/dev/null 2>&1; then
	printf '%s\n' "$profiles" "$plan" "$gui_plan" "$dev_plan" "$apply" "$plan_missing" "$install_result" "$check_home" "$home_apply" "$prefs" "$differing_prefs" | ruby -rjson -e 'STDIN.each_line { |line| JSON.parse(line) }'
fi

printf 'dotmac CLI tests passed\n'
