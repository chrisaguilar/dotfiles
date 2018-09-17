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
