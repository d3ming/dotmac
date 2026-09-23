# Dotmac interactive Zsh setup. Keep noninteractive shells quiet.
[[ -o interactive ]] || return

typeset -U path PATH
[[ -d "$HOME/bin" ]] && path=("$HOME/bin" $path)
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-$EDITOR}"

HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY EXTENDED_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS HIST_SAVE_NO_DUPS
unsetopt BEEP
bindkey -e
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
autoload -Uz compinit
compinit

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias p='cd ~/projects'
alias dl='cd ~/Downloads'
alias dt='cd ~/Desktop'
alias g='git'
alias l='ls -lh'
alias la='ls -lah'

mkd() {
	if (( $# != 1 )); then
		print -u2 'usage: mkd DIRECTORY'
		return 2
	fi
	mkdir -p -- "$1" && builtin cd -- "$1"
}

autoload -Uz add-zsh-hook colors vcs_info
colors
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' on %F{magenta}%b%f'
add-zsh-hook precmd vcs_info
setopt PROMPT_SUBST
PROMPT='%F{yellow}%n%f at %F{cyan}%m%f in %F{green}%~%f${vcs_info_msg_0_}%f
%# '

# Keep machine-specific customizations and secrets out of this repo.
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
