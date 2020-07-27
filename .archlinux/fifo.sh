#!/usr/bin/env bash

set -e

__dirname="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. "${__dirname}/util.sh"

printf "\033c"

echo "${BRed}Please make sure you've partitioned and mounted all drives before continuing.${Reset}"

lsblk

read -p "Root Partition (e.g. sda2): " BOOT_MOUNTPOINT

# Startup
pacman -Sy
loadkeys us
timedatectl set-ntp true

# Base System
pacman -S --noconfirm reflector
reflector --save /etc/pacman.d/mirrorlist --sort rate -f 10 -a 6 -p https -c US
pacman -Sy
pacstrap /mnt base base-devel git intel-ucode linux linux-firmware linux-tools man-db man-pages networkmanager reflector vim zsh

# Fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Swapfile
mem_total=$(free -h | grep Mem | awk '{printf "%d", $2}')
swap_total="$((${mem_total} / 2 * 1024))"
dd if=/dev/zero of=/mnt/swapfile bs=1M count=${swap_total} status=progress
chmod 600 /mnt/swapfile
mkswap /mnt/swapfile
swapon /mnt/swapfile
echo -e "/swapfile\tnone\tswap\tdefaults\t0\t0" >> /mnt/etc/fstab

# Copy Config Files
files=(
    "hostname"
    "hosts"
    "locale.conf"
    "locale.gen"
    "vconsole.conf"
)
for f in ${files[@]}; do
    cat "${__dirname}/etc/${f}" > "/mnt/etc/${f}"
done

# Run General Setup Commands
arch_chroot "ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime"
arch_chroot "hwclock --systohc --utc"
arch_chroot "locale-gen"
arch_chroot "systemctl enable NetworkManager"

# Install systemd-boot
root_partuuid=$(basename `find /dev/disk/by-partuuid/ -type l -ilname "*${BOOT_MOUNTPOINT}*"`)
arch_chroot "bootctl install"
cat "${__dirname}/boot/loader/loader.conf" > /mnt/boot/loader/loader.conf
cat "${__dirname}/boot/loader/entries/arch.conf" > /mnt/boot/loader/entries/arch.conf
sed -i "s/root_partuuid/${root_partuuid}/g" /mnt/boot/loader/entries/arch.conf

# Set Root Password
arch_chroot "echo \"root:a\" | chpasswd"

# Finalize & Reboot
cp -R /root/dotfiles /mnt/root
sync
swapoff -a
umount -R /mnt
reboot
