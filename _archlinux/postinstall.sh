#!/usr/bin/env bash

set -e

Bold=$(tput bold)
Reset=$(tput sgr0)
Green=$(tput setaf 2)
BGreen=${Bold}${Green}

usr() {
    su - chris -c "${1}"
}

package_install() {
    pacman -S --noconfirm --needed ${1}
}

cat << EOF > /etc/pacman.conf
[options]
HoldPkg      = pacman glibc
Architecture = auto

Color
TotalDownload
CheckSpace
VerbosePkgLists

SigLevel          = Required DatabaseOptional
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


echo "${BGreen}Initialize the Pacman Keyring${Reset}"
package_install "haveged"
haveged -w 1024
pacman-key --init
pacman-key --populate archlinux
pkill haveged
pacman -R --noconfirm haveged


echo "${BGreen}Get the Fastest Mirrors${Reset}"
reflector --save /etc/pacman.d/mirrorlist --verbose --sort rate -f 10 -a 6 -p https -c US


echo "${BGreen}System Update${Reset}"
pacman -Sy


echo "${BGreen}Configure Sudo${Reset}"
sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//' /etc/sudoers
echo "" >> /etc/sudoers
echo 'Defaults !requiretty, !tty_tickets, !umask' >> /etc/sudoers
echo 'Defaults visiblepw, path_info, insults, lecture=always' >> /etc/sudoers
echo 'Defaults loglinelen=0, logfile =/var/log/sudo.log, log_year, log_host, syslog=auth' >> /etc/sudoers
echo 'Defaults passwd_tries=3, passwd_timeout=1' >> /etc/sudoers
echo 'Defaults env_reset, always_set_home, set_home, set_logname' >> /etc/sudoers
echo 'Defaults !env_editor, editor="/usr/bin/vim:/usr/bin/vi:/usr/bin/nano"' >> /etc/sudoers
echo 'Defaults timestamp_timeout=15' >> /etc/sudoers
echo 'Defaults passprompt="[sudo] password for %u: "' >> /etc/sudoers
echo 'Defaults lecture=never' >> /etc/sudoers


echo "${BGreen}Install ZSH${Reset}"
package_install "zsh zsh-syntax-highlighting"
mkdir -p /etc/zsh
echo 'export ZDOTDIR=$HOME/.config/zsh' > /etc/zsh/zshenv


echo "${BGreen}User Setup${Reset}"
useradd -m -G wheel -s /usr/bin/zsh chris
passwd chris

usr "git clone https://github.com/chrisaguilar/dotfiles.git /home/chris/dotfiles"
usr "mkdir -p /home/chris/.config"
usr "chmod +x /home/chris/dotfiles/dots.sh"
usr "cd /home/chris/dotfiles && ./dots.sh"


echo "${BGreen}Makepkg Setup${Reset}"
sed -i -r -e's/CFLAGS=.*$/CFLAGS="-march=native -O2 -pipe -fstack-protector-strong -fno-plt"/' /etc/makepkg.conf
sed -i -r -e's/CXXFLAGS=.*$/CXXFLAGS="${CFLAGS}"/' /etc/makepkg.conf
sed -i -r -e's/# ?MAKEFLAGS=.*$/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf
sed -i -r -e's/# ?BUILDDIR/BUILDDIR/' /etc/makepkg.conf
sed -i -r -e"s/PKGEXT=.*$/PKGEXT='.pkg.tar'/" /etc/makepkg.conf


echo "${BGreen}AUR Helper${Reset}"
usr "mkdir -p /home/chris/aur_setup"
usr "gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53"
usr "git clone https://aur.archlinux.org/cower.git /home/chris/aur_setup/cower"
usr "git clone https://aur.archlinux.org/pacaur.git /home/chris/aur_setup/pacaur"
usr "cd /home/chris/aur_setup/cower && makepkg -sci"
usr "cd /home/chris/aur_setup/pacaur && makepkg -sci"
usr "rm -rf /home/chris/aur_setup"


echo "${BGreen}Basic Setup${Reset}"
package_install "bc rsync mlocate bash-completion pkgstats arch-wiki-lite tree"
package_install "zip unzip unrar p7zip lzop cpio"
package_install "avahi nss-mdns"
package_install "alsa-utils alsa-plugins"
package_install "pulseaudio pulseaudio-alsa"
package_install "ntfs-3g dosfstools exfat-utils f2fs-tools fuse fuse-exfat autofs mtpfs"
systemctl enable avahi-daemon


