title "Miscellaneous"


subtitle "Silence fsck Messages"
sed -i -r -e 's/HOOKS=.*$/HOOKS="base udev autodetect modconf block filesystems keyboard"/' /etc/mkinitcpio.conf
mkinitcpio -p linux

cp /usr/lib/systemd/system/systemd-fsck{@,-root}.service /etc/systemd/system/

echo -e "StandardOutput=null\nStandardError=journal+console" >> /etc/systemd/system/systemd-fsck@.service
echo -e "StandardOutput=null\nStandardError=journal+console" >> /etc/systemd/system/systemd-fsck-root.service


subtitle "Setup Automatic Login to Virtual Console"
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat << "EOF" > /etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin chris --noclear %I $TERM
EOF


subtitle "Blacklist Modules"
echo -e "blacklist nouveau" > /etc/modprobe.d/blacklist.conf


subtitle "Update the mlocate Database"
updatedb


subtitle "Detect Sensors"
sensors-detect --auto >> "${LOG}" 2>&1


subtitle "Enable Network Time Synchronization"
timedatectl set-ntp true


subtitle "Increase fs.inotify.max_user_watches"
echo "fs.inotify.max_user_watches=524288" > /etc/sysctl.d/40-max-user-watches.conf


subtitle "Disable Watchdog"
echo "kernel.nmi_watchdog=0" > /etc/sysctl.d/40-disable-watchdog.conf


subtitle "Modify journald Usage"
sed -i "s/#SystemMaxUse.*/SystemMaxUse=100M/" /etc/systemd/journald.conf


subtitle "Modify coredump Usage"
sed -i 's/#MaxUse.*/MaxUse=100M/' /etc/systemd/coredump.conf


subtitle "Modify /etc/dhcpcd.conf"
echo "noarp" >> /etc/dhcpcd.conf
sed -i '/option ntp_servers/s/^#//' /etc/dhcpcd.conf

subtitle "Enable System Services"
enable_services "pkgstats.timer fstrim.timer avahi-daemon.service sshd.service"
