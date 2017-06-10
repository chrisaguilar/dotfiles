if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then

    function zle-line-init() {
        echoti smkx
    }

    function zle-line-finish() {
        echoti rmkx
    }

    zle -N zle-line-init
    zle -N zle-line-finish
fi

# History Forward
autoload -U up-line-or-beginning-search
zle -N up-line-or-beginning-search

# History Back
autoload -U down-line-or-beginning-search
zle -N down-line-or-beginning-search

# Edit current line in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line

bindkey -e                                                  # Emacs mode
bindkey '\ew' kill-region                                   # [Esc-w] - Kill from the cursor to the mark
bindkey -s '\el' 'ls\n'                                     # [Esc-l] - run command: ls
bindkey '^r' history-incremental-search-backward            # [Ctrl-r] - Search backward for string.
bindkey "${terminfo[kpp]}" up-line-or-history               # [PageUp] - Up a line of history
bindkey "${terminfo[knp]}"   down-line-or-history             # [PageDown] - Down a line of history
bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search    # start typing + [Up-Arrow] - fuzzy find history forward
bindkey "${terminfo[kcud1]}" down-line-or-beginning-search  # start typing + [Down-Arrow] - fuzzy find history backward
bindkey "${terminfo[khome]}" beginning-of-line              # [Home] - Go to beginning of line
bindkey "${terminfo[kend]}"  end-of-line                    # [End] - Go to end of line
bindkey ' ' magic-space                                     # [Space] - do history expansion
bindkey '^[[1;5C' forward-word                              # [Ctrl-RightArrow] - move forward one word
bindkey '^[[1;5D' backward-word                             # [Ctrl-LeftArrow] - move backward one word
bindkey "${terminfo[kcbt]}" reverse-menu-complete           # [Shift-Tab] - move through the completion menu backwards
bindkey '^?' backward-delete-char                           # [Backspace] - delete backward
bindkey "${terminfo[kdch1]}" delete-char                    # [Delete] - delete forward
bindkey '\C-x\C-e' edit-command-line                        # Edit the current command line in $EDITOR
bindkey "^[m" copy-prev-shell-word                          # file rename magick
