#!/usr/bin/env bash

activate() {
    VIRTUAL_ENV_DISABLE_PROMPT='1' source ./env/bin/activate
}

cdl() {
    cd "$@" && ls
}

dlpl() {
    youtube-dl -x -o "%(playlist_index)s-%(title)s.%(ext)s" --audio-format mp3 "$@"
}

extract() {
    local c e i

    (($#)) || return

    for i; do
        c=''
        e=1

        if [[ ! -r $i ]]; then
            echo "$0: file is unreadable: '$i'" >&2
            continue
        fi

        case $i in
            *.t@(gz|lz|xz|b@(2|z?(2))|a@(z|r?(.@(Z|bz?(2)|gz|lzma|xz)))))
                    c=(bsdtar xvf);;
            *.7z)   c=(7z x);;
            *.Z)    c=(uncompress);;
            *.bz2)  c=(bunzip2);;
            *.exe)  c=(cabextract);;
            *.gz)   c=(gunzip);;
            *.rar)  c=(unrar x);;
            *.xz)   c=(unxz);;
            *.zip)  c=(unzip);;
            *)      echo "$0: unrecognized file extension: \`$i'" >&2
                    continue;;
        esac

        command "${c[@]}" "$i"
        ((e = e || $?))
    done
    return "$e"
}

fixperms() {
    sudo chown -R `whoami`:`id -g` "$1"
    find "$1" -type d -exec chmod 755 {} \;
    find "$1" -type f -exec chmod 644 {} \;
}

get() {
    curl -X GET "$1"
}

google() {
    open "https://google.com/search?q=`echo $@ | tr \"[:blank:]\" +`"
}

man() {
    MANWIDTH=80
    local width=$(tput cols)
    [ $width -gt $MANWIDTH ] && width=$MANWIDTH

    env MANWIDTH=$width man "$@"
}

mcd() {
    mkdir -p $@ && cd $@
}

open() {
    xdg-open "$@" &>/dev/null &!
}

opt_deps() {
    expac "%n: %o" "$@" | sort
}

postJSON() {
    curl -H "Content-Type: application/json" -X POST -d $2 $1
}

reflect() {
    sudo reflector --save /etc/pacman.d/mirrorlist --verbose --sort rate -f 10 -l 20 -p https -c US
}

rge() {
    pacaur -Rus $(pacaur -Qqg $1 | egrep -v "$(echo ${${@:2}[@]}|tr " " "|")")
}

remove_metadata() {
    ffmpeg -i "$1" -map_metadata -1 -c:v copy -c:a copy "$2"
}

wdihi() {
    expac -HM '%011m\t%-20n' $(comm -23 <(pacman -Qqe | sort) <(pacman -Qqg base base-devel $@ | sort)) | sort -rn
}
