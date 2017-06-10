# Start zsh's help builtin

autoload -Uz run-help
autoload -Uz run-help-git
autoload -Uz run-help-ip
autoload -Uz run-help-openssl
autoload -Uz run-help-p4
autoload -Uz run-help-sudo
autoload -Uz run-help-svk
autoload -Uz run-help-svn

# Nobody wants to type `run-help`
alias help=run-help
unalias run-help 2>/dev/null
