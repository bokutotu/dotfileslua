#───────────────────────────────────────────────
# 0. compinit（キャッシュ）
#───────────────────────────────────────────────
autoload -Uz compinit
compinit -C

#───────────────────────────────────────────────
# 1. pure テーマ確実ロード（手動）
#───────────────────────────────────────────────
PURE_DIR=$HOME/.zsh/pure
[[ -d $PURE_DIR/.git ]] || git clone --depth=1 https://github.com/sindresorhus/pure.git "$PURE_DIR"
fpath=($PURE_DIR $fpath)
autoload -Uz promptinit; promptinit; prompt pure
PURE_GIT_PULL=0   PURE_GIT_DELAY=2
zstyle :prompt:pure:path color '#00FFFF'

#───────────────────────────────────────────────
# 2.  plug-in manager を検出：zi(v3) 優先、無ければ zinit(v2)
#───────────────────────────────────────────────
if [[ -f ${XDG_DATA_HOME:-$HOME/.local/share}/zi/bin/zi.zsh ]]; then
  # === zi v3 が既にある ======================================
  source ${XDG_DATA_HOME:-$HOME/.local/share}/zi/bin/zi.zsh
  zpm() { zi "$@"; }            # マクロ的に使うため関数化
elif [[ -f ${ZINIT_HOME:-$HOME/.local/share}/zinit/zinit.git/zinit.zsh ]]; then
  # === 旧 zinit v2 がある ====================================
  source ${ZINIT_HOME:-$HOME/.local/share}/zinit/zinit.git/zinit.zsh
  zpm() { zinit "$@"; }
else
  # === どちらも無い→ zi v3 をクローン ========================
  ZI_HOME=${XDG_DATA_HOME:-$HOME/.local/share}/zi
  git clone --depth=1 https://github.com/z-shell/zi.git "$ZI_HOME"
  source "$ZI_HOME/bin/zi.zsh"
  zpm() { zi "$@"; }
fi

#───────────────────────────────────────────────
# 3. プラグイン（マネージャの違いを吸収して同一書式で指定）
#───────────────────────────────────────────────
# async（pure 依存）
zpm ice depth=1 lucid wait'0'
zpm light mafredri/zsh-async

# autosuggestions（Ctrl-O でトグル）
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_STRATEGY=(history)
zpm ice lucid wait'1' atload'_zsh_autosuggest_start' blockf
zpm load zsh-users/zsh-autosuggestions

# fast-syntax-highlighting（軽量）
typeset -gA FAST_HIGHLIGHT_STYLES; FAST_HIGHLIGHT_STYLES[default]=none
FAST_HIGHLIGHT_MAX_BYTES=60000
zpm ice lucid wait'1' blockf
zpm load zdharma-continuum/fast-syntax-highlighting

# Ctrl-O で両方 ON/OFF
_toggle_hl() {
  if (( ${+functions[_zsh_autosuggest_start]} )); then
    zpm unload zsh-users/zsh-autosuggestions
    zpm unload zdharma-continuum/fast-syntax-highlighting
    zle -M "hl+autosuggest → OFF"
  else
    zpm load  zsh-users/zsh-autosuggestions
    zpm load  zdharma-continuum/fast-syntax-highlighting
    _zsh_autosuggest_start
    zle -M "hl+autosuggest → ON"
  fi
}
zle -N _toggle_hl; bindkey '^O' _toggle_hl   # Ctrl-O

# enhancd / git-open
export ENHANCD_HOOK_AFTER_CD=ls
zpm ice lucid wait'1'; zpm load bokutotu/enhancd
zpm ice lucid wait'1'; zpm load paulirish/git-open

# completions & 256color
zpm ice lucid wait'1'; zpm load zsh-users/zsh-completions
zpm ice lucid wait'2'; zpm load chrissicool/zsh-256color
zpm ice lucid wait'1'; zpm load zsh-users/zsh-history-substring-search

#───────────────────────────────────────────────
# 4. 便利関数・fzf 履歴検索
#───────────────────────────────────────────────
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
alias ls='lsd'

select-history() {
  BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt='History > ')
  CURSOR=$#BUFFER
}
zle -N select-history; bindkey '^R' select-history
ZSH_DISABLE_COMPFIX=true

#───────────────────────────────────────────────
# 5. PATH / pyenv
#───────────────────────────────────────────────
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"; eval "$(pyenv init -)"

#───────────────────────────────────────────────
# 6. alias & 追加
#───────────────────────────────────────────────
alias vi='nvim'
[[ -f ~/.alias.zsh ]] && source ~/.alias.zsh


export GIT_EDITOR="nvim"
# or
export EDITOR="nvim"

