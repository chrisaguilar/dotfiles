# Ensure oh-my-zsh and plugins are installed
if [ ! -d "$ZSH" ]; then
    (cd "$HOME/.config/zsh" && git clone https://github.com/ohmyzsh/ohmyzsh.git oh-my-zsh)
fi

if [ ! -d "$ZSH/plugins/zsh-syntax-highlighting" ]; then
    (cd "$ZSH/plugins" && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git)
fi

if [ ! -d "$ZSH/plugins/zsh-autosuggestions" ]; then
    (cd "$ZSH/plugins" && git clone https://github.com/zsh-users/zsh-autosuggestions.git)
fi
