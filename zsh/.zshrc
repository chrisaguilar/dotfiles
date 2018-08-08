if [[ $TERM == xterm-termite ]]; then
    . /etc/profile.d/vte.sh
    __vte_osc7
fi

# Load Config Files
for file in $ZDOTDIR/zshrc.d/*.zsh; do . $file; done

# Syntax Highlighting
. /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Autosuggestions
# . /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

fpath=(/usr/share/zsh/functions/Completion /usr/share/bash-completion/bash_completion $fpath)
