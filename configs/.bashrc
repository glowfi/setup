#  _               _
# | |__   __ _ ___| |__  _ __ ___
# | '_ \ / _` / __| '_ \| '__/ __|
# | |_) | (_| \__ \ | | | | | (__
# |_.__/ \__,_|___/_| |_|_|  \___|

# ===================================================================
#                           Aliases
# ===================================================================
alias sf='searchFilesCurrent'
alias sfh='searchFilesCurrent h'
alias sd='searchDirCurrent'
alias sdh='searchDirCurrent h'
alias sg='searchContents'
alias sgh='searchContents h'
alias v='nvim'
alias n='nnn -d -e'
alias gt='gitui'
alias ls='ls -1'
alias grep='grep --color=auto'

# ===================================================================
#                          Miscellaneous
# ===================================================================
# Do nothing if not running interactively
[[ $- != *i* ]] && return

# Bash-completion
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] &&
	. /usr/share/bash-completion/bash_completion

# ===================================================================
#                           Environment Variables
# ===================================================================
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
export FZF_DEFAULT_OPTS='--color=bg+:#4f4b49,spinner:#fb4934,hl:#928374,fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934,marker:#fb4934,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934'

# ===================================================================
#                           Custom Functions
# ===================================================================

# Utility variable
go_loc_var=$(echo "go")

# Search Files in current working directory
function searchFilesCurrent() {

	if [[ "$1" == "h" ]]; then
		args=$(fd --exclude "$go_loc_var" --type f --hidden . | fzf --prompt "Open File:" --reverse --preview "bat --theme gruvbox-dark --style numbers,changes --color=always {}")
	else
		args=$(fd --exclude "$go_loc_var" --type f . | fzf --prompt "Open File:" --reverse --preview "bat --theme gruvbox-dark --style numbers,changes --color=always {}")

	fi

	if [[ "$args" ]]; then
		ft=$(xdg-mime query filetype "$args")
		def=$(xdg-mime query default "$ft")
		case $def in
		"nvim.desktop")
			if which nvim >/dev/null; then
				nvim "$args"
			else
				clear
				vim "$args"
			fi
			;;

		"")
			if which nvim >/dev/null; then
				nvim "$args"
			else
				clear
				vim "$args"
			fi
			;;

		*)
			setsid xdg-open "$args"
			;;
		esac
	else
		echo "Exited from searching files in current working directory!"
	fi

}

# Search Directories in current working directory
function searchDirCurrent() {
	if [[ "$1" == "h" ]]; then
		args=$(fd --exclude "$go_loc_var" --type d --hidden . | fzf --prompt "Open File:" --reverse --preview "ls {}")
	else
		args=$(fd --exclude "$go_loc_var" --type d . | fzf --prompt "Go to:" --reverse --preview "ls {}")
	fi

	if [[ "$args" ]]; then
		cd "$args"
	else
		echo "Exited from searching directories in current working directory!"
	fi

}

# Search Inside Files
function searchContents() {
	if [[ "$1" == "h" ]]; then
		args=$(rg --line-number -g "!$go_loc_var" -g "!./.*" -g "!node_modules" . --hidden | awk '{ print $0 }' | fzf --prompt "Find By Words:" --color 'hl:-1:underline,hl+:-1:underline:reverse' --preview 'set loc {};set loc1 (string split ":" {} -f2);set loc (string split ":" {} -f1);bat --theme "gruvbox-dark" --style numbers,changes --color=always --highlight-line $loc1 --line-range $loc1: $loc' | awk -F':' '{ print $1 " " $2}')
	else
		args=$(rg --line-number -g "!$go_loc_var" -g "!./.*" -g "!node_modules" . | awk '{ print $0 }' | fzf --prompt "Find By Words:" --color 'hl:-1:underline,hl+:-1:underline:reverse' --preview 'set loc {};set loc1 (string split ":" {} -f2);set loc (string split ":" {} -f1);bat --theme "gruvbox-dark" --style numbers,changes --color=always --highlight-line $loc1 --line-range $loc1: $loc' | awk -F':' '{ print $1 " " $2}')
	fi

	fl=$(echo "$args" | awk -F" " '{print $1}')
	ln=$(echo "$args" | awk -F" " '{print $2}')

	if [[ "$fl" ]]; then
		nvim -c ".+$ln" $fl
	else
		echo "Exited from searching contents inside files in the current working directory!"
	fi
}

# ===================================================================
#                           Prompt
# ===================================================================
if [[ $COLORTERM = gnome-* && $TERM = xterm ]] && infocmp gnome-256color >/dev/null 2>&1; then
	export TERM='gnome-256color'
elif infocmp xterm-256color >/dev/null 2>&1; then
	export TERM='xterm-256color'
fi

user=$(whoami)
if [[ "$user" = "root" ]]; then
	PS1='◆  \[\e[91m\]\u\[\e[0;1m\] \w $(git branch 2>/dev/null | grep '"'"'*'"'"' | colrm 1 2) '
else
	PS1='◆  \[\e[32m\]\u\[\e[0;1m\] \w $(git branch 2>/dev/null | grep '"'"'*'"'"' | colrm 1 2) '
fi

