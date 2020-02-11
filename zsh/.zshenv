export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share

PATH="$HOME/.dotnet/tools:$PATH"
PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/.npm-global/bin:$PATH"
PATH="$HOME/code/go/bin:$PATH"
PATH="$XDG_CONFIG_HOME/bin:$PATH"
PATH="$XDG_DATA_HOME/npm/bin:$PATH"
export PATH

export ANDROID_HOME=/opt/android-sdk
export DOCKERID=chrisaguilar
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export EDITOR=/usr/bin/vim
export ELECTRON_TRASH=gio
export GOPATH=$HOME/code/go
#export GTK2_RC_FILES=$XDG_CONFIG_HOME/gtk-2.0/gtkrc
export LANG=en_US.UTF-8
export LC_COLLATE=C
export LESSHISTFILE=$XDG_CACHE_HOME/less/history
export LESSKEY=$XDG_CACHE_HOME/less/key
export LIBVA_DRIVER_NAME="i965"
export MAILCHECK=0
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc
export PAGER=/usr/bin/less
export PGPASSFILE=$XDG_CONFIG_HOME/pg/pgpass
export PGSERVICEFILE=$XDG_CONFIG_HOME/pg/pg_service.conf
export PSQL_HISTORY=$XDG_CACHE_HOME/psql_history
export PSQLRC=$XDG_CONFIG_HOME/pg/psqlrc
export PYLINTHOME=$XDG_CACHE_HOME/pylint.d
export RANGER_LOAD_DEFAULT_RC=false
export VDPAU_DRIVER="va_gl"
export VISUAL=/usr/bin/vim
export WB_FORCE_SYSTEM_COLORS=1
