#!/usr/bin/env bash

set -e

Bold=$(tput bold)
Reset=$(tput sgr0)
Red=$(tput setaf 1)
Green=$(tput setaf 2)
Yellow=$(tput setaf 3)
BRed=${Bold}${Red}
BGreen=${Bold}${Green}
BYellow=${Bold}${Yellow}

LOG=/var/log/installation.log

add_to_group() {
    [ $(getent group ${1}) ] || groupadd ${1} >> "${LOG}" 2>&1
    gpasswd -a chris ${1} >> "${LOG}" 2>&1
}

enable_services() {
    read -a services <<< "${1}"
    for service in ${services[@]}; do
        echo "${BYellow}Enabling ${service}${Reset}"
        systemctl enable --now ${service} >> "${LOG}" 2>&1
    done
}

package_install() {
    read -a pkgs <<< "${1}"
    for pkg in ${pkgs[@]}; do
        echo "${BYellow}Installing ${pkg}${Reset}"
        if [[ "${2}" == "stubborn" ]]; then
            yes | pacman -S --needed ${pkg} >> "${LOG}" 2>&1
        else
            pacman -S --noconfirm --needed ${pkg} >> "${LOG}" 2>&1
        fi
    done
}

package_remove() {
    read -a pkgs <<< "${1}"
    for pkg in ${pkgs[@]}; do
        echo "${BYellow}Uninstalling ${pkg}${Reset}"
        pacman -Rus --noconfirm ${pkg} >> "${LOG}" 2>&1
    done
}

title() {
    echo "${BGreen}${1}${Reset}"
}

usr() {
    su - chris -c "${1}"
}


title "Configure Pacman"
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


title "Initialize the Pacman Keyring"
package_install "haveged"
haveged -w 1024
pacman-key --init
pacman-key --populate archlinux
pkill haveged
package_remove "haveged"


title "Get the Fastest Mirrors"
reflector --save /etc/pacman.d/mirrorlist --sort rate -f 10 -a 6 -p https -c US


title "System Update"
pacman -Sy >> "${LOG}" 2>&1


title "Configure Sudo"
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


title "ZSH"
package_install "bash-completion zsh zsh-doc zsh-completions zsh-syntax-highlighting"
mkdir -p /etc/zsh
echo 'export ZDOTDIR=$HOME/.config/zsh' > /etc/zsh/zshenv


title "User Setup"
useradd -m -G wheel -s /usr/bin/zsh chris
passwd chris

usr "git clone https://github.com/chrisaguilar/dotfiles.git /home/chris/.config"
usr "chmod +x /home/chris/.config/dots.sh"
usr "cd /home/chris/.config && ./dots.sh"
usr "mkdir -p /home/chris/screenshots"
usr "rm -rf /home/chris/.bash*"


title "Makepkg Setup"
sed -i -r -e 's/CFLAGS=.*$/CFLAGS="-march=native -O2 -pipe -fstack-protector-strong -fno-plt"/' /etc/makepkg.conf
sed -i -r -e 's/CXXFLAGS=.*$/CXXFLAGS="${CFLAGS}"/' /etc/makepkg.conf
sed -i -r -e 's/# ?MAKEFLAGS=.*$/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf
sed -i -r -e 's/# ?BUILDDIR/BUILDDIR/' /etc/makepkg.conf
sed -i -r -e "s/PKGEXT=.*$/PKGEXT='.pkg.tar'/" /etc/makepkg.conf


title "AUR Helper"
usr "mkdir -p /home/chris/aur_setup"
usr "gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53"
usr "git clone https://aur.archlinux.org/cower.git /home/chris/aur_setup/cower"
usr "git clone https://aur.archlinux.org/pacaur.git /home/chris/aur_setup/pacaur"
usr "cd /home/chris/aur_setup/cower && makepkg -sci"
usr "cd /home/chris/aur_setup/pacaur && makepkg -sci"
usr "rm -rf /home/chris/aur_setup"


title "Graphics Drivers"
if [[ "$1" == "vbox" ]]; then
    package_install "virtualbox-guest-modules-arch virtualbox-guest-utils mesa-libgl"
       add_to_group "vboxsf"
    enable_services "vboxservice.service"

    echo -e "vboxguest\nvboxsf\nvboxvideo" >> "/etc/modules-load.d/virtualbox-guest.conf"
else
    package_install "xf86-video-ati mesa-libgl mesa-vdpau libvdpau-va-gl \
                    libva-mesa-driver libva-vdpau-driver vulkan-icd-loader \
                    vulkan-radeon"
fi


          title "Essentials"
package_install "bc rsync mlocate pkgstats arch-wiki-lite tree zip unzip unrar \
                 p7zip lzop cpio avahi nss-mdns alsa-utils alsa-plugins \
                 pulseaudio pulseaudio-alsa ntfs-3g dosfstools exfat-utils \
                 f2fs-tools fuse fuse-exfat autofs mtpfs openssh"

          title "Xorg"
