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


subtitle "Initialize the Pacman Keyring"
package_install "haveged"
haveged -w 1024 >> "${LOG}" 2>&1
pacman-key --init >> "${LOG}" 2>&1
pacman-key --populate archlinux >> "${LOG}" 2>&1
pkill haveged >> "${LOG}" 2>&1
package_remove "haveged"


subtitle "Geting the Fastest Mirrors"
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


subtitle "Sync with Mirrors"
pacman -Sy >> "${LOG}" 2>&1