echo "${BGreen}Install SSH${Reset}"
package_install "openssh"
systemctl enable sshd
sed -i '/Port 22/s/^#//' /etc/ssh/sshd_config
sed -i '/Protocol 2/s/^#//' /etc/ssh/sshd_config
sed -i '/HostKey \/etc\/ssh\/ssh_host_rsa_key/s/^#//' /etc/ssh/sshd_config
sed -i '/HostKey \/etc\/ssh\/ssh_host_dsa_key/s/^#//' /etc/ssh/sshd_config
sed -i '/HostKey \/etc\/ssh\/ssh_host_ecdsa_key/s/^#//' /etc/ssh/sshd_config
sed -i '/KeyRegenerationInterval/s/^#//' /etc/ssh/sshd_config
sed -i '/ServerKeyBits/s/^#//' /etc/ssh/sshd_config
sed -i '/SyslogFacility/s/^#//' /etc/ssh/sshd_config
sed -i '/LogLevel/s/^#//' /etc/ssh/sshd_config
sed -i '/LoginGraceTime/s/^#//' /etc/ssh/sshd_config
sed -i '/PermitRootLogin/s/^#//' /etc/ssh/sshd_config
sed -i '/HostbasedAuthentication no/s/^#//' /etc/ssh/sshd_config
sed -i '/StrictModes/s/^#//' /etc/ssh/sshd_config
sed -i '/RSAAuthentication/s/^#//' /etc/ssh/sshd_config
sed -i '/PubkeyAuthentication/s/^#//' /etc/ssh/sshd_config
sed -i '/IgnoreRhosts/s/^#//' /etc/ssh/sshd_config
sed -i '/PermitEmptyPasswords/s/^#//' /etc/ssh/sshd_config
sed -i '/AllowTcpForwarding/s/^#//' /etc/ssh/sshd_config
sed -i '/AllowTcpForwarding no/d' /etc/ssh/sshd_config
sed -i '/X11Forwarding/s/^#//' /etc/ssh/sshd_config
sed -i '/X11Forwarding/s/no/yes/' /etc/ssh/sshd_config
sed -i -e '/\tX11Forwarding yes/d' /etc/ssh/sshd_config
sed -i '/X11DisplayOffset/s/^#//' /etc/ssh/sshd_config
sed -i '/X11UseLocalhost/s/^#//' /etc/ssh/sshd_config
sed -i '/PrintMotd/s/^#//' /etc/ssh/sshd_config
sed -i '/PrintMotd/s/yes/no/' /etc/ssh/sshd_config
sed -i '/PrintLastLog/s/^#//' /etc/ssh/sshd_config
sed -i '/TCPKeepAlive/s/^#//' /etc/ssh/sshd_config
sed -i '/the setting of/s/^/#/' /etc/ssh/sshd_config
sed -i '/RhostsRSAAuthentication and HostbasedAuthentication/s/^/#/' /etc/ssh/sshd_config


echo "${BGreen}Install Graphics Drivers${Reset}"
package_install "xf86-video-ati mesa-libgl mesa-vdpau libvdpau-va-gl \
                libva-mesa-driver libva-vdpau-driver"


echo "${BGreen}Install Xorg${Reset}"
package_install "xorg-server xorg-xinit xorg-xkill xorg-xinput \
                xf86-input-libinput mesa"


echo "${BGreen}CUPS${Reset}"
package_install "cups cups-filters ghostscript gsfonts gutenprint foomatic-db \
                foomatic-db-engine foomatic-db-nonfree foomatic-db-ppds \
                foomatic-db-nonfree-ppds hplip splix cups-pdf \
                foomatic-db-gutenprint-ppds"
systemctl enable org.cups.cupsd


echo "${BGreen}Desktop Environment${Reset}"
package_install "xfce4 xfce4-goodies i3"
package_install "gvfs gvfs-mtp gvfs-google xdg-user-dirs-gtk pavucontrol \
                system-config-printer gtk3-print-backends zathura \
                zathura-pdf-mupdf zathura-djvu maim xdotool compton curl \
                numlockx polkit-gnome redshift rofi geoip geoip-database-extra \
                jsoncpp python-gobject python-xdg xdg-utils xorg-xprop \
                xorg-xwininfo"
