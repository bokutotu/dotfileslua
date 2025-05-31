
KEYTIMEOUT=1
setopt prompt_subst

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt EXTENDED_HISTORY

autoload -U compinit && compinit -C

bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward

ZSH_AUTOSUGGEST_DIR=${ZDOTDIR:-$HOME}/.zsh/zsh-autosuggestions
if [[ ! -e $ZSH_AUTOSUGGEST_DIR/zsh-autosuggestions.zsh ]]; then
  command git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_AUTOSUGGEST_DIR" 2>/dev/null || true
fi
ZSH_AUTOSUGGEST_USE_ASYNC=1
source "$ZSH_AUTOSUGGEST_DIR/zsh-autosuggestions.zsh"

_git_branch() {
  local b
  b=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) || return 0
  print -P "%F{green}($b)%f"
}

typeset -g _timer=0
preexec() { _timer=$SECONDS }

precmd() {
  local -i elapsed=$(( SECONDS - _timer ))
  local elapsed_str=""
  (( elapsed > 0 )) && elapsed_str="%F{magenta}${elapsed}s%f"

  PROMPT='%F{cyan}%*%f %F{yellow}%~%f $(_git_branch) %# '
  RPROMPT="$elapsed_str"
}

alias vi="nvim"
