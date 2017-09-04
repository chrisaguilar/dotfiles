#!/usr/bin/env bash

set -e

# Install dotfiles
chmod +x ./_install/dots.sh
./_install/dots.sh

# Pacaur setup
mkdir aur_setup
cd aur_setup
gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53
git clone https://aur.archlinux.org/cower.git
git clone https://aur.archlinux.org/pacaur.git
cd cower && makepkg -sci
cd ../pacaur && makepkg -sci
cd ../../
rm -rf aur_setup

pacaur -S --noconfirm --needed \
    alsa-utils \
    calibre \
    capitaine-cursors \
    compton \
    curl \
    dunst-git \
    feh \
    gnome-keyring \
    google-chrome \
    htop \
    i3-wm \
    libva-mesa-driver \
    libva-vdpau-driver \
    libvdpau-va-gl  \
    mesa-vdpau \
    mlocate \
    nodejs \
    noto-fonts \
    noto-fonts-cjk \
    noto-fonts-emoji \
    npm \
    ntfs-3g \
    numix-circle-icon-theme-git \
    numlockx \
    openssh \
    otf-fira-code \
    otf-fira-mono \
    p7zip \
    pavucontrol \
    pkgstats \
    plex-media-server \
    polkit-gnome \
    polybar-git \
    postgresql \
    pulseaudio \
    pulseaudio-alsa \
    python \
    python-pip \
    redshift \
    rofi \
    scrot \
    skypeforlinux-bin \
    sqlite3 \
    termite \
    transmission-gtk \
    tree \
    ttf-dejavu \
    ttf-font-awesome \
    ttf-liberation \
    visual-studio-code \
    vulkan-icd-loader \
    vulkan-radeon \
    wget \
    xdotool \
    xf86-video-amdgpu \
    xfce-theme-greybird \
    xorg-server \
    xorg-xinit \
    youtube-dl \
    zathura \
    zathura-djvu \
    zathura-pdf-mupdf \
    zsh-syntax-highlighting \

###

pacaur -S --noconfirm --needed --asdeps \
    alsa-lib \
    geoip \
    geoip-database-extra \
    i3ipc-glib-git \
    imagemagick \
    jsoncpp \
    python-gobject \
    python-xdg \
    xdg-utils \
    xorg-xprop \
    xorg-xwininfo

###

# Font configuration for better looking text
sudo ln -sf /etc/fonts/conf.avail/10-{hintint-slight,sub-pixel-rgb}.conf /etc/fonts/conf.d/
sudo ln -sf /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
sudo ln -sf /etc/fonts/conf.avail/66-noto-{mono,sans,serif}.conf /etc/fonts/conf.d/

sudo sed -i.bak -r -e's/# ?export/export/' /etc/profile.d/freetype2.sh

# Remove monochromatic Noto Emoji fonts
sudo rm /usr/share/fonts/noto/NotoEmoji-Regular.ttf
sudo fc-cache -fv

# VSCode extension installation
# from `code --list-extensions`
extensions="
    christian-kohler.path-intellisense
    dbaeumer.vscode-eslint
    donjayamanne.python
    EditorConfig.EditorConfig
    eg2.tslint
    eg2.vscode-npm-script
    esbenp.prettier-vscode
    formulahendry.code-runner
    HookyQR.beautify
    humao.rest-client
    joelday.docthis
    msjsdiag.debugger-for-chrome
    octref.vetur
    robertohuertasm.vscode-icons
    shinnn.stylelint
    zhuangtongfa.Material-theme
"
for extension in $extensions; do
    code --install-extension "$extension"
done

# PostgreSQL Setup
sudo passwd postgres
sudo -u postgres initdb --locale $LANG -E UTF8 -D '/var/lib/postgres/data'
sudo -u postgres createuser --interactive

# Some misc things
sudo updatedb
sudo sensors-detect --auto

reboot
