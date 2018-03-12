title "Network Setup"


subtitle "Installing Packages"
package_install "dhclient dnsmasq gnome-keyring network-manager-applet \
                 nm-connection-editor openresolv"

subtitle "NetworkManager Setup"
cat << EOF > /etc/NetworkManager/NetworkManager.conf
[main]
dhcp=client

[connection]
wifi.powersave=0
EOF
