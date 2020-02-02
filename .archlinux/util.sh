#!/usr/bin/env bash

Blue=$(tput setaf 4)
Bold=$(tput bold)
Green=$(tput setaf 2)
Red=$(tput setaf 1)
Reset=$(tput sgr0)
Yellow=$(tput setaf 3)
BBlue=${Bold}${Blue}
BGreen=${Bold}${Green}
BRed=${Bold}${Red}
BYellow=${Bold}${Yellow}

arch_chroot() {
    arch-chroot /mnt /bin/bash -c "${1}"
}

copy_config_file() {
    mkdir -p "/$(dirname ${1})"

    if [[ -f "/${1}" ]]; then
        mkdir -p "${__dirname}/.backup/$(dirname ${1})"
        cat "/${1}" >> "${__dirname}/.backup/${1}"
    fi

    cat "${1}" > "/${1}"
}

usr() {
    su - chris -c "${1}"
}
