title "AUR Helper Setup"


subtitle "Making AUR Setup Directory"
usr "mkdir -p /home/chris/aur_setup"


subtitle "Cloning trizen from the AUR"
usr "git clone https://aur.archlinux.org/trizen.git /home/chris/aur_setup/trizen" >> "${LOG}" 2>&1


subtitle "Installing trizen"
usr "cd /home/chris/aur_setup/trizen && yes | makepkg -sci" >> "${LOG}" 2>&1


subtitle "Removing AUR Setup Directory"
usr "rm -rf /home/chris/aur_setup"
