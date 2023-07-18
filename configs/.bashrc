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
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

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

# ===================================================================
#                           Custom Functions
# ===================================================================

# Utility variable
go_loc_var=$(echo "$HOME/go")

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
    args=$(rg --line-number -g "!$go_loc_var" -g "!./.*" -g "!node_modules" . | awk '{ print $0 }' | fzf --prompt "Find By Words:" --preview 'set loc {};set loc1 (string split ":" {} -f2);set loc (string split ":" {} -f1);bat --theme "gruvbox-dark" --style numbers,changes --color=always --highlight-line $loc1 --line-range $loc1: $loc' | awk -F':' '{ print $1 " " $2}')
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
    export TERM='gnome-256color';
elif infocmp xterm-256color >/dev/null 2>&1; then
    export TERM='xterm-256color';
fi;

prompt_git() {
    local s='';
    local branchName='';

    # Check if the current directory is in a Git repository.
    if [ $(git rev-parse --is-inside-work-tree &>/dev/null; echo "${?}") == '0' ]; then

        # check if the current directory is in .git before running git checks
        if [ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == 'false' ]; then

            # Ensure the index is up to date.
            git update-index --really-refresh -q &>/dev/null;

            # Check for uncommitted changes in the index.
            if ! $(git diff --quiet --ignore-submodules --cached); then
                s+='+';
            fi;

            # Check for unstaged changes.
            if ! $(git diff-files --quiet --ignore-submodules --); then
                s+='!';
            fi;

            # Check for untracked files.
            if [ -n "$(git ls-files --others --exclude-standard)" ]; then
                s+='?';
            fi;

            # Check for stashed files.
            if $(git rev-parse --verify refs/stash &>/dev/null); then
                s+='$';
            fi;

        fi;

        # Get the short symbolic ref.
        # If HEAD isn’t a symbolic ref, get the short SHA for the latest commit
        # Otherwise, just give up.
        branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
			git rev-parse --short HEAD 2> /dev/null || \
			echo '(unknown)')";

        [ -n "${s}" ] && s=" [${s}]";

        echo -e "${1}${branchName}${2}${s}";
    else
        return;
    fi;
}


# Hex 2 Ansi-256 color codes
#
# 1d2021 016 # ---- darkest black
# 3c3836 016 # ---  darker black
# 504945 052 # --   dark black
# 665c54 059 # -    black
# bdae93 144 # +    brown
# d5c4a1 187 # ++   light brown
# ebdbb2 223 # +++  lighter brown
# fbf1c7 230 # ++++ lightest brown
# fb4934 196 #      red
# fe8019 208 #      orange
# fabd2f 214 #      yellow
# b8bb26 142 #      green
# 8ec07c 108 #      aqua/cyan
# 83a598 109 #      blue
# d3869b 175 #      purple
# d65d0e 166 #      brown

if tput setaf 1 &> /dev/null; then
    tput sgr0; # reset colors
    bold=$(tput bold);
    reset=$(tput sgr0);
    # Grubbox colors, taken from https://github.com/dawikur/base16-gruvbox-scheme
    black=$(tput setaf 0);
    blue=$(tput setaf 109);
    cyan=$(tput setaf 108);
    green=$(tput setaf 142);
    orange=$(tput setaf 208);
    purple=$(tput setaf 175);
    red=$(tput setaf 196);
    white=$(tput setaf 15);
    yellow=$(tput setaf 214);
else
    bold='';
    reset="\e[0m";
    black="\e[1;30m";
    blue="\e[1;34m";
    cyan="\e[1;36m";
    green="\e[1;32m";
    orange="\e[1;33m";
    purple="\e[1;35m";
    red="\e[1;31m";
    white="\e[1;37m";
    yellow="\e[1;33m";
fi;

# Highlight the user name when logged in as root.
if [[ "${USER}" == "root" ]]; then
    userStyle="${red}";
else
    userStyle="${cyan}";
fi;

# Highlight the hostname when connected via SSH.
if [[ "${SSH_TTY}" ]]; then
    hostStyle="${bold}${red}";
else
    hostStyle="${yellow}";
fi;

# Set the terminal title and prompt.
PS1="\[\033]0;\W\007\]"; # working directory base name
PS1+="\[${red}\][${reset}";
PS1+="\[${userStyle}\]\u"; # username
PS1+="\[${white}\]@";
PS1+="\[${hostStyle}\]\h"; # host
PS1+="\[${red}\]]${reset} ";
PS1+="\[${blue}\]\w ${reset}"; # working directory full path
PS1+="\$(prompt_git \"\[${white}\] on \[${blue}\]\" \"\[${cyan}\]\")"; # Git repository details
export PS1;

PS2="\[${yellow}\]→ \[${reset}\]";
export PS2;
