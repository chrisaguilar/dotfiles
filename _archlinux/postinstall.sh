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
    package_install "mesa-libgl virtualbox-guest-modules-arch virtualbox-guest-utils"
       add_to_group "vboxsf"
    enable_services "vboxservice.service"

    echo -e "vboxguest\nvboxsf\nvboxvideo" >> "/etc/modules-load.d/virtualbox-guest.conf"
else
    package_install "xf86-video-ati mesa mesa-libgl mesa-vdpau libvdpau-va-gl \
                    libva-mesa-driver libva-vdpau-driver vulkan-icd-loader \
                    vulkan-radeon"
fi


          title "Essentials"
package_install "alsa-plugins alsa-utils autofs avahi bc cpio dosfstools \
                 exfat-utils f2fs-tools fuse fuse-exfat lzop mlocate mtpfs \
                 nss-mdns ntfs-3g openssh p7zip pkgstats pulseaudio \
                 pulseaudio-alsa rsync tree unrar unzip zip"

          title "Xorg"
package_install "xorg-server xorg-xinit"

          title "Desktop Environment"
package_install "compton curl geoip geoip-database-extra gnome-themes-standard \
                 i3-wm i3lock jsoncpp maim numlockx pavucontrol polkit-gnome \
                 python-gobject python-xdg xdg-utils redshift rofi \
                 xdg-user-dirs xdotool xfce4-notifyd xfce4-taskmanager \
                 xorg-xprop xorg-xwininfo"

          title "Termite"
package_install "termite" "stubborn"

#           title "CUPS"
# package_install "cups cups-filters cups-pdf foomatic-db foomatic-db-engine \
#                  foomatic-db-gutenprint-ppds foomatic-db-nonfree \
#                  foomatic-db-nonfree-ppds foomatic-db-ppds ghostscript gsfonts \
#                  gtk3-print-backends gutenprint hplip splix \
#                  system-config-printer"

          title "Network"
package_install "dhclient dnsmasq gnome-keyring network-manager-applet \
                 nm-connection-editor openresolv"

          title "Development"
package_install "nodejs npm python python-pip"

          title "Books"
package_install "calibre zathura zathura-pdf-mupdf zathura-djvu"

#           title "Office"
# package_install "libreoffice-fresh"

#           title "LaTeX"
# package_install "biber texlive-lang texlive-langextra texlive-most texstudio"

          title "System"
package_install "docker htop"

          title "Graphics"
package_install "feh"

          title "Internet"
package_install "chromium pepper-flash transmission-gtk wget youtube-dl"

          title "Audio"
package_install "gst-libav gst-plugins-bad gst-plugins-base \
                 gst-plugins-base-libs gst-plugins-good gst-plugins-ugly"

          title "Video"
package_install "cdrdao cdrtools ffmpeg ffmpeg2.8 ffmpegthumbnailer \
                 ffmpegthumbs libdvdcss libdvdnav mpv"

          title "PostgreSQL"
package_install "postgresql"

          title "MongoDB"
package_install "mongodb mongodb-tools"

          title "Fonts"
package_install "cairo fontconfig freetype2 noto-fonts noto-fonts-cjk \
                 noto-fonts-emoji noto-fonts-extra otf-fira-mono ttf-liberation"

          title "AUR Packages"
            usr "pacaur -S --noconfirm --needed chromium-widevine gpmdp \
                 i3ipc-glib-git numix-circle-icon-theme-git \
                 numix-icon-theme-git otf-fira-code plex-media-server \
                 polybar-git skypeforlinux-bin ttf-font-awesome \
                 visual-studio-code zsh-autosuggestions"


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
usr "yes | pacaur -Scc >> /dev/null 2>&1"
pacman-optimize >> "${LOG}" 2>&1


title "Finish"
rm -rf "${LOG}"
reboot
