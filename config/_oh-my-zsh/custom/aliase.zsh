alias loff="xset dpms force off"
alias tmux="tmux -2" #为tmux 支持256 color

alias p="percol" #只能搜索

alias pyhttp='sudo python -m SimpleHTTPServer ${1:-80}'
alias pytags='ctags --Python-kinds=cfmv --languages=Python '

alias l="ls -F"
alias ..="cd .."
alias ..2="cd ../.."
alias ..3="cd ../../.."
alias ..4="cd ../../../.."
alias ..5="cd ../../../../.."


alias a='fasd -a'        # any
alias s='fasd -si'       # show / search / select
alias d='fasd -d'        # directory
alias f='fasd -f'        # file
alias sd='fasd -sid'     # interactive directory selection
alias sf='fasd -sif'     # interactive file selection

function fasd_cd() {
    if ([ $# -le 1 ]); then
    fasd "$@"
  else
    local _fasd_ret="$(fasd -e 'printf %s' "$@")"
    [ -z "$_fasd_ret" ] && return
    [ -d "$_fasd_ret" ] && cd "$_fasd_ret" || printf %s\n "$_fasd_ret"
  fi
}
alias z='fasd_cd -d'     # cd, same functionality as j in autojump
alias zz='fasd_cd -d -i' # cd with interactive selection

if [ -f ~/.alias ]; then
    . ~/.alias
fi
