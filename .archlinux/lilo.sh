#!/usr/bin/env bash

set -e

__dirname="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. "${__dirname}/util.sh"

title "makepkg Setup"

subtitle "Setting CFLAGS"
sed -i -r -e 's/CFLAGS=.*$/CFLAGS="-march=native -O2 -pipe -fstack-protector-strong -fno-plt"/' /etc/makepkg.conf

subtitle "Setting CXXFLAGS"
sed -i -r -e 's/CXXFLAGS=.*$/CXXFLAGS="${CFLAGS}"/' /etc/makepkg.conf

subtitle "Setting MAKEFLAGS"
sed -i -r -e 's/# ?MAKEFLAGS=.*$/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf

subtitle "Setting BUILDDIR"
sed -i -r -e 's/# ?BUILDDIR/BUILDDIR/' /etc/makepkg.conf

subtitle "Setting COMPRESSXZ"
sed -i -r -e 's/COMPRESSXZ=.*$/COMPRESSXZ=(xz -c -z - --threads=0)/' /etc/makepkg.conf

title "pacman Setup"

subtitle "Modifying /etc/pacman.conf"
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

subtitle "Initializing the Pacman Keyring"
package_install "haveged"
haveged -w 1024 >> "${LOG}" 2>&1
pacman-key --init >> "${LOG}" 2>&1
pacman-key --populate archlinux >> "${LOG}" 2>&1
pkill haveged >> "${LOG}" 2>&1
package_remove "haveged"

subtitle "Getting the Fastest Mirrors"
reflector --save /etc/pacman.d/mirrorlist --sort rate -f 10 -a 6 -p https -c US

subtitle "Adding systemd-boot Update Hook"
mkdir -p /etc/pacman.d/hooks
cat << EOF > /etc/pacman.d/hooks/systemd-boot.hook
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Updating systemd-boot...
When = PostTransaction
Exec = /usr/bin/bootctl update
EOF

subtitle "Synchronizing with Mirrors"
pacman -Sy >> "${LOG}" 2>&1

title "sudo Setup"

subtitle "Granting wheel Group Full Access"
sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^# //' /etc/sudoers

subtitle "Setting Defaults in /etc/sudoers"
cat << EOF >> /etc/sudoers

Defaults !requiretty, !tty_tickets, !umask
Defaults visiblepw, path_info, insults, lecture=always
Defaults loglinelen=0, logfile =/var/log/sudo.log, log_year, log_host, syslog=auth
Defaults passwd_tries=3, passwd_timeout=1
Defaults env_reset, always_set_home, set_home, set_logname
Defaults !env_editor, editor="/usr/bin/vim:/usr/bin/vi:/usr/bin/nano"
Defaults timestamp_timeout=15
Defaults passprompt="[sudo] password for %u: "
Defaults lecture=never
EOF

title "ZSH Setup"

subtitle "Installing Packages"
package_install "bash-completion zsh zsh-doc zsh-completions zsh-syntax-highlighting"

subtitle "Creating ZDOTDIR Environment Variable"
mkdir -p /etc/zsh
echo 'export ZDOTDIR=$HOME/.config/zsh' > /etc/zsh/zshenv

title "User Setup"

subtitle "Adding User"
useradd -m -G wheel -s /usr/bin/zsh chris

subtitle "Setting User Password"
echo "chris:a" | chpasswd

subtitle "Cloning Dotfiles from GitHub"
usr "git clone https://github.com/chrisaguilar/dotfiles.git /home/chris/.config" >> "${LOG}" 2>&1

subtitle "Removing Bash Config Files"
usr "rm -rf /home/chris/.bash*"

title "AUR Helper Setup"

subtitle "Making AUR Setup Directory"
usr "mkdir -p /home/chris/aur_setup"

subtitle "Cloning yay from the AUR"
usr "git clone https://aur.archlinux.org/yay.git /home/chris/aur_setup/yay" >> "${LOG}" 2>&1

subtitle "Installing yay"
usr "cd /home/chris/aur_setup/yay && yes | makepkg -sci" >> "${LOG}" 2>&1

subtitle "Removing AUR Setup Directory"
usr "rm -rf /home/chris/aur_setup"

title "Installing Packages"
usr "yay -S --noconfirm --needed \
    mesa xf86-video-intel vulkan-intel vulkan-icd-loader libva-intel-driver \
    libvdpau-va-gl libva-vdpau-driver \
    gnome-{shell,control-center,backgrounds,keyring,menus,screenshot,system-monitor,tweaks} \
    nautilus{,-sendto} tracker{,-miners} xdg-user-dirs-gtk eog gdm sushi dconf-editor \
    cairo fontconfig freetype2 noto-fonts noto-fonts-cjk noto-fonts-emoji \
    noto-fonts-extra otf-fira-code otf-fira-mono otf-font-awesome \
    ttf-liberation \
    dhclient dnsmasq nm-connection-editor openresolv \
    alsa-plugins alsa-utils autofs avahi bc cpio dosfstools exfat-utils \
    f2fs-tools fuse fuse-exfat gvfs libreoffice-fresh lzop mlocate mtpfs \
    nss-mdns ntfs-3g openssh p7zip pkgstats pulseaudio pulseaudio-alsa rsync \
    tree unrar unzip zip \
    nodejs yarn npm jre{,8,10,11}-openjdk-headless jre{,8,10,11}-openjdk \
    jdk{,8,10,11}-openjdk openjdk{,8,10,11}-doc openjdk{,8,10,11}-src \
    sencha-cmd-6 jetbrains-toolbox \
    htop linux-tools termite tlp tlp-rdw acpi_call smartmontools \
    guvcview simplescreenrecorder \
    icaclient transmission-gtk wget youtube-dl \
    gst-libav gst-plugins-bad gst-plugins-base gst-plugins-base-libs \
    gst-plugins-good gst-plugins-ugly \
    mpv vlc \
    capitaine-cursors google-chrome gpmdp slack-desktop spotify \
    visual-studio-code-bin zsh-autosuggestions \
    "

