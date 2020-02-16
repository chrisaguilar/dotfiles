#!/usr/bin/env bash

set -e

__dirname="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. "${__dirname}/util.sh"

printf "\033c"

sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sda
        g # Create a new GPT partition table
        n # New partition
          # Partition number - accept default (1)
          # First sector - accept default (2048)
    +100M # Last sector (boot partition will be 100M)
        n # New partition
          # Partition number - accept default (2)
          # First sector - accept default (where the boot partition ends)
          # Last sector - accept default (rest of space)
        t # Change partition type
        1 # Select partition 1
        1 # Set partition to type "EFI System"
        t # Change partition type
        2 # Select partition 2
       20 # Set partition type to "Linux filesystem"
        w # Write the partiion table and quit
EOF

# Create the filesystems
mkfs.vfat /dev/sda1
mkfs.ext4 /dev/sda2

# Mount the partitions
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

# Startup
pacman -Sy
loadkeys us
timedatectl set-ntp true

# Base System
pacman -S --noconfirm reflector
reflector --save /etc/pacman.d/mirrorlist --sort rate -f 10 -a 6 -p https -c US
pacman -Sy
pacstrap /mnt base base-devel git linux linux-firmware linux-tools man-db man-pages networkmanager reflector texinfo vim zsh virtualbox-guest-utils xf86-video-vmware virtualbox-guest-modules-arch

# Fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Swapfile
mem_total=$(free -h | grep Mem | awk '{printf "%d", $2}')
swap_total="$((${mem_total} / 2))"
fallocate -l "${swap_total}G" /mnt/swapfile
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
arch_chroot "systemctl enable NetworkManager.service"
arch_chroot "systemctl enable vboxservice.service"

# Install systemd-boot
root_partuuid=$(basename `find /dev/disk/by-partuuid/ -type l -ilname "*sda2*"`)
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