yes | pacman -S --needed termite

echo "${BGreen}Network Manager${Reset}"
package_install "dnsmasq openresolv dhclient network-manager-applet \
                nm-connection-editor gnome-keyring"


echo "${BGreen}Install Development Apps${Reset}"
package_install "nodejs npm python-pip"


echo "${BGreen}Install Office Apps${Reset}"
package_install "calibre texlive-most libreoffice-fresh"


echo "${BGreen}Install System Apps${Reset}"
package_install "htop docker"


echo "${BGreen}Install Graphics Apps${Reset}"
package_install "feh"


echo "${BGreen}Install Internet Apps${Reset}"
package_install "chromium firefox youtube-dl transmission-gtk wget"


echo "${BGreen}Install Audio Apps${Reset}"
package_install "gst-plugins-base gst-plugins-base-libs gst-plugins-good \
                gst-plugins-bad gst-plugins-ugly gst-libav"


echo "${BGreen}Install Video Apps${Reset}"
package_install "mpv libdvdnav libdvdcss cdrdao cdrtools ffmpeg ffmpeg2.8 \
                ffmpegthumbnailer ffmpegthumbs"


echo "${BGreen}Install PostgreSQL${Reset}"
package_install "postgresql"
mkdir -p /var/lib/postgres
chown -R postgres:postgres /var/lib/postgres
echo "Enter your new postgres account password:"
passwd postgres
su - postgres -c "initdb --locale $LANG -D /var/lib/postgres/data"


echo "${BGreen}Install Fonts${Reset}"
package_install "cairo fontconfig freetype2"
package_install "ttf-dejavu ttf-liberation ttf-bitstream-vera \
                noto-fonts noto-fonts-cjk noto-fonts-emoji otf-fira-mono"


echo "${BGreen}Font Configuration${Reset}"
sudo ln -sf /etc/fonts/conf.avail/10-{hintint-slight,sub-pixel-rgb}.conf /etc/fonts/conf.d/
sudo ln -sf /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
sudo ln -sf /etc/fonts/conf.avail/66-noto-{mono,sans,serif}.conf /etc/fonts/conf.d/

sudo sed -i -r -e's/# ?export/export/' /etc/profile.d/freetype2.sh


echo "${BGreen}Remove Monochromatic Emojis${Reset}"
sudo rm /usr/share/fonts/noto/NotoEmoji-Regular.ttf
sudo fc-cache -fv


echo "${BGreen}Silence fsck Messages${Reset}"
sed -i -r -e's/HOOKS=.*$/HOOKS="base udev autodetect modconf block filesystems keyboard"/' /etc/mkinitcpio.conf
mkinitcpio -p linux

cp /usr/lib/systemd/system/systemd-fsck{@,-root}.service /etc/systemd/system/

echo -e "StandardOutput=null\nStandardError=journal+console" >> /etc/systemd/system/systemd-fsck@.service
echo -e "StandardOutput=null\nStandardError=journal+console" >> /etc/systemd/system/systemd-fsck-root.service


echo "${BGreen}Setup Automatic Login to Virtual Console${Reset}"
mkdir -p /etc/systemd/system/getty@tty1.service.d
echo '[Service]' >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo 'ExecStart=' >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo 'ExecStart=-/usr/bin/agetty --autologin chris --noclear %I $TERM' >> /etc/systemd/system/getty@tty1.service.d/override.conf


echo "${BGreen}Miscellaneous Stuff${Reset}"
echo "blacklist sp5100_tco" > /etc/modprobe.d/blacklist.conf
updatedb
systemctl enable pkgstats.timer fstrim.timer
sensors-detect --auto
timedatectl set-ntp true


echo "${BGreen}Install AUR Packages${Reset}"
usr "pacaur -S --noconfirm --needed \
    polybar-git i3ipc-glib-git numix-icon-theme-git numix-circle-icon-theme-git \
    xfce-theme-greybird visual-studio-code google-chrome skypeforlinux-bin \
    plex-media-server otf-fira-code ttf-font-awesome"


echo "${BGreen}Clean Orphans${Reset}"
pacman -Rus --noconfirm `pacman -Qtdq`
usr "yes | pacaur -Scc"
pacman-optimize


echo "${BGreen}Finish${Reset}"
reboot
