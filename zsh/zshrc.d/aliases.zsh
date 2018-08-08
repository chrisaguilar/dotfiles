# Aliases
alias c='printf "\033c"'
alias clear='c'
alias e='exit'
alias uefisetup='sudo systemctl reboot --firmware-setup'

alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias mkdir='mkdir -p'
alias rm='rm -rf'

alias ls='ls --color=auto -AFhl --group-directories-first'
alias l='ls'
alias lss="ls | grep '^d' --color=never ; ls | grep '^l' --color=never ; ls | grep '^-' --color=never"

alias tree='tree --dirsfirst'

alias sqlite='sqlite3'
alias dotnet='TERM=xterm dotnet'

alias d='gio trash'
