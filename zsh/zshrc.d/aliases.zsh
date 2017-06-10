# Aliases
alias c='printf "\033c"'
alias clear='c'
alias e='exit'

alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias mkdir='mkdir -p'
alias rm='rm -rf'

alias ls='ls --color=auto -AFhL --group-directories-first'
alias l='ls -l'
alias ll='ls -1'
alias lgg='l -Gg'

alias tree='tree --dirsfirst'

alias npmexec='PATH=`npm bin`:$PATH'
alias tm='tmux'
alias sqlite='sqlite3'

# NPM Aliases (for executing various npm scripts from the command line)
alias tsc='npmexec tsc'
