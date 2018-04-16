emulate sh -c 'source /etc/profile'

if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
    startx $HOME/.config/X11/initrc -- -keeptty -nolisten tcp > $HOME/.cache/xorg.log 2>&1
fi
