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
