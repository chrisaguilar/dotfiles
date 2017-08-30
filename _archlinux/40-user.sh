#!/usr/bin/env bash

# Pacaur setup
gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53
git clone https://aur.archlinux.org/cower.git
git clone https://aur.archlinux.org/pacaur.git
cd cower && makepkg -sci
cd ../pacaur && makepkg -sci
cd ..
rm -rf cower pacaur

# Install dotfiles
./_install/dots.sh

# Fonts
pacaur -S --noconfirm --needed noto-fonts{,-{cjk,emoji}} otf-fira-mono ttf-dejavu
pacaur -S --noconfirm --needed otf-fira-code ttf-font-awesome

# Font configuration for better looking text
sudo ln -s /etc/fonts/conf.avail/10-{hintint-slight,sub-pixel-rgb}.conf /etc/fonts/conf.d/
sudo ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
sudo ln -s /etc/fonts/conf.avail/66-noto-{mono,sans,serif}.conf /etc/fonts/conf.d/

sudo sed -i.bak -r -e's/# ?export/export/' /etc/profile.d/freetype2.sh

# Remove monochromatic Noto Emoji fonts
sudo updatedb
sudo rm /usr/share/fonts/noto/NotoEmoji-regular.ttf
sudo fc-cache -fv

sudo sensors-detect --auto

# Window manager setup
pacaur -S --noconfirm --needed \
    compton \
    dunst-git \
    feh \
    gnome-keyring \
    gnome-themes-standard \
    i3-wm \
    numix-circle-icon-theme-git \
    numlockx \
    polkit-gnome \
    polybar-git \
    redshift \
    rofi \
    scrot \
    termite \
    xdotool

# Programming stuff
pacaur -S --noconfirm --needed \
    nodejs \
    npm \
    openssh \
    python \
    visual-studio-code

# Media/Misc
pacaur -S --noconfirm --needed \
    alsa-utils \
    calibre \
    cmus \
    google-chrome \
    mpv \
    plex-media-server \
    pavucontrol \
    pulseaudio \
    skypeforlinux-bin

# Known optional deps (may be more, update as necessary)
pacaur -S --noconfirm --needed --asdeps \
    alsa-lib \
    alsa-utils \
    faad2 \
    ffmpeg \
    flac \
    geoip \
    geoip-database-extra \
    i3ipc-glib-git \
    jsoncpp \
    libao \
    libcdio-paranoia \
    libmad \
    libmodplug \
    libmp4v2 \
    libmpcdec \
    libpulse \
    libvorbis \
    opusfile \
    pulseaudio-alsa \
    python-gobject \
    python-xdg \
    ttf-liberation \
    wavpack \
    xdg-utils \
    xorg-xprop \
    xorg-xwininfo

reboot
