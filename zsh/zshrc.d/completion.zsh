# Initialization
autoload -Uz compinit bashcompinit
compinit -d "$ZSH_CACHE/zcompdump"
bashcompinit -d "$ZSH_CACHE/bashcompdump"
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path $ZSH_CACHE

_comp_options+=(globdots)

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' menu select=2
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*' rehash true
zstyle ':completion:*:complete:(cd|pushd):*' tag-order 'local-directories path-directories directory-stack' '*'

# Verbose completion results
zstyle ':completion:*' verbose true

# Group results by category
# Keep disabled because it makes things slow
# zstyle ':completion:*' group-name ''

# Keep directories and files separated
zstyle ':completion:*' list-dirs-first true

# Don't try parent path completion if the directories exist
zstyle ':completion:*' accept-exact-dirs true

# Nicer format for completion messages
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'

# Use ls-colors for path completions
function _set-list-colors() {
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    unfunction _set-list-colors
}
sched 0 _set-list-colors  # deferred since LC_COLORS might not be available yet

# pipenv completion
# eval "$(pipenv --completion)"

#compdef pipenv
_pipenv() {
  eval $(env COMMANDLINE="${words[1,$CURRENT]}" _PIPENV_COMPLETE=complete-zsh  pipenv)
}
if [[ "$(basename ${(%):-%x})" != "_pipenv" ]]; then
  autoload -U compinit && compinit
  compdef _pipenv pipenv
fi

