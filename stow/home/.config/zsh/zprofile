# Initialize Homebrew for login shells on Apple silicon or Intel Macs.
for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
	if [[ -x "$brew_bin" ]]; then
		eval "$("$brew_bin" shellenv)"
		break
	fi
done
unset brew_bin

# User-level commands (uv tool, pipx, personal scripts) for login shells, including non-interactive ones.
typeset -U path PATH
for user_bin in "$HOME/.local/bin" "$HOME/bin"; do
	[[ -d "$user_bin" ]] && path=("$user_bin" $path)
done
unset user_bin
