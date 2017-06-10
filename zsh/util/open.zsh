function open() {
    emulate -L zsh
    setopt shwordsplit
    nohup xdg-open "$@" &>/dev/null
}
