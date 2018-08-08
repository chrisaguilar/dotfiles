title "Power Management Setup"


subtitle "Installing Packages"
package_install "tlp tlp-rdw acpi_call smartmontools"


subtitle "Configuring Battery Thresholds"
sed -i '/START_CHARGE_THRESH_BAT0/s/^#//' /etc/default/tlp
sed -i '/STOP_CHARGE_THRESH_BAT0/s/^#//' /etc/default/tlp
sed -i '/START_CHARGE_THRESH_BAT1/s/^#//' /etc/default/tlp
sed -i '/STOP_CHARGE_THRESH_BAT1/s/^#//' /etc/default/tlp
