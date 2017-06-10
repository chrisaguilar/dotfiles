autoload -Uz vcs_info
precmd() { vcs_info }

# Enable git Repositories
zstyle ':vcs_info:*' enable git

zstyle ':vcs_info:*' formats ' [%F{yellow}%r%f@%F{green}%b%f%c%u]'
zstyle ':vcs_info:*' actionformats ' [%F{yellow}%r%f@%F{green}%b%f%c%u:$F{red}%a%f]'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '|%F{blue}S%f'
zstyle ':vcs_info:*' unstagedstr '|%F{magenta}U%f'
