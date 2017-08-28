#!/usr/bin/env bash

# Finish systemd-resolved setup
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

# Network time synchronization
timedatectl set-ntp true

cat << EOF > /etc/pacman.conf
[options]
HoldPkg      = pacman glibc
Architecture = auto

Color
TotalDownload
CheckSpace
VerbosePkgLists

SigLevel    = Required DatabaseOptional
LocalFileSigLevel = Optional
#[testing]
#Include = /etc/pacman.d/mirrorlist

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

#[community-testing]
#Include = /etc/pacman.d/mirrorlist

[community]
Include = /etc/pacman.d/mirrorlist

#[multilib-testing]
#Include = /etc/pacman.d/mirrorlist

#[multilib]
#Include = /etc/pacman.d/mirrorlist
EOF

sed -i.bak -r -e's/# ?export/export/' /etc/profile.d/freetype2.sh

# Make compilation better
sed -i.bak -r -e's/CFLAGS=.*$/CFLAGS="-march=native -O2 -pipe -fstack-protector-strong -fno-plt"/' /etc/makepkg.conf
sed -i -r -e's/CXXFLAGS=.*$/CXXFLAGS="${CFLAGS}"/' /etc/makepkg.conf
sed -i -r -e's/# ?MAKEFLAGS=.*$/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf
sed -i -r -e's/# ?BUILDDIR/BUILDDIR/' /etc/makepkg.conf
sed -i -r -e"s/# ?PKGEXT=.*$/PKGEXT='.pkg.tar'/" /etc/makepkg.conf

# Change $ZDOTDIR to $HOME/.config/zsh
mkdir -p /etc/zsh
echo 'export ZDOTDIR=$HOME/.config/zsh' > /etc/zsh/zshenv

# Blacklist some kernel modules
echo -e "blacklist radeon\nblacklist sp5100_tco" > /etc/modprobe.d/blacklist.conf

# Xorg configuration for amdgpu
mkdir -p /etc/X11/xorg.conf.d
cat << EOF > /etc/X11/xorg.conf.d/20-amdgpu.conf
Section "Device"
    Identifier "AMD"
    Driver "amdgpu"
    Option "DRI" "3"
    Option "TearFree" "true"
EndSection
EOF

# Faster pacman downloads
pacman -Syu --noconfirm reflector
reflector --save /etc/pacman.d/mirrorlist --verbose --sort rate -f 25 -a 6 -p http -p https

# The basics
pacman -Syu --noconfirm --needed git vim mlocate pkgstats stow tree zsh zsh-syntax-highlighting

# Required for graphics
pacman -Syu --noconfirm --needed \
    xorg-server \
    xorg-xinit \
    xf86-video-amdgpu \
    libvdpau-va-gl  \
    libva-mesa-driver \
    libva-vdpau-driver \
    mesa-vdpau \
    vulkan-radeon \
    vulkan-icd-loader \

# Add user chris and set password
useradd -m -G wheel -s /usr/bin/zsh chris
passwd chris

# Edit sudoers file
visudo

# Enable periodic trim for SSD
systemctl enable fstrim.timer

# Silence fsck messages
sed -i.bak -r -e's/HOOKS=.*$/HOOKS="base udev autodetect modconf block filesystems keyboard"/' /etc/mkinitcpio.conf
mkinitcpio -p linux

cp /usr/lib/systemd/system/systemd-fsck{@,-root}.service /etc/systemd/system/

echo -e "StandardOutput=null\nStandardError=journal+console" >> /etc/systemd/system/systemd-fsck{@,-root}.service

# Autologin for user chris
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat << EOF > /etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin chris --noclear %I $TERM
EOF

sensors detect

reboot
