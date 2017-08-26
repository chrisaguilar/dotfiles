autoload -Uz vcs_info

# Enable git Repositories
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' formats '(%F{yellow}%r%f@%F{green}%b%f%c%u)'
zstyle ':vcs_info:*' actionformats '(%F{yellow}%r%f@%F{green}%b%f%c%u:$F{red}%a%f)'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '|%F{blue}S%f'
zstyle ':vcs_info:*' unstagedstr '|%F{magenta}U%f'


# Python Virtual Environment Information
function venv_info {
    [ -n "$VIRTUAL_ENV" ] && echo "%B%F{blue}($(basename $VIRTUAL_ENV))%f%b"
}

precmd() {
    vcs_info
    user_info="[%n@%m]"
    current_dir="%F{cyan}%1~%f"
    state="%F{%(?.green.red)}➜%f "

    if [ -n "$vcs_info_msg_0_" ]; then
        PROMPT=$'\n${user_info} %B${current_dir} ${vcs_info_msg_0_} ${state}%b '
    else
        PROMPT=$'\n${user_info} %B${current_dir} ${state}%b'
    fi

    RPROMPT="$(venv_info)"
}