package_install "xorg-server xorg-xinit xorg-xkill xorg-xinput \
                 xf86-input-libinput mesa"

          title "Desktop Environment"
package_install "xfce4-notifyd xfce4-taskmanager i3-wm i3lock gvfs gvfs-mtp \
                 xdg-user-dirs-gtk pavucontrol system-config-printer \
                 gtk3-print-backends zathura zathura-pdf-mupdf zathura-djvu \
                 maim xdotool compton curl numlockx polkit-gnome redshift rofi \
                 geoip geoip-database-extra jsoncpp python-gobject python-xdg \
                 xdg-utils xorg-xprop xorg-xwininfo"

          title "Termite"
package_install "termite" "stubborn"

#           title "CUPS"
# package_install "cups cups-filters ghostscript gsfonts gutenprint foomatic-db \
#                  foomatic-db-engine foomatic-db-nonfree foomatic-db-ppds \
#                  foomatic-db-nonfree-ppds hplip splix cups-pdf \
#                  foomatic-db-gutenprint-ppds"

          title "Network"
package_install "dnsmasq openresolv dhclient network-manager-applet \
                 nm-connection-editor gnome-keyring"

          title "Development"
package_install "nodejs npm python python-pip"

          title "Office"
package_install "calibre libreoffice-fresh"

#           title "LaTeX"
# package_install "texlive-most texlive-lang texlive-langextra biber texstudio"

          title "System"
package_install "htop docker"

          title "Graphics"
package_install "feh"

          title "Internet"
package_install "youtube-dl transmission-gtk wget"

          title "Audio"
package_install "gst-plugins-base gst-plugins-base-libs gst-plugins-good \
                 gst-plugins-bad gst-plugins-ugly gst-libav"

          title "Video"
package_install "mpv libdvdnav libdvdcss cdrdao cdrtools ffmpeg ffmpeg2.8 \
                 ffmpegthumbnailer ffmpegthumbs"

          title "PostgreSQL"
package_install "postgresql"

          title "MongoDB"
package_install "mongodb mongodb-tools"

          title "Fonts"
package_install "cairo fontconfig freetype2 ttf-dejavu ttf-liberation \
                 noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra \
                 otf-fira-mono"

          title "AUR Packages"
            usr "pacaur -S --noconfirm --needed polybar-git i3ipc-glib-git \
                 numix-icon-theme-git numix-circle-icon-theme-git \
                 visual-studio-code google-chrome skypeforlinux-bin
                 plex-media-server otf-fira-code ttf-font-awesome \
                 zsh-autosuggestions gpmdp"


title "SSH Setup"
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


# title "CUPS Setup"
# enable_services "org.cups.cupsd.service"


# title "LaTeX Setup"
# ln -s /etc/fonts/conf.avail/09-texlive-fonts.conf /etc/fonts/conf.d/09-texlive-fonts.conf
# fc-cache && mkfontscale && mkfontdir


title "Docker Setup"
add_to_group "docker"
enable_services "docker.service"


title "PostgreSQL Setup"
passwd postgres
su - postgres -c "initdb --locale ${LANG} -E UTF8 -D '/var/lib/postgres/data'"
enable_services "postgresql.service"
su - postgres -c "createuser --interactive"


title "MongoDB Setup"
enable_services "mongodb.service"


title "Font Setup"
ln -sf /etc/fonts/conf.avail/10-{hinting-slight,sub-pixel-rgb}.conf /etc/fonts/conf.d/
ln -sf /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
ln -sf /etc/fonts/conf.avail/66-noto-{color-emoji,mono,sans,serif}.conf /etc/fonts/conf.d/

sed -i -r -e 's/# ?export/export/' /etc/profile.d/freetype2.sh

fc-cache -f


title "Silence fsck Messages"
sed -i -r -e 's/HOOKS=.*$/HOOKS="base udev autodetect modconf block filesystems keyboard"/' /etc/mkinitcpio.conf
mkinitcpio -p linux

cp /usr/lib/systemd/system/systemd-fsck{@,-root}.service /etc/systemd/system/

echo -e "StandardOutput=null\nStandardError=journal+console" >> /etc/systemd/system/systemd-fsck@.service
echo -e "StandardOutput=null\nStandardError=journal+console" >> /etc/systemd/system/systemd-fsck-root.service


title "Setup Automatic Login to Virtual Console"
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat << "EOF" > /etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin chris --noclear %I $TERM
EOF


title "Blacklist Modules"
echo -e "blacklist sp5100_tco" > /etc/modprobe.d/blacklist.conf


title "Update the mlocate Database"
updatedb


title "Detect Sensors"
sensors-detect --auto >> "${LOG}" 2>&1


title "Enable Network Time Synchronization"
timedatectl set-ntp true


title "Enable System Services"
enable_services "pkgstats.timer fstrim.timer avahi-daemon.service sshd.service"


title "Clean Orphans"
package_remove "$(pacman -Qtdq)"
usr "yes | pacaur -Scc >> ${LOG} 2>&1"
pacman-optimize >> "${LOG}" 2>&1


title "Finish"
reboot
