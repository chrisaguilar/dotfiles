#!/usr/bin/env bash

# Install the base system
pacstrap /mnt base base-devel

# Generate the fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into the new system
arch-chroot /mnt
