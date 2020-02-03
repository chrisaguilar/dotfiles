#!/usr/bin/env bash

set -e

__dirname="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. "${__dirname}/util.sh"

mkdir "${__dirname}/.backup"

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
usr "yay -S --noconfirm --needed acpi_call ark bash-completion bluez-utils capitaine-cursors dolphin dolphin-plugins dotnet-sdk dotnet-runtime ffmpegthumbs google-chrome gpmdp gwenview htop icaclient intel-undervolt jetbrains-toolbox jre{,11,10,8,7}-openjdk-headless jre{,11,10,8,7}-openjdk kdegraphics-mobipocket kdegraphics-thumbnailers kdialog keditbookmarks konsole kwalletmanager libappindicator-gtk{2,3} libva-intel-driver libva-vdpau-driver libvdpau-va-gl lrzip lzop mesa mlocate moreutils nodejs noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra npm okular openjdk{,11,10,8,7}-doc openjdk{,11,10,8,7}-src openssh otf-fira-code otf-fira-mono p7zip pkgstats plasma python rsync slack-desktop smartmontools spectacle spotify tlp tlp-rdw tree ttf-liberation unace unarchiver unrar unzip visual-studio-code-bin vulkan-icd-loader vulkan-intel wget xf86-video-intel zip zsh-autosuggestions zsh-completions zsh-doc zsh-syntax-highlighting"
usr "yay -Rus --noconfirm $(yay -Qtdq) drkonqi khotkeys kinfocenter knetattach ksshaskpass kwrited milou plasma-thunderbolt plasma-vault"

# Link Font Configurations
ln -sf /etc/fonts/conf.avail/10-{hinting-slight,sub-pixel-rgb}.conf /etc/fonts/conf.d/
ln -sf /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
ln -sf /etc/fonts/conf.avail/66-noto-{color-emoji,mono,sans,serif}.conf /etc/fonts/conf.d/

# Copy Config Files
for f in `find {etc,usr} -type f`; do
    copy_config_file $f
done

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
    "fstrim.timer"
    "sddm.service"
    "intel-undervolt.service"
    "pkgstats.timer"
    "sshd.service"
)
for service in ${services[@]}; do
    systemctl enable $service
done

# Create Initial Ramdisk
mkinitcpio -P

reboot
