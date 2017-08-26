# Cache directory setup
ZSH_CACHE="/tmp/.zsh-${USER}-${ZSH_VERSION}"
mkdir -p $ZSH_CACHE
chmod 700 $ZSH_CACHE

# Misc

ttyctl -f

# LS_COLORS
eval $( dircolors -b $ZDOTDIR/LS_COLORS )
