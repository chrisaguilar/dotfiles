title "User Setup"


subtitle "Adding User"
useradd -m -G wheel -s /usr/bin/zsh chris


subtitle "Setting User Password"
passwd chris


subtitle "Cloning Dotfiles from GitHub"
usr "git clone https://github.com/chrisaguilar/dotfiles.git /home/chris/.config" >> "${LOG}" 2>&1


subtitle "Installing Dotfiles"
usr "chmod +x /home/chris/.config/dots.sh"
usr "cd /home/chris/.config && ./dots.sh" >> "${LOG}" 2>&1


subtitle "Remove Bash Config Files"
usr "rm -rf /home/chris/.bash*"
