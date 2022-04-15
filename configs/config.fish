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
set PATH ~/node-v17.9.0-linux-x64/bin/ $PATH # Sets NodeJS paths
set PATH ~/lua-ls/bin/ $PATH # Sets lua path
set PATH ~/.cargo/bin/ $PATH # Sets rust path
set PATH ~/go/bin/ $PATH # Sets golang path
set PATH ~/clangd_13.0.0/bin $PATH # Sets clangd path
set PATH ~/.local/bin/ $PATH # Sets Universal path

## Enhancements
set fish_greeting # Supresses fish's greeting message
set TERM xterm-256color # Sets the terminal type

# Start X at login
if status --is-login
    if test -z "$DISPLAY" -a $XDG_VTNR = 1
        set greetings bonjour halo hola nomoskar
        set random_greet (random 1 (count $greetings))

        echo "                                      " | lolcat
        echo "                 ▄█▄                  " | lolcat
        echo "                ▄███▄                 " | lolcat
        echo "               ▄█████▄                " | lolcat
        echo "              ▄███████▄               " | lolcat
        echo "             ▄ ▀▀██████▄              " | lolcat
        echo "            ▄██▄▄ ▀█████▄             " | lolcat
        echo "           ▄█████████████▄            " | lolcat
        echo "          ▄███████████████▄           " | lolcat
        echo "         ▄█████████████████▄          " | lolcat
        echo "        ▄███████████████████▄         " | lolcat
        echo "       ▄█████████▀▀▀▀████████▄        " | lolcat
        echo "      ▄████████▀      ▀███████▄       " | lolcat
        echo "     ▄█████████        ████▀▀██▄      " | lolcat
        echo "    ▄██████████        █████▄▄▄       " | lolcat
        echo "   ▄██████████▀        ▀█████████▄    " | lolcat
        echo "  ▄██████▀▀▀              ▀▀██████▄   " | lolcat
        echo " ▄███▀▀                       ▀▀███▄  " | lolcat
        echo "▄▀▀                               ▀▀▄ " | lolcat
        echo ""

        echo "$greetings[$random_greet] $USER!" | figlet | lolcat
        exec startx -- -keeptty
    end
end

# ===================================================================
#                        Aliases
# ===================================================================

# Changing ls to exa
alias ls='exa --icons -l --color=always --group-directories-first -F'

# Changing cat to bat
alias cat='bat --theme=gruvbox-dark'

# Changing grep to ripgrep
alias grep='rg'

# Changing find to fd
alias find='fd'

# Changing top to bottom
alias top='btm --mem_as_value --color gruvbox'

# Kitty aliases
alias disp='kitty +kitten icat'
alias diff='kitty +kitten diff'

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
sudo reflector --verbose -c DE --latest 5 --age 2 --fastest 5 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
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
alias xbt="xhibit -cs gruvbox -rcn t"
alias xi="randomImagexhibit"

# sYT alais
alias sYT="sYT.sh"

# Terminal Schenanigans
alias suprise="suprise"

# Set Wallpaper
alias wl="setWall"

# PyPI package alias 
alias pC="python3 setup.py sdist bdist_wheel"
alias tW="twine upload dist/*"

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

# DWM compile
alias dwc="make clean;make"

# Find files in current location and open in editor
alias sf="searchFilesCurrent"

# Find directories in current location and cd into it
alias sd="searchDirCurrent"

# Find contents inside of the file and open in the editor
alias sg="searchContents"

# Bluetooth alias
alias bst='sudo systemctl enable bluetooth.service;sudo systemctl start bluetooth.service'
alias bsp='sudo systemctl disable bluetooth.service;sudo systemctl stop bluetooth.service;killall blueman-tray;killall blueman-applet'

# Virtualization 
alias von='sudo systemctl start libvirtd'


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

set check_clangd (whereis clangd)
if test -z "$check_clangd"
    set clangd_loc_var (echo ".cache")
else
    set clangd_loc (clangd --version | head -1 | cut -d " " -f3)
    set clangd_loc_var (echo "clangd_$clangd_loc")
end

set lua_loc_var (echo "lua-ls")

set go_loc_var (echo "go")



# Search Files in current working directory
function searchFilesCurrent
    fd --exclude "$node_loc_var" --exclude "$clangd_loc_var" --exclude "$lua_loc_var" --exclude "$go_loc_var" --type f . | fzf --reverse --height 10 | read -t args
    if test -z "$args"
        echo "Exited from searching files in current working directory!"
    else
        set ft (xdg-mime query filetype $args)
        set def (xdg-mime query default $ft)

        switch $def
            case "nvim.desktop"
                nvim $args
            case ""
                nvim $args
            case '*'
                setsid xdg-open $args
        end
    end
