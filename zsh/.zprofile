emulate sh -c 'source /etc/profile'

export PATH=$HOME/.npm-global/bin:$PATH

if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
    exec startx $HOME/.config/X/initrc -- -keeptty -nolisten tcp > $HOME/.cache/xorg.log 2>&1
fi

