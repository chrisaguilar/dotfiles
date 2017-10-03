#!/usr/bin/env bash

set -e

Bold=$(tput bold)
Reset=$(tput sgr0)
Red=$(tput setaf 1)
Green=$(tput setaf 2)
Yellow=$(tput setaf 3)
BRed=${Bold}${Red}
BGreen=${Bold}${Green}
BYellow=${Bold}${Yellow}

LOG=/var/log/installation.log

package_install() {
    read -a pkgs <<< "${1}"
    for pkg in ${pkgs[@]}; do
        echo "${BYellow}Installing ${pkg}${Reset}"
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
        echo "${BYellow}Uninstalling ${pkg}${Reset}"
        pacman -Rus --noconfirm ${pkg} >> "${LOG}" 2>&1
    done
}

title() {
    echo "${BGreen}${1}${Reset}"
}

arch_chroot() {
    arch-chroot /mnt /bin/bash -c "${1}"
}


echo "${BRed}Please make sure you've partitioned and mounted all drives before continuing.${Reset}"


read -p "Root Partition (e.g. sda2): " BOOT_MOUNTPOINT


title "Sync with Servers"
pacman -Sy >> "${LOG}" 2>&1


title "Set the Keymap"
loadkeys us


title "Sync the Clock"
timedatectl set-ntp true


title "Get the Fastest Mirrors"
package_install "reflector"
reflector --save /etc/pacman.d/mirrorlist --sort rate -f 10 -a 6 -p https -c US
pacman -Sy >> "${LOG}" 2>&1


title "Install the Base System"
pacstrap /mnt base base-devel git stow vim zsh reflector networkmanager


title "Generate Fstab"
genfstab -U /mnt >> /mnt/etc/fstab


title "Create Swap File"
fallocate -l 8G /mnt/var/swapfile
chmod 600 /mnt/var/swapfile
mkswap /mnt/var/swapfile
swapon /mnt/var/swapfile
echo -e "/var/swapfile\tnone\tswap\tdefaults\t0\t0" >> /mnt/etc/fstab


title "Set the Timezone"
arch_chroot "ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime"
arch_chroot "sed -i '/#NTP=/d' /etc/systemd/timesyncd.conf"
arch_chroot "sed -i 's/#Fallback//' /etc/systemd/timesyncd.conf"
arch_chroot "echo \"FallbackNTP=0.pool.ntp.org 1.pool.ntp.org 0.fr.pool.ntp.org\" >> /etc/systemd/timesyncd.conf"


title "Sync the Hardware Clock"
arch_chroot "hwclock --systohc --utc"


title "Set the Locale"
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf
sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /mnt/etc/locale.gen
arch_chroot "locale-gen"


title "Set the Keymap"
echo -e "FONT=sun12x22\nKEYMAP=us" > /mnt/etc/vconsole.conf


title "Set the Hostname"
echo "chris" >> /mnt/etc/hostname
sed -i.bak -r -e "s/# End of file/127.0.1.1\tchris.localdomain\tchris/" /mnt/etc/hosts


title "Enable Networking"
arch_chroot "systemctl enable NetworkManager >> ${LOG} 2>&1"


title "Initramfs"
arch_chroot "mkinitcpio -p linux"


title "Install & Configure Bootloader"

root_partuuid=$(basename `find /dev/disk/by-partuuid/ -type l -ilname "*${BOOT_MOUNTPOINT}*"`)
arch_chroot "bootctl install"

cat << EOF > /mnt/boot/loader/loader.conf
timeout 0
default arch
EOF

cat << EOF > /mnt/boot/loader/entries/arch.conf
title    Arch Linux
linux    /vmlinuz-linux
initrd   /initramfs-linux.img
options  root=PARTUUID=$root_partuuid rw quiet loglevel=3 udev.log-priority=3
EOF


title "Set the Root Password"
arch_chroot "passwd"


title "Finish"
cp -R /root/dotfiles /mnt/root
sync
swapoff -a
umount -R /mnt
reboot