end


# Search Directories in current working directory
function searchDirCurrent
    fd --exclude "$node_loc_var" --exclude "$clangd_loc_var" --exclude "$lua_loc_var" --exclude "$go_loc_var" --type d . | fzf --reverse --height 10 | read -t args
    if test -z "$args"
        echo "Exited from searching directories in current working directory!"
    else
        cd $args
    end
end


# Search Inside Files
function searchContents
    rg --line-number -g "!$node_loc_var" -g "!$clangd_loc_var" -g "!$lua_loc_var" -g "!$go_loc_var" -g "!./.*" -g "!node_modules" . | awk '{ print $0 }' | fzf --preview 'set loc {};set loc1 (string split ":" {} -f2);set loc (string split ":" {} -f1);bat --theme "gruvbox-dark" --style numbers,changes --color=always --highlight-line $loc1 --line-range $loc1: $loc' | awk -F':' '{ print $1 " " $2}' | read -t args
    set fl (string split " " $args -f1)
    set ln (string split " " $args -f2)
    if test -z "$fl"
        echo "Exited from searching contents inside files in the current working directory!"
    else
        nvim -c ".+$ln" $fl
    end
end

# Terminal Schenanigans
function suprise
    bash -c 'find $HOME/terminal_pics/ -type f -name "*.jpg" -o -name "*.png" -name "*.gif" | shuf -n 1' | xargs -I {} kitty +kitten icat --align=left {} && fortune -sn80
end

# Generate random image and show in xhibit
function randomImagexhibit
    if test -z $argv[1]
        set img ( fd  --type f -g "*.jpg" -g "*.png" $HOME/wall 2>/dev/null| shuf -n 1)
        xhibit -img "$img" -imb kitty -rcs t
    else
        set img (fd --type f --full-path $argv[1] | shuf -n 1)
        xhibit -img "$img" -imb kitty -rcs t
    end
end

function setWall
    feh --bg-fill $argv[1]
    cd
    cat .fehbg | tail -1 | awk '{print $NF}' | awk -F/ '{print $5}' | tr -d "'" | xargs -I {} wal -s -q -t --backend haishoku -i ~/wall/{}
    sed -i '9,11d' ~/.cache/wal/colors-wal-dwm.h
    sed -i 14d ~/.cache/wal/colors-wal-dwm.h
    cd ~/.config/dwm-6.2/
    make clean
    make
    cd ~/wall/
    xdotool key super+shift+q
end

function trad
    ffmpeg -i $argv[1] -ss $argv[2] -to $argv[3] -f mp3 -ab 192000 -vn out.mp3
end

function mado
    ffmpeg -i $argv[1] -i $argv[2] \
        -filter_complex '[0:0][1:0]concat=n=2:v=0:a=1[out]' \
        -map '[out]' output.mp3
end

function kut
    ffmpeg -i $argv[1] -vcodec copy -acodec copy -ss $argv[2] -to $argv[3] out.mp4
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


function chooseTheme
    set choosen (printf "classic\nminimal" | fzf)
    sed -i "545s/.*/    $choosen/" ~/.config/fish/config.fish
end


function classic
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

function minimal

    # Status
    set -l last_status $status
    set -l cwd (pwd | sed "s|^$HOME|~|")

    # Colors
    set -l normal_color (set_color normal)
    set -l branch_color (set_color yellow)
    set -l meta_color (set_color brgreen)
    set -l symbol_color (set_color blue -o)
    set -l error_color (set_color red -o)
    set -l purple (set_color -o purple)


    # Display current path and left pointing arrow symbol
    set_color black -b 477D6F
    echo -n " $cwd "
    set_color normal
    set_color ffc04d
    printf '%s' ' -> '

    # Show git branch and dirty state
    if git_is_repo
        echo -n -s (set_color 000000 -b d65d0e) (string join '' '  ' (git_branch_name) ' ') $normal_color
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

    # Add a space and restore normal color
    set_color normal
    echo -n ' '
end


function fish_prompt
    classic
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

# QT Platform
set plat (echo "$XDG_CURRENT_DESKTOP")
if test -n "$plat"
else
    export QT_QPA_PLATFORMTHEME=qt5ct
end
