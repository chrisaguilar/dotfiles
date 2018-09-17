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

LOG=/var/log/installation.log

add_to_group() {
    [ $(getent group ${1}) ] || groupadd ${1} >> "${LOG}" 2>&1
    gpasswd -a chris ${1} >> "${LOG}" 2>&1
}

arch_chroot() {
    arch-chroot /mnt /bin/bash -c "${1}"
}

enable_services() {
    read -a services <<< "${1}"
    for service in ${services[@]}; do
        echo "${BYellow}Enabling ${service}${Reset}"
        systemctl enable --now ${service} >> "${LOG}" 2>&1
    done
}

package_install() {
    read -a pkgs <<< "${1}"
    for pkg in ${pkgs[@]}; do
        # echo "${BYellow}Installing ${pkg}${Reset}"
        if [[ "${2}" == "stubborn" ]]; then
            yes | pacman -S --needed ${pkg} >> "${LOG}" 2>&1
        else
            pacman -S --noconfirm --needed ${pkg} >> "${LOG}" 2>&1
        fi
    done
}

package_remove() {
    read -a pkgs <<< "${1}"
    for pkg in ${pkgs[@]}; do
        # echo "${BYellow}Uninstalling ${pkg}${Reset}"
        pacman -Rus --noconfirm ${pkg} >> "${LOG}" 2>&1
    done
}

subtitle() {
    echo -e "\t${BBlue}${1}${Reset}"
}

title() {
    echo "${BGreen}${1}${Reset}"
}

usr() {
    su - chris -c "${1}"
}
