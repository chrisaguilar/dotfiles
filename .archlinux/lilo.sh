#!/usr/bin/env bash

set -e

__dirname="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. "${__dirname}/util.sh"

mkdir -p "${__dirname}/.backup"

# Pacman Setup
copy_config_file "etc/pacman.conf"
copy_config_file "etc/makepkg.conf"
copy_config_file "etc/sudoers"
pacman -S --noconfirm haveged
haveged -w 1024
pacman-key --init
pacman-key --populate archlinux
pkill haveged
pacman -Rus --noconfirm haveged
reflector --save /etc/pacman.d/mirrorlist --sort rate -f 10 -a 6 -p https -c US
pacman -Sy

# User Setup
useradd -m -G wheel -s /usr/bin/zsh chris
echo "chris:a" | chpasswd
usr "git clone https://github.com/chrisaguilar/dotfiles.git /home/chris/.config"
usr "rm -rf /home/chris/.bash*"
usr "mkdir -p /home/chris/media/{documents,downloads,music,pictures,video}"

# Yay Setup
usr "git clone https://aur.archlinux.org/yay.git /home/chris/yay"
usr "cd /home/chris/yay && yes | makepkg -sci"
usr "rm -rf /home/chris/yay"

# Packages
REQUIRED_PACKAGES="\
    capitaine-cursors google-chrome icaclient intel-undervolt jetbrains-toolbox slack-desktop visual-studio-code-bin \
    nodejs npm \
    noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra otf-fira-code otf-fira-mono \
    chrome-gnome-shell dconf-editor eog evince file-roller gdm gnome-backgrounds gnome-keyring gnome-menus gnome-screenshot gnome-system-monitor gnome-tweaks nautilus xdg-user-dirs-gtk \
    bumblebee libva-intel-driver libva-vdpau-driver libvdpau-va-gl vulkan-icd-loader vulkan-intel xf86-video-intel \
    tlp tlp-rdw \
    bluez-utils htop mlocate moreutils openssh pkgstats rsync termite tree wget \
    zsh-autosuggestions zsh-completions zsh-doc zsh-syntax-highlighting \
"

OPTIONAL_PACKAGES="\
    bash-completion \
    bbswitch nvidia \
    eog-plugins \
    p7zip unrar unace lrzip \
    gnome-control-center \
    ttf-liberation \
    nvidia-settings \
    acpi_call smartmontools \
"

usr "yay -S --noconfirm --needed ${REQUIRED_PACKAGES[@]}"
usr "yay -S --noconfirm --needed --asdeps ${OPTIONAL_PACKAGES[@]}"

# Link Font Configurations
ln -sf /etc/fonts/conf.avail/10-{hinting-slight,sub-pixel-rgb}.conf /etc/fonts/conf.d/
ln -sf /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
ln -sf /etc/fonts/conf.avail/66-noto-{color-emoji,mono,sans,serif}.conf /etc/fonts/conf.d/

# Copy Config Files
for f in `find {etc,usr} -type f`; do
    copy_config_file $f
done

# for f in `find home -type f`; do
#     usr "ln -sf '$(pwd)/$f' $HOME"
# done

# Citrix Workspace App Setup
usr "mkdir -p /home/chris/.ICAClient/cache"
usr "cp /opt/Citrix/ICAClient/config/{All_Regions,Trusted_Region,Unknown_Region,canonicalization,regions}.ini /home/chris/.ICAClient/"

# Update mlocate DB
updatedb

# Detect Sensors
sensors-detect --auto

# Set Time
timedatectl set-ntp true

# Enable Services
services=(
    "bluetooth.service"
    "bumblebeed.service"
    "fstrim.timer"
    "gdm.service"
    "intel-undervolt.service"
    "pkgstats.timer"
    "sshd.service"
    "tlp.service"
)
for service in ${services[@]}; do
    systemctl enable $service
done

# Create Initial Ramdisk
mkinitcpio -P

reboot
