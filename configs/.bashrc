#  _               _
# | |__   __ _ ___| |__  _ __ ___
# | '_ \ / _` / __| '_ \| '__/ __|
# | |_) | (_| \__ \ | | | | | (__
# |_.__/ \__,_|___/_| |_|_|  \___|

# ===================================================================
#                           Aliases
# ===================================================================
alias sf='searchFilesCurrent'
alias sd='searchDirCurrent'
alias sg='searchContents'
alias v='nvim'
alias n='nnn -d -e'
alias gt='gitui'

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
. "$HOME/.cargo/env"
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# ===================================================================
#                           Custom Functions
# ===================================================================

# Utility variable
node_loc_var=$(whereis node)
node_loc_var=$(echo $node_loc_var | cut -d '/' -f4)

# Search Files in current working directory
function searchFilesCurrent() {
	args=$(fd --exclude "$node_loc_var" --type f . | fzf --reverse --height 10)
	if [[ "$args" ]]; then
		ft=$(xdg-mime query filetype "$args")
		def=$(xdg-mime query default "$ft")
		case $def in
		"nvim.desktop")
			nvim $args
			;;

		"")
			nvim $args
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
	args=$(fd --exclude "$node_loc_var" --type d . | fzf --reverse --height 10)
	if [[ "$args" ]]; then
		cd "$args"
	else
		echo "Exited from searching directories in current working directory!"
	fi

}

# Search Inside Files
function searchContents() {
	args=$(rg --line-number -g "!$node_loc_var" -g "!./.*" -g "!node_modules" . | awk '{ print $0 }' | fzf --preview 'set loc {};set loc1 (string split ":" {} -f2);set loc (string split ":" {} -f1);bat --theme "gruvbox-dark" --style numbers,changes --color=always --highlight-line $loc1 --line-range $loc1: $loc' | awk -F':' '{ print $1 " " $2}')
	fl=$(echo "$args" | awk -F" " '{print $1}')
	ln=$(echo "$args" | awk -F" " '{print $2}')

	if [[ "$fl" ]]; then
		nvim -c ".+$ln" $fl
	else
		echo "Exited from searching contents inside files in the current working directory!"
	fi
}
