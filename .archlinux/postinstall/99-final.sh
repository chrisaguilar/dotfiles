title "Finishing Up"


subtitle "Removing Orphans"
package_remove "$(pacman -Qtdq)"


subtitle "Clearing pacman Cache"
usr "yes | trizen -Scc >> /dev/null 2>&1"


subtitle "Optimizing pacman Database"
pacman-optimize >> "${LOG}" 2>&1


subtitle "Removing Installation Log File"
rm -rf "${LOG}"


subtitle "Reboot"
reboot