# ===================================================================
#                           ble.sh
# ===================================================================
if test -f ~/.local/share/blesh/ble.sh; then
	## Read ble.sh
	source ~/.local/share/blesh/ble.sh

	## Basic settings

	bleopt input_encoding=UTF-8
	bleopt editor=vim

	## Line editor settings

	bleopt indent_offset=4
	bleopt indent_tabs=1

	# position of the cursor on dirty section after undo (end or beg)
	bleopt undo_point=end

	bleopt prompt_eol_mark=$'\e[4;1;33m[EOF]\e[m'
	bleopt exec_errexit_mark=$'\e[1;31m$? >>> %d\e[m'

	bleopt line_limit_length=10000
	bleopt history_limit_length=10000

	## Rendering options

	bleopt tab_width=4
	bleopt char_width_mode=auto

	## User input settings

	bleopt decode_isolated_esc=esc

	# disable visual bells since they dont go away
	bleopt decode_error_char_vbell=1
	bleopt decode_error_cseq_vbell=1
	bleopt decode_error_kseq_vbell=1

	bleopt vbell_duration=2000
	bleopt vbell_align=right

	## Custom key bindings

	# extra bingings
	ble-bind -s 'M-c' '\C-a\C-] \C-u'
	ble-bind -c 'M-u' 'cd ..'

	# change from vim mode to normal mode
	ble-bind -m 'emacs' -f 'M-e' 'vi-editing-mode'
	ble-bind -m 'vi_imap' -f 'M-e' 'emacs-editing-mode'
	ble-bind -m 'vi_nmap' -f 'M-e' 'emacs-editing-mode'
	ble-bind -m 'vi_xmap' -f 'M-e' 'emacs-editing-mode'

	# Alt+, and Alt+. to pick first/last arg from last command
	ble-bind -m 'emacs' -f M-, insert-nth-argument
	ble-bind -m 'emacs' -f M-. insert-last-argument

	## Settings for completion

	## The following settings turn on/off the corresponding functionalities. When
	## non-empty strings are set, the functionality is enabled. Otherwise, the
	## functionality is inactive.

	bleopt complete_auto_complete=1
	bleopt complete_menu_complete=1
	bleopt complete_menu_filter=1
	bleopt complete_ambiguous=1

	# Options are "dense" "dense-nowrap" "linewise" "desc" "desc-raw" "align" and "align-nowrap"
	bleopt complete_menu_style=align
	bleopt menu_align_max=20
	bleopt complete_menu_maxlines=20

	## Color settings

	bleopt term_index_colors=256

	# This might not let the colors respect the colorsheme
	# bleopt filename_ls_colors="$LS_COLORS"

	bleopt highlight_syntax=1
	bleopt highlight_filename=1
	bleopt highlight_variable=

	## The following settings specify graphic styles of each faces.

	ble-color-setface region fg=white,bg=60
	ble-color-setface region_insert none
	ble-color-setface region_match fg=white,bg=55,bold
	ble-color-setface region_target fg=black,bg=153
	ble-color-setface disabled fg=242
	ble-color-setface overwrite_mode fg=black,bg=51
	ble-color-setface auto_complete fg=238,bg=254
	ble-color-setface vbell reverse
	ble-color-setface vbell_erase none
	ble-color-setface vbell_flash fg=green,reverse

	ble-color-setface syntax_default none
	ble-color-setface syntax_command fg=brown
	ble-color-setface syntax_quoted fg=green
	ble-color-setface syntax_quotation fg=green,bold
	ble-color-setface syntax_expr fg=navy
	ble-color-setface syntax_error bg=203,fg=231
	ble-color-setface syntax_varname fg=202
	ble-color-setface syntax_delimiter none
	ble-color-setface syntax_param_expansion fg=purple
	ble-color-setface syntax_history_expansion bg=94,fg=231
	ble-color-setface syntax_function_name fg=92,bold
	ble-color-setface syntax_comment fg=gray
	ble-color-setface syntax_glob fg=198,bold
	ble-color-setface syntax_brace fg=37,bold
	ble-color-setface syntax_tilde fg=navy,bold
	ble-color-setface syntax_document fg=94
	ble-color-setface syntax_document_begin fg=94,bold
	ble-color-setface command_builtin_dot fg=yellow,bold
	ble-color-setface command_builtin fg=yellow
	ble-color-setface command_alias fg=teal
	ble-color-setface command_function fg=orange
	ble-color-setface command_file none
	ble-color-setface command_keyword fg=blue
	ble-color-setface command_jobs fg=red,bold
	ble-color-setface command_directory fg=blue
	ble-color-setface filename_directory fg=blue
	ble-color-setface filename_directory_sticky fg=white,bg=blue,bold
	ble-color-setface filename_link fg=teal
	ble-color-setface filename_orphan underline,fg=teal,bg=224
	ble-color-setface filename_setuid underline,fg=black,bg=220
	ble-color-setface filename_setgid underline,fg=black,bg=191
	ble-color-setface filename_executable fg=green
	ble-color-setface filename_other none
	ble-color-setface filename_socket underline,fg=cyan,bg=black
	ble-color-setface filename_pipe underline,fg=lime,bg=black
	ble-color-setface filename_character underline,fg=white,bg=black
	ble-color-setface filename_block underline,fg=yellow,bg=black
	ble-color-setface filename_warning underline,fg=red
	ble-color-setface filename_url underline,fg=blue
	ble-color-setface filename_ls_colors none
	ble-color-setface varname_array fg=orange,bold
	ble-color-setface varname_empty fg=31
	ble-color-setface varname_export fg=200,bold
	ble-color-setface varname_expr fg=92,bold
	ble-color-setface varname_hash fg=70,bold
	ble-color-setface varname_number fg=64
	ble-color-setface varname_readonly fg=200
	ble-color-setface varname_transform fg=29,bold
	ble-color-setface varname_unset fg=124
fi
