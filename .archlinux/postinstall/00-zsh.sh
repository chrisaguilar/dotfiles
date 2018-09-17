title "ZSH Setup"


subtitle "Installing Packages"
package_install "bash-completion zsh zsh-doc zsh-completions zsh-syntax-highlighting"


subtitle "Creating ZDOTDIR Environment Variable"
mkdir -p /etc/zsh
echo 'export ZDOTDIR=$HOME/.config/zsh' > /etc/zsh/zshenv
