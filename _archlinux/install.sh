#!/usr/bin/env bash

set -e

Bold=$(tput bold)
Reset=$(tput sgr0)
Green=$(tput setaf 2)
BGreen=${Bold}${Green}

arch_chroot() {
    arch-chroot /mnt /bin/bash -c "${1}"
}

echo "Please make sure you've partitioned and mounted all drives before continuing."
read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n\n'

read -p "Root Partition (e.g. sda2): " BOOT_MOUNTPOINT

pacman -Sy

echo "${BGreen}Set the Keymap${Reset}"
loadkeys us

echo "${BGreen}Sync the Clock${Reset}"
timedatectl set-ntp true

echo "${BGreen}Get the Fastest Mirrors${Reset}"
pacman -S --noconfirm reflector
reflector --save /etc/pacman.d/mirrorlist --verbose --sort rate -f 10 -a 6 -p https -c US
pacman -Sy

echo "${BGreen}Install the Base System${Reset}"
pacstrap /mnt base base-devel git stow vim zsh reflector networkmanager

echo "${BGreen}Generate Fstab${Reset}"
genfstab -U /mnt >> /mnt/etc/fstab

echo "${BGreen}Create Swap File${Reset}"
fallocate -l 8G /mnt/var/swapfile
chmod 600 /mnt/var/swapfile
mkswap /mnt/var/swapfile
swapon /mnt/var/swapfile
echo -e "/var/swapfile\tnone\tswap\tdefaults\t0\t0" >> /mnt/etc/fstab

echo "${BGreen}Set the Timezone${Reset}"
arch_chroot "ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime"
arch_chroot "sed -i '/#NTP=/d' /etc/systemd/timesyncd.conf"
arch_chroot "sed -i 's/#Fallback//' /etc/systemd/timesyncd.conf"
arch_chroot "echo \"FallbackNTP=0.pool.ntp.org 1.pool.ntp.org 0.fr.pool.ntp.org\" >> /etc/systemd/timesyncd.conf"

echo "${BGreen}Sync the Hardware Clock${Reset}"
arch_chroot "hwclock --systohc --utc"

echo "${BGreen}Set the Locale${Reset}"
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf
sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /mnt/etc/locale.gen
arch_chroot "locale-gen"

echo "${BGreen}Set the Keymap${Reset}"
echo "KEYMAP=us" > /mnt/etc/vconsole.conf

echo "${BGreen}Set the Hostname${Reset}"
echo "chris" >> /mnt/etc/hostname
sed -i.bak -r -e "s/# End of file/127.0.1.1\tchris.localdomain\tchris/" /mnt/etc/hosts

echo "${BGreen}Enable Networking${Reset}"
arch_chroot "systemctl enable NetworkManager"

echo "${BGreen}Initramfs${Reset}"
arch_chroot "mkinitcpio -p linux"

echo "${BGreen}Install & Configure Bootloader${Reset}"
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

echo "${BGreen}Set the Root Password${Reset}"
arch_chroot "passwd"

echo "${BGreen}Finish${Reset}"
umount -R /mnt
reboot
