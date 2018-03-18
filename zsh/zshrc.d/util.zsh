#!/usr/bin/env bash

# Activate Python virtualenv
activate() {
    VIRTUAL_ENV_DISABLE_PROMPT='1' source ./env/bin/activate
}

# Clone All Public Repos
capr() {
    start=$(pwd)
    
    [[ -z "${1}" ]] && echo "You must specify a username!" && return 1

    mkdir "${1}" && cd "${1}"

    curl -o "${1}.json" "https://api.github.com/users/${1}/repos" > /dev/null 2>&1

    repos=($(cat "${1}.json" | grep ssh_url | awk -F ":" '{print $2":"$3}' | sed 's/[,"]//g'))

    for repo in ${repos}; do
        echo "Cloning ${repo}"
        git clone "${repo}" &>/dev/null
    done

    rm -rf "${1}.json"

    cd "${start}"
}

# cd && ls
cdl() {
    cd "$@" && ls
}

# Copy to Clipboard
ctcb() {
    cat "$@" | xclip -sel clip
}

# Download Playlist
dlpl() {
    youtube-dl -x -o "%(playlist_index)s-%(title)s.%(ext)s" --audio-format mp3 "$@"
}

# Extract archive
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

# Fix Permissions
fixperms() {
    sudo chown -R `whoami`:`id -g` "$1"
    find "$1" -type d -exec chmod 755 {} \;
    find "$1" -type f -exec chmod 644 {} \;
}

# GET request
get() {
    curl -X GET "$1"
}

# Search google
google() {
    open "https://google.com/search?q=`echo $@ | tr \"[:blank:]\" +`"
}

# Modify `man` to be only 80 characters wide
man() {
    MANWIDTH=80
    local width=$(tput cols)
    [ $width -gt $MANWIDTH ] && width=$MANWIDTH

    env MANWIDTH=$width man "$@"
}

# mkdir && cd
mkcd() {
    mkdir -p "$@" && cd "$@"
}

# Run *.sql file in MySQL
mysql-run() {
    mysql --host=localhost --user=root --password=a < "$@"
}

# Emulate `open` command from macOS
open() {
    xdg-open "$@" &>/dev/null &!
}

# Get optional dependencies
opt_deps() {
    expac "%n: %o" "$@" | sort
}

# POST request (JSON-only)
postJSON() {
    curl -H "Content-Type: application/json" -X POST -d $2 $1
}

# Update mirrorlist
reflect() {
    sudo reflector --save /etc/pacman.d/mirrorlist --verbose --sort rate -f 10 -l 20 -p https -c US
}

# Remove all in group except
rge() {
    trizen -Rus $(trizen -Qqg $1 | egrep -v "$(echo ${${@:2}[@]}|tr " " "|")")
}

# Remove metadata from media file
remove_metadata() {
    ffmpeg -i "$1" -map_metadata -1 -c:v copy -c:a copy "$2"
}

# Parses JSON using Node.js
parseJSON() {
    node -e "
        const { inspect } = require('util');

        const json = JSON.parse('$(cat ${1})');

        console.log(inspect(json, { depth: null, colors: true }));
    "
}

# What do I have installed?
wdihi() {
    expac -HM '%011m\t%-20n' $(comm -23 <(pacman -Qqe | sort) <(pacman -Qqg base base-devel $@ | sort)) | sort -rn
}
