if [[ $TERM == xterm-termite ]]; then
    . /etc/profile.d/vte.sh
    __vte_osc7
fi

# Load Config Files
for file in $ZDOTDIR/zshrc.d/*.zsh; do . $file; done

# Syntax Highlighting
. /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
