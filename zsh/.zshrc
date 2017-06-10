if [[ $TERM == xterm-termite ]]; then
  . /etc/profile.d/vte.sh
  __vte_osc7
fi

# Load Config Files
for file in $ZDOTDIR/{util,zshrc.d}/*.zsh; do . $file; done

# Fish-Like Syntax Highlighting
. /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

