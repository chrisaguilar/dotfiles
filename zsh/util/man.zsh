function man() {
  MANWIDTH=80
  local width=$(tput cols)
  [ $width -gt $MANWIDTH ] && width=$MANWIDTH

  env MANWIDTH=$width man "$@"
}
