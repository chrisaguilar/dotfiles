#!/usr/bin/env bash

set -e

Bold=$(tput bold)
Reset=$(tput sgr0)
Green=$(tput setaf 2)
BGreen=${Bold}${Green}

arch_chroot() {
    arch-chroot /mnt /bin/bash -c "${1}"
}

package_install() {
    pacman -S --noconfirm --needed ${1} >> /tmp/installation.log 2>&1
}

title() {
    echo "${BGreen}${1}${Reset}"
}


echo "Please make sure you've partitioned and mounted all drives before continuing."
read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...'

read -p "Root Partition (e.g. sda2): " BOOT_MOUNTPOINT


title "Sync with Servers"
pacman -Sy


title "Set the Keymap"
loadkeys us


title "Sync the Clock"
timedatectl set-ntp true


title "Get the Fastest Mirrors"
package_install "reflector"
reflector --save /etc/pacman.d/mirrorlist --verbose --sort rate -f 10 -a 6 -p https -c US
pacman -Sy


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
echo "KEYMAP=us" > /mnt/etc/vconsole.conf


title "Set the Hostname"
echo "chris" >> /mnt/etc/hostname
sed -i.bak -r -e "s/# End of file/127.0.1.1\tchris.localdomain\tchris/" /mnt/etc/hosts


title "Enable Networking"
arch_chroot "systemctl enable NetworkManager"


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
options  root=PARTUUID=$root_partuuid rw quiet loglevel=3 udev.log-priority=3 radeon.si_support=0 radeon.cik_support=0 amdgpu.si_support=1 amdgpu.cik_support=1
EOF


title "Set the Root Password"
arch_chroot "passwd"


title "Finish"
sync
swapoff -a
umount -R /mnt
reboot
