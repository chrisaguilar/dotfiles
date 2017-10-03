autoload -Uz vcs_info

# Enable git Repositories
zstyle ':vcs_info:*' enable git
# zstyle ':vcs_info:*' formats ' (%F{yellow}%r%f@%F{green}%b%f%c%u) '
zstyle ':vcs_info:*' formats ' (%B%F{green}%b%f%c%u%%b) '
# zstyle ':vcs_info:*' actionformats '(%F{yellow}%r%f@%F{green}%b%f%c%u:%F{red}%a%f)'
zstyle ':vcs_info:*' actionformats '(%B%F{green}%b%f%c%u:%F{red}%a%f%%b)'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '%F{yellow}*%f'
zstyle ':vcs_info:*' unstagedstr '%F{magenta}*%f'


# Python Virtual Environment Information
function pyvenv_info {
    [ -n "$VIRTUAL_ENV" ] && venv_info="%B%F{blue}($(basename $VIRTUAL_ENV))%f%b"
}

precmd() {
    vcs_info
    pyvenv_info

    info="[%n@%m:%B%F{cyan}%3~%f%b]"
    state="%B%F{%(?.green.red)}➜%f%b"

    PROMPT=$'\n${info}${vcs_info_msg_0_:-" "}${state} '

    RPROMPT=$'${venv_info}'
}
