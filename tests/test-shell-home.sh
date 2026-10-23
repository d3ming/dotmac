#!/bin/bash
set -euo pipefail

repo_dir=$(cd "$(dirname "$0")/.." && pwd -P)
command -v stow >/dev/null
tmp=$(mktemp -d "${TMPDIR:-/tmp}/dotmac-shell-test.XXXXXX")
trap 'rm -rf "$tmp"' EXIT
shell_repo="$tmp/repo"
mkdir -p "$shell_repo/scripts"
cp "$repo_dir/scripts/dotmac" "$shell_repo/scripts/"
cp -R "$repo_dir/stow" "$repo_dir/templates" "$shell_repo/"

run_home() {
	env HOME="$shell_home" "$shell_repo/scripts/dotmac" "$@"
}

# Real Stow and real Zsh: appending installer settings must never edit the repo.
shell_home="$tmp/fresh"
mkdir -p "$shell_home/.local/bin"
run_home home check > "$tmp/check"
[[ ! -e $shell_home/.zshrc && ! -e $shell_home/.zprofile ]]
[[ ! -e $shell_home/.config && ! -e $shell_repo/.agent-local ]]
run_home home apply > "$tmp/apply"
for name in zshrc zprofile; do
	[[ -f $shell_home/.$name && ! -L $shell_home/.$name ]]
	[[ $(stat -f %Lp "$shell_home/.$name") == 600 ]]
	[[ -f $shell_home/.config/zsh/$name ]]
done
printf '\nexport DOTMAC_INSTALLER_TEST=present\n' >> "$shell_home/.zshrc"
printf '\nexport DOTMAC_LOGIN_INSTALLER_TEST=present\n' >> "$shell_home/.zprofile"
printf 'export EDITOR=local-editor\n(( DOTMAC_LOCAL_LOADS += 1 ))\n' > "$shell_home/.zshrc.local"
printf 'export DOTMAC_LOGIN_LOCAL_TEST=present\n' > "$shell_home/.zprofile.local"
before=$(shasum -a 256 "$shell_home/.zshrc" "$shell_home/.zprofile")
run_home home apply > "$tmp/reapply"
[[ $before == "$(shasum -a 256 "$shell_home/.zshrc" "$shell_home/.zprofile")" ]]
for name in zshrc zprofile; do
	cmp "$repo_dir/stow/home/.config/zsh/$name" "$shell_repo/stow/home/.config/zsh/$name"
done
env HOME="$shell_home" ZDOTDIR="$shell_home" /bin/zsh -dlic '
	[[ $EDITOR == local-editor && $DOTMAC_LOCAL_LOADS == 1 ]] &&
	[[ $DOTMAC_INSTALLER_TEST == present && $DOTMAC_LOGIN_INSTALLER_TEST == present ]] &&
	[[ $DOTMAC_LOGIN_LOCAL_TEST == present && ${aliases[g]} == git ]] &&
	(( ${path[(Ie)$HOME/.local/bin]} > 0 ))
'

# A pulled checkout can leave old absolute or relative Dotmac links dangling.
shell_home="$tmp/legacy"
mkdir -p "$shell_home"
ln -s "$shell_repo/stow/home/.zprofile" "$shell_home/.zprofile"
ln -s ../repo/stow/home/.zshrc "$shell_home/.zshrc"
printf 'export DOTMAC_LEGACY_LOCAL=preserved\n' > "$shell_home/.zshrc.local"
run_home home check > "$tmp/legacy-check"
[[ -L $shell_home/.zshrc && -L $shell_home/.zprofile ]]
[[ ! -e $shell_repo/.agent-local ]]
grep -q 'Migrate Dotmac' "$tmp/legacy-check"
run_home home apply > "$tmp/legacy-apply"
[[ ! -L $shell_home/.zshrc && ! -L $shell_home/.zprofile ]]
grep -q 'DOTMAC_LEGACY_LOCAL=preserved' "$shell_home/.zshrc.local"
for backup in "$shell_repo"/.agent-local/backups/*; do
	[[ -L $backup/.zshrc && -L $backup/.zprofile ]]
	[[ $(stat -f %Lp "$backup") == 700 ]]
done

# Unknown startup files and links need review; preflight must not partially apply.
shell_home="$tmp/conflict"
mkdir -p "$shell_home"
printf 'export EXISTING_CONFIG=preserved\n' > "$shell_home/.zshrc"
if run_home home apply > "$tmp/conflict-check"; then
	printf 'expected unrelated local startup file to block apply\n' >&2
	exit 1
fi
grep -q 'EXISTING_CONFIG=preserved' "$shell_home/.zshrc"
[[ ! -e $shell_home/.config && ! -e $shell_home/.zprofile ]]
mv "$shell_home/.zshrc" "$shell_home/custom-zshrc"
ln -s custom-zshrc "$shell_home/.zshrc"
if run_home home apply > "$tmp/symlink-conflict"; then
	printf 'expected unrelated startup symlink to block apply\n' >&2
	exit 1
fi
[[ $(readlink "$shell_home/.zshrc") == custom-zshrc ]]
[[ ! -e $shell_home/.config && ! -e $shell_home/.zprofile ]]

printf 'local shell startup tests passed\n'