title "Font Setup"

subtitle "Creating Symbolic Links from /etc/fonts/conf.avail -> /etc/fonts/conf.d"
ln -sf /etc/fonts/conf.avail/10-{hinting-slight,sub-pixel-rgb}.conf /etc/fonts/conf.d/
ln -sf /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
ln -sf /etc/fonts/conf.avail/66-noto-{color-emoji,mono,sans,serif}.conf /etc/fonts/conf.d/


subtitle "Creating /etc/fonts/local.conf"
cat << EOF > /etc/fonts/local.conf
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>

    <alias>
        <family>sans-serif</family>
        <prefer>
            <family>Noto Sans</family>
            <family>Noto Color Emoji</family>
            <family>Noto Emoji</family>
        </prefer>
    </alias>

    <alias>
        <family>serif</family>
        <prefer>
            <family>Noto Serif</family>
            <family>Noto Color Emoji</family>
            <family>Noto Emoji</family>
        </prefer>
    </alias>

    <alias>
        <family>monospace</family>
        <prefer>
            <family>Fira Code</family>
            <family>Noto Color Emoji</family>
            <family>Noto Emoji</family>
        </prefer>
    </alias>

</fontconfig>
EOF

subtitle "Modifying freetype2.sh"
sed -i -r -e 's/# ?export/export/' /etc/profile.d/freetype2.sh

subtitle "Regenerating the Font Cache"
fc-cache -f

title "Network Setup"

subtitle "Configuring NetworkManager"
cat << EOF > /etc/NetworkManager/NetworkManager.conf
[main]
dhcp=client

[connection]
wifi.powersave=0
EOF

title "Power Management Setup"

subtitle "Configuring Battery Thresholds"
sed -i '/START_CHARGE_THRESH_BAT0/s/^#//' /etc/default/tlp
sed -i '/STOP_CHARGE_THRESH_BAT0/s/^#//' /etc/default/tlp
sed -i '/START_CHARGE_THRESH_BAT1/s/^#//' /etc/default/tlp
sed -i '/STOP_CHARGE_THRESH_BAT1/s/^#//' /etc/default/tlp

title "SSH Setup"

subtitle "Modifying /etc/ssh/sshd_config"
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

title "Miscellaneous"

subtitle "ICAClient Setup"
usr "mkdir -p /home/chris/.ICAClient/cache"
usr "cp /opt/Citrix/ICAClient/config/{All_Regions,Trusted_Region,Unknown_Region,canonicalization,regions}.ini /home/chris/.ICAClient/"

cat << "EOF" > /usr/share/applications/wfica.desktop
[Desktop Entry]
Name=Citrix ICA client
Comment="Launch Citrix applications from .ica files"
Categories=Network;
Exec=/opt/Citrix/ICAClient/wfica
Terminal=false
Type=Application
NoDisplay=true
MimeType=application/x-ica;
EOF

subtitle "Silencing fsck Messages"
sed -i -r -e 's/HOOKS=.*$/HOOKS="base udev autodetect modconf block filesystems keyboard"/' /etc/mkinitcpio.conf
mkinitcpio -p linux

cp /usr/lib/systemd/system/systemd-fsck{@,-root}.service /etc/systemd/system/

echo -e "StandardOutput=null\nStandardError=journal+console" >> /etc/systemd/system/systemd-fsck@.service
echo -e "StandardOutput=null\nStandardError=journal+console" >> /etc/systemd/system/systemd-fsck-root.service

subtitle "Turning On Automatic Login to Virtual Console"
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat << "EOF" > /etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin chris --noclear %I $TERM
EOF

subtitle "Blacklisting Modules"
echo -e "blacklist nouveau" > /etc/modprobe.d/blacklist.conf

subtitle "Updating the mlocate Database"
updatedb

subtitle "Detecting Sensors"
sensors-detect --auto >> "${LOG}" 2>&1

subtitle "Enabling Network Time Synchronization"
timedatectl set-ntp true

subtitle "Increasing fs.inotify.max_user_watches"
echo "fs.inotify.max_user_watches=524288" > /etc/sysctl.d/40-max-user-watches.conf

subtitle "Disabling Watchdog"
echo "kernel.nmi_watchdog=0" > /etc/sysctl.d/40-disable-watchdog.conf

subtitle "Modifying journald Usage"
sed -i "s/#SystemMaxUse.*/SystemMaxUse=100M/" /etc/systemd/journald.conf

subtitle "Modifying coredump Usage"
sed -i 's/#MaxUse.*/MaxUse=100M/' /etc/systemd/coredump.conf

subtitle "Modifying /etc/dhcpcd.conf"
echo "noarp" >> /etc/dhcpcd.conf
sed -i '/option ntp_servers/s/^#//' /etc/dhcpcd.conf

subtitle "Setting Default Cursor Theme"
cat << "EOF" > /usr/share/icons/default/index.theme
[Icon Theme]
Inherits=capitaine-cursors
EOF

subtitle "Enabling System Services"
enable_services "pkgstats.timer fstrim.timer avahi-daemon.service gdm.service sshd.service"

title "Finishing Up"

subtitle "Removing Orphans"
package_remove "$(pacman -Qtdq)"

subtitle "Clearing pacman Cache"
usr "yes | yay -Scc >> /dev/null 2>&1"

subtitle "Removing Installation Log File"
rm -rf "${LOG}"

subtitle "Reboot"
reboot
