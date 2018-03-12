title "Finishing Up"


subtitle "Clean Orphans"
package_remove "$(pacman -Qtdq)"


subtitle "Clear pacman Cache"
usr "yes | trizen -Scc >> /dev/null 2>&1"


subtitle "Optimize pacman Database"
pacman-optimize >> "${LOG}" 2>&1


subtitle "Remove Installation Log File"
rm -rf "${LOG}"


subtitle "Reboot"
reboot
