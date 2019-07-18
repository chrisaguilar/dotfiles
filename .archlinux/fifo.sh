#!/usr/bin/env bash

set -e

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. "${dir}/util.sh"

echo "${BRed}Please make sure you've partitioned and mounted all drives before continuing.${Reset}"

lsblk

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
pacstrap /mnt base base-devel git stow vim zsh reflector networkmanager intel-ucode


title "Generate Fstab"
genfstab -U /mnt >> /mnt/etc/fstab


title "Create Swap File"
mem_total=$(free -h | grep Mem | awk '{printf "%d", $2}')
swap_total="$((${mem_total} / 2))"
fallocate -l "${swap_total}G" /mnt/swapfile
chmod 600 /mnt/swapfile
mkswap /mnt/swapfile
swapon /mnt/swapfile
echo -e "/swapfile\tnone\tswap\tdefaults\t0\t0" >> /mnt/etc/fstab


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
initrd   /intel-ucode.img
initrd   /initramfs-linux.img
options  root=PARTUUID=$root_partuuid rw quiet loglevel=3 udev.log-priority=3 i915.enable_guc=2 i915.fastboot=1 i915.enable_fbc=1
EOF


title "Set the Root Password"
arch_chroot "echo \"root:a\" | chpasswd"


title "Finish"
cp -R /root/dotfiles /mnt/root
sync
swapoff -a
umount -R /mnt
reboot
