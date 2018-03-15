title "Miscellaneous"


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

subtitle "Enabling System Services"
enable_services "pkgstats.timer fstrim.timer avahi-daemon.service sshd.service"
