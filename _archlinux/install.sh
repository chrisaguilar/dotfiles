#!/usr/bin/env bash

set -e

arch_chroot() {
    arch-chroot /mnt /bin/bash -c "${1}"
}

echo "Please make sure you've partitioned and mounted all drives before continuing."
read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n\n'

read -p "Root Partition: " BOOT_MOUNTPOINT

pacman -Sy

# Keymap
loadkeys us

# Sync the Clock
timedatectl set-ntp true

# Mirrorlist
pacman -Sy --noconfirm reflector
reflector --save /etc/pacman.d/mirrorlist --verbose --sort rate -f 10 -a 6 -p https -c US

# Install Base System
pacstrap /mnt base base-devel

# Generate Fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Create Swap File
fallocate -l 8G /mnt/var/swapfile
chmod 600 /mnt/var/swapfile
mkswap /mnt/var/swapfile
swapon /mnt/var/swapfile
echo -e "/var/swapfile\tnone\tswap\tdefaults\t0\t0" >> /mnt/etc/fstab

# Timezone
arch_chroot "ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime"
arch_chroot "sed -i '/#NTP=/d' /etc/systemd/timesyncd.conf"
arch_chroot "sed -i 's/#Fallback//' /etc/systemd/timesyncd.conf"
arch_chroot "echo \"FallbackNTP=0.pool.ntp.org 1.pool.ntp.org 0.fr.pool.ntp.org\" >> /etc/systemd/timesyncd.conf"
arch_chroot "timedatectl set-ntp true "

# Hardware Clock
arch_chroot "hwclock --systohc --utc"

# Locale
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf
sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /mnt/etc/locale.gen
arch_chroot "locale-gen"

# Keymap
echo "KEYMAP=en_US.UTF-8" > /mnt/etc/vconsole.conf

# Hostname
echo "chris" >> /mnt/etc/hostname
sed -i.bak -r -e "s/# End of file/127.0.1.1\tchris.localdomain\tchris/" /mnt/etc/hosts

# Network
arch_chroot "pacman -Sy --noconfirm networkmanager"
arch_chroot "pacman -Sy --noconfirm --asdeps dnsmasq openresolv dhclient"
arch_chroot "systemctl enable NetworkManager"

# Initramfs
arch_chroot "mkinitcpio -p linux"

# Install & Configure Bootloader
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
options  root=PARTUUID=$root_partition rw quiet loglevel=3 udev.log-priority=3
EOF

# Root Password
arch_chroot "passwd"

# Finish
umount -R /mnt
reboot
