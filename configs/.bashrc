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
	PS1='◆  \[\e[91m\]\u\[\e[0;1m\] \[\e[0;38;5;208m\]\w\[\e[0m\] $(git branch 2>/dev/null | grep '"'"'*'"'"' | colrm 1 2) '
else
	PS1='◆  \[\e[94m\]\u\[\e[0;1m\] \[\e[0;38;5;208m\]\w\[\e[0m\] $(git branch 2>/dev/null | grep '"'"'*'"'"' | colrm 1 2) '
fi
