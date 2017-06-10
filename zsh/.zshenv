#!/usr/bin/env bash

export VDPAU_DRIVER="radeonsi"
export LIBVA_DRIVER_NAME="radeonsi"
export PATH=$HOME/.local/bin:$PATH
export LANG=en_US.UTF-8
export EDITOR=`which vim`
export VISUAL=`which vim`
export PAGER=`which less`

export GNUPGHOME=$HOME/.config/gnupg
export ICEAUTHORITY=$HOME/.cache/ICEauthority
export LESSHISTFILE=$HOME/.cache/less/less_history
export LESSKEY=$HOME/.cache/less/key
export MAILCHECK=0
export RANGER_LOAD_DEFAULT_RC=false
export VIMINIT='let $MYVIMRC="$HOME/.config/vim/vimrc" | source $MYVIMRC'
export VIMDOTDIR=$HOME/.config/vim
export XAUTHORITY=$HOME/.cache/Xauthority

if [ -n "$DISPLAY" ]; then
    export BROWSER=`which google-chrome-beta`
else
    export BROWSER=`which elinks`
fi


# TTY Color Scheme
#if [ "$TERM" = "linux" ]; then
#    echo -en "\e]P0232323" #black
#    echo -en "\e]P82B2B2B" #darkgrey
#    echo -en "\e]P1D75F5F" #darkred
#    echo -en "\e]P9E33636" #red
#    echo -en "\e]P287AF5F" #darkgreen
#    echo -en "\e]PA98E34D" #green
#    echo -en "\e]P3D7AF87" #brown
#    echo -en "\e]PBFFD75F" #yellow
#    echo -en "\e]P48787AF" #darkblue
#    echo -en "\e]PC7373C9" #blue
#    echo -en "\e]P5BD53A5" #darkmagenta
#    echo -en "\e]PDD633B2" #magenta
#    echo -en "\e]P65FAFAF" #darkcyan
#    echo -en "\e]PE44C9C9" #cyan
#    echo -en "\e]P7E5E5E5" #lightgrey
#    echo -en "\e]PFFFFFFF" #white
#    clear #for background artifacting
#fi
