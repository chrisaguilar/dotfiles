#!/usr/bin/env bash

set -e

if [[ -z "$1" ]]; then
    echo "Please provide root partition as the first argument (e.g. sda2)"
    exit
fi

# Set the time zone
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

# Generate /etc/adjtime
hwclock --systohc

# Generate the locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

# Set the locale
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set the keymap to us
echo "KEYMAP=us" > /etc/vconsole.conf

# Set the hostname
echo "chris" > /etc/hostname

# Update hosts file
sed -i.bak -r -e"s/# End of file/127.0.1.1\tchris.localdomain\tchris/" /etc/hosts

# Network setup
cat << EOF > /etc/systemd/network/20-wired.network
[Match]
Name=enp1s0

[Network]
DHCP=yes

[DHCP]
UseDomains=true
EOF

systemctl enable systemd-{network,resolve}d

# Create the initramfs
mkinitcpio -p linux

# Set the root password
passwd

# Configure the boot loader
bootctl install

cat << EOF > /boot/loader/loader.conf
timeout 0
default arch
EOF

root_partition=$(basename `find /dev/disk/by-partuuid/ -type l -ilname "*$1*"`)
cat << EOF > /boot/loader/entries/arch.conf
title    Arch Linux
linux    /vmlinuz-linux
initrd   /initramfs-linux.img
options  root=PARTUUID=$root_partition rw quiet loglevel=3 udev.log-priority=3
EOF

echo "exit, unmount, and reboot"
