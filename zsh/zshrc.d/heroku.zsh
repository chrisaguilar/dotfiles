# type heroku &>/dev/null && heroku autocomplete:script zsh

HEROKU_AC_ZSH_SETUP_PATH=/home/chris/.cache/heroku/autocomplete/zsh_setup

test -f $HEROKU_AC_ZSH_SETUP_PATH && source $HEROKU_AC_ZSH_SETUP_PATH
