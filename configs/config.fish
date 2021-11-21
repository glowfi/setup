#    ▗▄▄▄▖ ▄▄▄  ▗▄▖ ▗▖ ▗▖       ▄▄  ▗▄▖ ▗▄ ▗▖▗▄▄▄▖ ▄▄▄   ▄▄
#    ▐▛▀▀▘ ▀█▀ ▗▛▀▜ ▐▌ ▐▌      █▀▀▌ █▀█ ▐█ ▐▌▐▛▀▀▘ ▀█▀  █▀▀▌
#    ▐▌     █  ▐▙   ▐▌ ▐▌     ▐▛   ▐▌ ▐▌▐▛▌▐▌▐▌     █  ▐▌
#    ▐███   █   ▜█▙ ▐███▌     ▐▌   ▐▌ ▐▌▐▌█▐▌▐███   █  ▐▌▗▄▖
#    ▐▌     █     ▜▌▐▌ ▐▌     ▐▙   ▐▌ ▐▌▐▌▐▟▌▐▌     █  ▐▌▝▜▌
#    ▐▌    ▄█▄ ▐▄▄▟▘▐▌ ▐▌      █▄▄▌ █▄█ ▐▌ █▌▐▌    ▄█▄  █▄▟▌
#    ▝▘    ▀▀▀  ▀▀▘ ▝▘ ▝▘       ▀▀  ▝▀▘ ▝▘ ▀▘▝▘    ▀▀▀   ▀▀

# ===================================================================
#                       General Settings
# ===================================================================

## Path
set PATH ~/node-v17.1.0-linux-x64/bin/ $PATH # Sets NodeJS path
set PATH ~/.local/bin/ $PATH # Sets Universal path

## Enhancements
set fish_greeting # Supresses fish's greeting message
set TERM xterm-256color # Sets the terminal type

# ===================================================================
#                        Aliases
# ===================================================================

# Changing ls to exa
alias ls='exa --icons -l --color=always --group-directories-first'

# Changing cat to bat
alias cat='bat --theme=gruvbox-dark'

# Changing grep to ripgrep
alias grep='rg'

# Changing find to fd
alias find='fd'

# Changing top to bottom
alias top='btm --mem_as_value --color gruvbox'

# NNN alias
alias n='nnn -d -e'

# Reload dxhd
alias dxrel='dxhd -r'

# Git aliases
alias gt='gitui'

# Neovim aliases
alias v='nvim'
alias upgv='sudo rm /usr/local/bin/nvim;
sudo rm -r /usr/local/share/nvim;
rm -rf ~/.config/nvim;
rm -rf ~/.local/share/nvim;
git clone https://github.com/neovim/neovim --depth 1;
cd neovim;
sudo make CMAKE_BUILD_TYPE=Release install;
cd ..;
sudo rm -r neovim;
cp -r ~/setup/configs/nvim ~/.config;
nvim -c "PackerSync";
nvim -c "PackerSync";
nvim -c "PackerSync"'

# Synchronize mirrorlist
alias mirru='sudo rm -rf /var/lib/pacman/db.lck;
sudo reflector --verbose --protocol https -a 48 -c DE -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Syyy'

