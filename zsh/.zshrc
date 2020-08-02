if [[ $TERM == xterm-termite ]]; then
    . /etc/profile.d/vte.sh
    __vte_osc7
fi

# Load Config Files
for file in $ZDOTDIR/zshrc.d/*.zsh; do . $file; done

# Syntax Highlighting (zsh-syntax-highlighting)
. /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Autosuggestions (zsh-autosuggestions)
. /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# LS_Colors (lscolors-git)
. /usr/share/LS_COLORS/dircolors.sh

fpath=(/usr/share/zsh/functions/Completion /usr/share/bash-completion/bash_completion $fpath)
