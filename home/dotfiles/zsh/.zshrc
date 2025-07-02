typeset -U path cdpath fpath manpath
autoload -U compinit && compinit
HISTSIZE="10000"
SAVEHIST="10000"
HISTFILE="$HOME/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"

setopt HIST_FCNTL_LOCK
unsetopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
unsetopt HIST_IGNORE_ALL_DUPS
unsetopt HIST_SAVE_NO_DUPS
unsetopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
unsetopt BEEP
setopt NOMATCH

zstyle ':completion:*' menu select
zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"

#ALT LEFT
bindkey '^[[1;3D' backward-word
#ALT RIGHT
bindkey '^[[1;3C' forward-word
#CTRL LEFT
bindkey '^[[1;5D' backward-word
#CTRL RIGHT
bindkey '^[[1;5C' forward-word
#CTRL BACKSPACE
bindkey '^H' backward-delete-char
#ALT BACKSPACE
bindkey '^[^?' backward-kill-word

autoload -U select-word-style
select-word-style bash

exist() {
  command -v "$1" > /dev/null 2>&1
}

exist bat && alias cat='bat -pp'
exist dust && alias dust='dust -d 1 '
exist ip && alias ip='ip -c'
exist lazygit && alias lg='lazygit'
exist eza && alias ls='eza --icons auto'
exist xdg-open && alias o=xdg-open
exist ssh && alias ssh='TERM=xterm-256color ssh'
exist doas && alias sudo=doas
exist nvim && alias v=nvim

exist fzf && eval "$(fzf --zsh)"
exist starship && eval "$(starship init zsh)"
exist zoxide && eval "$(zoxide init zsh)" && alias cd=z

if [ -z "$WAYLAND_DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ] ; then
    exec Hyprland
fi

[[ -z "$GUIX_ENVIRONMENT" && -z "$IN_NIX_SHELL" ]] && exist fastfetch && fastfetch