# Cleanup
alias cleanup='yes | sudo pacman -Sc;
yes | yay -Sc;
printf "Cleaned Unused Pacakges!\n";
rm -rf ~/.cache/*;
printf "Cleaned Cache!\n";
sudo pacman -Rns (pacman -Qtdq)  2> /dev/null;
yes | printf "Cleaned Orphans!"'

# Upgrade
alias upgrade='mirru;sudo pacman -Syyyu --noconfirm;yay -Syyyu --noconfirm'

# Check-ur-requests alias
alias checkur="checkur.py"

# xhibit alias
alias xbt="xhibit.py -cs gruvbox -rcn t"

# Browser-sync
alias bs='browser-sync start --index $argv --server --files "./*.*"'

# Postgres alias
alias pst='sudo systemctl start postgresql'
alias psp='sudo systemctl stop postgresql'
alias psql='psql -d delta'

# Mongo alias
alias mst='sudo systemctl enable mongodb;sudo systemctl start mongodb'
alias msp='sudo systemctl disable mongodb;sudo systemctl stop mongodb'

# Search Pacman
alias spac="pacman -Slq | fzf -m --preview 'pacman -Si {1}' | xargs -ro sudo pacman -S"

# Search AUR
alias saur="yay -Slq | fzf -m --preview 'yay -Si {1}' | xargs -ro yay -S"

# Uninstall Packages
alias pacu="pacman -Q | cut -f 1 -d ' ' | fzf -m --preview 'yay -Si {1}' | xargs -ro sudo pacman -Rns"

# Brightness up 
alias bu="brightnessctl s 30+"
alias bd="brightnessctl s 30-"

# Find files in current location and open in editor
alias sf="searchFilesCurrent"

# Find directories in current location and cd into it
alias sd="searchDirCurrent"

# Find contents inside of the file and open in the editor
alias sg="searchContents"


# ===================================================================
#                         Git Functions
# ===================================================================


function git_is_repo -d "Check if directory is a repository"
    test -d .git
    or begin
        set -l info (command git rev-parse --git-dir --is-bare-repository 2>/dev/null)
        and test $info[2] = false
    end
end


function git_ahead -a ahead behind diverged none
    not git_is_repo; and return

    set -l commit_count (command git rev-list --count --left-right "@{upstream}...HEAD" 2> /dev/null)

    switch "$commit_count"
        case ""
            # no upstream
        case "0"\t"0"
            test -n "$none"; and echo "$none"; or echo ""
        case "*"\t"0"
            test -n "$behind"; and echo "$behind"; or echo -
        case "0"\t"*"
            test -n "$ahead"; and echo "$ahead"; or echo "+"
        case "*"
            test -n "$diverged"; and echo "$diverged"; or echo "±"
    end
end


function git_branch_name -d "Get current branch name"
    git_is_repo; and begin
        command git symbolic-ref --short HEAD 2>/dev/null
        or command git show-ref --head -s --abbrev | head -n1 2>/dev/null
    end
end


function git_is_dirty -d "Check if there are changes to tracked files"
    git_is_worktree; and not command git diff --no-ext-diff --quiet --exit-code
end


function git_is_staged -d "Check if repo has staged changes"
    git_is_repo; and begin
        not command git diff --cached --no-ext-diff --quiet --exit-code
    end
end


function git_is_stashed -d "Check if repo has stashed contents"
    git_is_repo; and begin
        command git rev-parse --verify --quiet refs/stash >/dev/null
    end
end


function git_is_touched -d "Check if repo has any changes"
    git_is_worktree; and begin
        # The first checks for staged changes, the second for unstaged ones.
        # We put them in this order because checking staged changes is *fast*.
        not command git diff-index --cached --quiet HEAD -- >/dev/null 2>&1
        or not command git diff --no-ext-diff --quiet --exit-code >/dev/null 2>&1
    end
end


function git_is_worktree -d "Check if directory is inside the worktree of a repository"
    git_is_repo
    and test (command git rev-parse --is-inside-git-dir) = false
end


function git_untracked -d "Print list of untracked files"
    git_is_worktree; and begin
        command git ls-files --other --exclude-standard
    end
end

# ===================================================================
#                           Custom Functions
# ===================================================================

# Utility variable
set node_loc_var (whereis node)
set node_loc_var (echo $node_loc_var | cut -d '/' -f4 )

# Search Files in current working directory
function searchFilesCurrent
    fd --exclude "$node_loc_var" --type f . | fzf --reverse --height 10 | read -t args
    if test -z "$args"
        echo "Exited from searching current files in current working directory!"
    else
        nvim $args
    end
end


# Search Directories in current working directory
function searchDirCurrent
    fd --exclude "$node_loc_var" --type d . | fzf --reverse --height 10 | read -t args
    if test -z "$args"
        echo "Exited from searching directories in current working directory!"
    else
        cd $args
    end
end


# Search Inside Files
function searchContents
    rg --line-number -g "!$node_loc_var" -g "!./.*" -g "!node_modules" . | awk '{ print $0 }' | fzf --preview 'set loc {};set loc1 (string split ":" {} -f2);set loc (string split ":" {} -f1);bat --theme "gruvbox-dark" --style numbers,changes --color=always --highlight-line $loc1 --line-range $loc1: $loc' | awk -F':' '{ print $1 " " $2}' | read -t args
    set fl (string split " " $args -f1)
    set ln (string split " " $args -f2)
    if test -z "$fl"
        echo "Exited from searching contents of current working directory files!"
    else
        nvim -c ".+$ln" $fl
    end
end


# Bang-Bang Function
function __history_previous_command
    switch (commandline -t)
        case "!"
            commandline -t $history[1]
            commandline -f repaint
        case "*"
            commandline -i !
    end
end

function __history_previous_command_arguments
    switch (commandline -t)
        case "!"
            commandline -t ""
            commandline -f history-token-search-backward
        case "*"
            commandline -i '$'
    end
end

# Binding Bang-Bang Function
bind ! __history_previous_command
bind '$' __history_previous_command_arguments

# set up the same key bindings for insert mode if using fish_vi_key_bindings
if test "$fish_key_bindings" = fish_vi_key_bindings
    bind --mode insert ! __history_previous_command
    bind --mode insert '$' __history_previous_command_arguments
end

# ===================================================================
#                            Theme
# ===================================================================


function fish_prompt
    set -l last_command_status $status

    set_color red --bold
    printf "["
    set_color blue
    printf "%s" "$USER"
    set_color green
    printf "@"
    set_color yellow
    printf "%s" "$hostname "
    set_color C7ECEC
    printf (pwd | sed "s|^$HOME|~|")
    set_color red --bold
    printf "] "
    set_color ffc04d
    printf '%s' '-> '

    set -l normal_color (set_color normal)
    set -l branch_color (set_color yellow)
    set -l meta_color (set_color brgreen)
    set -l symbol_color (set_color blue -o)
    set -l error_color (set_color red -o)
    set -l purple (set_color -o purple)

    if git_is_repo
        echo -n -s $branch_color (git_branch_name) $normal_color
        set -l git_meta ""
        if test (command git ls-files --others --exclude-standard | wc -w 2> /dev/null) -gt 0
            set git_meta "$symbol_color?"
        end
        if test (command git rev-list --walk-reflogs --count refs/stash 2> /dev/null)
            set git_meta "$git_meta\$"
        end
        if git_is_touched
            git_is_dirty && set git_meta "$error_color✘"
            git_is_staged && set git_meta "$git_meta●"
        end
        set -l commit_count (command git rev-list --count --left-right (git remote)/(git_branch_name)"...HEAD" 2> /dev/null)
        if test $commit_count
            set -l behind (echo $commit_count | cut -f 1)
            set -l ahead (echo $commit_count | cut -f 2)
            if test $behind -gt 0
                set git_meta "$purple↓"
            end
            if test $ahead -gt 0
                set git_meta "$purple↑"
            end
        end
        if test $git_meta
            echo -n -s $meta_color " " $git_meta " " $normal_color
        else
            echo -n -s ""
        end
    end

    if test $last_command_status -eq 0
        echo -n -s $symbol_color $symbol " " $normal_color
    else
        echo -n -s $error_color $symbol " " $normal_color
    end
end


function fish_right_prompt

    set -l S (math --scale 2 $CMD_DURATION/1000)
    set -l M (math --scale 2 $S/60)

    echo -n -s " "
    if test $M -gt 1
        echo -n -s $M m
    else if test $S -gt 1
        echo -n -s $S s
    else
        echo -n -s $CMD_DURATION ms
    end
    set_color normal
end


# Fish Title 
function fish_title
    echo fish
end


# ===================================================================
#                   Syntax Highlighting Colors
# ===================================================================

set -U fish_color_normal normal
set -U fish_color_command 99cc99
set -U fish_color_quote ffcc66
set -U fish_color_redirection d3d0c8
set -U fish_color_end cc99cc
set -U fish_color_error f2777a
set -U fish_color_param d3d0c8
set -U fish_color_comment ffcc66
set -U fish_color_match 6699cc
set -U fish_color_selection white --bold --background=brblack
set -U fish_color_search_match bryellow --background=brblack
set -U fish_color_history_current --bold
set -U fish_color_operator 6699cc
set -U fish_color_escape 66cccc
set -U fish_color_cwd_root red
set -U fish_color_cwd green
set -U fish_color_autosuggestion 747369
set -U fish_color_valid_path --underline
set -U fish_color_user brgreen
set -U fish_color_host normal
set -U fish_color_cancel -r
set -U fish_pager_color_completion normal
set -U fish_pager_color_description B3A06D yellow
set -U fish_pager_color_prefix normal --bold --underline
set -U fish_pager_color_progress brwhite --background=cyan


# ===================================================================
#                     Miscellaneous
# ===================================================================

# Default Editor
export EDITOR=nvim

# Bar as Manpager
set -x MANPAGER "sh -c 'col -bx | bat --theme=gruvbox-dark -l man -p'"

# NNN File Manager
export NNN_PLUG='f:fzcd;o:fzopen;p:preview-tui;'
export NNN_FCOLORS='c1e20406006033f7c6d6abc4'
export NNN_FIFO='/tmp/nnn.fifo'
export NNN_TRASH=1
