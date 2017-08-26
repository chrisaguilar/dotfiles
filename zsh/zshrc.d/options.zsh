setopt auto_cd
setopt prompt_subst
setopt extended_glob

### Changing Directories

# setopt auto_cd              # If given a path but no command, will cd to that directory if it exists (Requires shin_stdin)
# setopt auto_pushd           # Forces `cd` to push old directory into directory stack
# setopt cdable_vars          # If given a variable and the variable is a path, will cd to path if exists
# setopt chase_dots           # /foo/bar links to /alt/rod; cd /foo/bar/.. changes to /alt and cd .. changes to /alt too
# setopt chase_links          # Basically ^
# setopt pushd_ignore_dups    # Don't push multiple copies of the same directory to the stack
# setopt pushd_minus          # cd +n/-n specifies directory in stack
# setopt pushd_silent         # Don't print directory stack after pushd or popd
# setopt no_pushd_to_home     # Have pushd with no args act like `pushd $HOME`

# # Completion
# setopt always_last_prompt   # LOOK IT UP (man zshoptions -> /ALWAYS_LAST_PROMPT)
# setopt always_to_end        # Initiating completion moves cursor to end of word
# setopt auto_list            # List choices on ambiguous completion
# setopt auto_menu            # Automatically use menu completion on tab key * 2 (overridden by menu_complete)
# setopt auto_name_dirs       # LOOK IT UP (man zshoptions -> /AUTO_NAME_DIRS)
# setopt auto_param_keys      #
# setopt auto_param_slash     #
# setopt no_auto_remove_slash #
# setopt no_bash_auto_list    #
# setopt no_complete_aliases  #
# setopt complete_in_word     #
# setopt glob_complete        #
# setopt hash_list_all        #
# setopt list_ambiguous       #
# setopt no_list_beep         #
# setopt no_list_packed       #
# setopt no_list_rows_first   #
# setopt list_types           #
# setopt no_menu_complete     #
# setopt no_rec_exact         #

# # Expansion & Globbing
# setopt bad_pattern              #
# setopt bare_glob_qual           #
# setopt brace_ccl                #
# setopt no_case_glob             #
# setopt case_match               #
# setopt no_csh_null_glob         #
# setopt equals                   #
# setopt extended_glob            #
# setopt glob                     #
# setopt no_glob_assign           #
# setopt glob_dots                #
# setopt no_glob_subst            #
# setopt no_hist_subst_pattern    #
# setopt no_ignore_braces         #
# setopt no_ksh_glob              #
# setopt magic_equal_subst        #
# setopt mark_dirs                #
# setopt multibyte                #
# setopt nomatch                  #
# setopt no_null_glob             #
# setopt numeric_glob_sort        #
# setopt rc_expand_param          #
# setopt no_rematch_pcre          #
# setopt no_sh_glob               #
# setopt unset                    #
# setopt no_warn_create_global    #

# # History
# setopt append_history           #
# setopt bang_hist                #
# setopt extended_history         #
# setopt no_hist_allow_clobber    #
# setopt no_hist_beep             #
# setopt hist_expire_dups_first   #
# setopt hist_fcntl_lock          #
# setopt hist_find_no_dups        #
# setopt no_hist_ignore_all_dups  #
# setopt hist_ignore_dups         #
# setopt hist_ignore_space        #
# setopt hist_no_functions        #
# setopt hist_no_store            #
# setopt hist_reduce_blanks       #
# setopt hist_save_by_copy        #
# setopt no_hist_save_no_dups     #
# setopt hist_verify              #
# setopt inc_append_history       #
# setopt share_history            #

# # I/O
# setopt aliases              #
# setopt no_clobber           #
# setopt no_correct           #
# setopt no_correct_all       #
# setopt no_dvorak            #
# setopt no_flowcontrol       #
# setopt no_ignore_eof        #
# setopt interactive_comments #
# setopt hash_cmds            #
# setopt hash_dirs            #
# setopt no_mail_warning      #
# setopt no_path_dirs         #
# setopt no_print_eight_bit   #
# setopt no_print_exit_value  #
# setopt rc_quotes            #
# setopt no_rm_star_silent    #
# setopt no_rm_star_wait      #
# setopt short_loops          #
# setopt no_sun_keyboard_hack #

# # Job Control
# setopt auto_continue    #
# setopt no_auto_resume   #
# setopt bg_nice          #
# setopt check_jobs       #
# setopt hup              #
# setopt long_list_jobs   #
# setopt monitor          #
# setopt notify           #

# # Prompt
# setopt no_prompt_bang       #
# setopt prompt_cr            #
# setopt prompt_sp            #
# setopt prompt_percent       #
# setopt prompt_subst         #
# setopt transient_rprompt    #

# # Scripts & Functions
# setopt c_bases              #
# setopt no_c_precedences     #
# setopt no_debug_before_cmd  #
# setopt no_err_exit          #
# setopt no_err_return        #
# setopt eval_lineno          #
# setopt exec                 #
# setopt function_argzero     #
# setopt local_options        #
# setopt local_traps          #
# setopt multios              #
# setopt no_octal_zeroes      #
# setopt no_typeset_silent    #
# setopt no_verbose           #
# setopt no_xtrace            #

# # Shell Emulation
# setopt no_bash_rematch       #
# setopt no_bsd_echo           #
# setopt no_csh_junkie_history #
# setopt no_csh_junkie_loops   #
# setopt no_csh_junkie_quotes  #
# setopt no_csh_nullcmd        #
# setopt no_ksh_arrays         #
# setopt no_ksh_autoload       #
# setopt no_ksh_option_print   #
# setopt no_ksh_typeset        #
# setopt no_ksh_zero_subscript #
# setopt no_posix_aliases      #
# setopt no_posix_builtins     #
# setopt no_posix_identifiers  #
# setopt no_sh_file_expansion  #
# setopt no_sh_nullcmd         #
# setopt no_sh_option_letters  #
# setopt no_sh_word_split      #
# setopt no_traps_async        #

# # Shell State - These are pretty complicated, just look them up.
# # setopt interactive      #
# # setopt login            #
# # setopt privileged       #
# # setopt restricted       #
# # setopt shin_stdin       #
# # setopt single_command   #

# # ZLE
# setopt no_beep              # Beep on error
# setopt no_combining_chars   # man zshoptions -> /combining_chars
# setopt emacs                # Use emacs keybinding for ZLE
# setopt no_overstrike        # Start up line editor in overstrike mode
# setopt no_single_line_zle   # single-line command line editing instead of multi-line
# setopt no_vi                # Use vi keybindings for ZLE
# setopt zle                  # Use the zsh line editor
