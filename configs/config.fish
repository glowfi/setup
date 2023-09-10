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
set PATH ~/.local/bin/ $PATH # Sets Universal path
set PATH ~/.local/bin/nodeJS/bin/ $PATH # Sets NodeJS paths
set PATH ~/.local/bin/luaLSP/bin/ $PATH # Sets lua path
set PATH ~/go/bin $PATH # Sets golang path
set PATH ~/.local/bin/clangd/bin $PATH # Sets clangd path
set PATH ~/.cargo/bin/ $PATH # Sets rust path

## Enhancements
set fish_greeting # Supresses fish's greeting message
set TERM xterm-256color # Sets the terminal type

# Start X at login
set otherOS (uname -a | grep -Eoi "Android"|head -1)
if test "$otherOS" = Android
    true
else
    set checkOS (uname -a | grep -Eoi "Linux"|head -1)
    if test "$checkOS" = Linux
        if status --is-login
            if test -z "$DISPLAY" -a $XDG_VTNR = 1
                exec startx -- -keeptty
            end
        end
    else
        true
    end
end

# ===================================================================
#                        Aliases
# ===================================================================

# Changing ls to exa
alias ls='exa --icons -l --color=always --group-directories-first -F'

# Changing cat to bat
alias cat='bat --theme=gruvbox-dark'

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
alias upgv="upgradeNeovim $argv[1]"

# Synchronize mirrorlist
alias mirru='sudo rm -rf /var/lib/pacman/db.lck;
sudo reflector --verbose -c DE --latest 5 --age 2 --fastest 5 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Syyy'

# Upgrade
alias upgrade='mirru;sudo pacman -Syyyu --noconfirm;yay -Syyyu --noconfirm'

# Archive Unarchive aliases 
alias comp='ouch compress'
alias dcomp='ouch decompress'

# Check-ur-requests alias
alias checkur="checkur.py"

# xhibit alias
alias xbt="xhibit -cs gruvbox -rcn t"
alias xi="randomImagexhibit"

# sYT alais
alias sYT="sYT.sh"

# Terminal Schenanigans
alias suprise="suprise"

# Set Wallpaper and Preview Image
alias wl="nsxiv -t ."
alias pri="setWall"

# PyPI package alias 
alias pC="rm -rf build/ dist/ xhibit.egg-info/;python3 setup.py sdist bdist_wheel"
alias tW="twine upload dist/*"

# Browser-sync
alias bs='browser-sync start --index $argv --server --files "./*.*"'

# Postgres alias
alias pst='sudo systemctl start postgresql'
alias psp='sudo systemctl stop postgresql'
alias psql='psql -d delta'

# Docker alias
alias dst='sudo systemctl start docker.service'
alias dsp='sudo systemctl stop docker.service;sudo systemctl disable docker.service'

# Mongo alias
alias mst='sudo systemctl enable mongodb;sudo systemctl start mongodb'
alias msp='sudo systemctl disable mongodb;sudo systemctl stop mongodb'

# Search Pacakges in Repository
alias spac="pacman -Slq | fzf -m --preview 'pacman -Si {}' | xargs -ro sudo pacman -S"
alias sxb='sudo xbps-query -Rs . | fzf -m | cut -d " " -f2 | xargs -ro sudo xbps-install -Sy'
alias spkg='pkg search "^" | fzf -m|cut -d " " -f1 |xargs -ro sudo pkg install'

# Search AUR
alias saur="yay -Slq | fzf -m --preview 'yay -Si {}' | xargs -ro yay -S"

# Uninstall Packages
alias pacu="pacman -Q | cut -f 1 -d ' ' | fzf -m --preview 'yay -Si {}' | xargs -ro sudo pacman -Rns"
alias pkgu='pkg info | fzf -m|cut -d " " -f1 |xargs -ro sudo pkg remove'
alias xbu="xbps-query -m | fzf -m | xargs -ro sudo xbps-remove -R"

# Cleanup
alias cleanup='yes | sudo pacman -Sc;
yes | yay -Sc;
printf "Cleaned Unused Pacakges!\n";
rm -rf ~/.cache/*;
printf "Cleaned Cache!\n";
sudo pacman -Rns (pacman -Qtdq)  2> /dev/null;
yes | printf "Cleaned Orphans!"'
alias xbc="sudo xbps-remove -Oo;sudo rm /var/cache/xbps/*;sudo rm -rf $HOME/.cache"

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
alias bsp='sudo systemctl disable bluetooth.service;sudo systemctl stop bluetooth.service'

# Virtualization 
alias von='sudo systemctl start libvirtd;sudo virsh net-start default'
alias voff='sudo systemctl stop libvirtd;sudo virsh net-destroy default '
alias vd='vm_download.sh'
alias vs='vm_setup.sh'
alias vm='vm_manager.sh'

# Go to Mounted drive
alias jd='gotoMounteddrive'

# Execute as sudo preserving environment variable of current user
alias se='sudo -E'

# Find and replace with specific word
alias rep="replaceWithSpecificWord"

# Download a file with aria2c
alias d="aria2c -j 16 -x 16 -s 16 -k 1M $argv"

# Copy current path
alias cpc='pwd | xclip -sel c;notify-send "Copied current path to clipboard"'

# Adjust Microphone Volume 
alias mvol='micVOl'

# Open Carbon
alias cbn='setsid xdg-open "https://carbon.now.sh/?bg=rgba%28171%2C+184%2C+195%2C+1%29&t=monokai&wt=none&l=auto&width=680&ds=true&dsyoff=20px&dsblur=68px&wc=true&wa=true&pv=56px&ph=56px&ln=true&fl=1&fm=Hack&fs=14px&lh=133%25&si=false&es=2x&wm=false&code="'

# Refresh dwmblocks 
alias rb='pkill -RTMIN+10 dwmblocks'

# Reset Git Head 
alias gres="git reset --hard HEAD~1"
alias gck="git checkout $argv[1]"

# Get Dotfiles
alias gdot="cd;rm -rf setup;git clone https://github.com/glowfi/setup"

# Eject
alias ej="sudo udisksctl power-off -b $argv[1]"
function ej_
    lsof +D ./ | awk '{print $2}' | tail -n +2 | xargs -r kill -9
end

# Delete Multiple Files 
alias muldf="fd --type f . | fzf -m --reverse --height 10 | xargs -ro sudo rm -rf"
alias muldd="fd --type d . | fzf -m --reverse --height 10 | xargs -ro sudo rm -rf"

# Remove all Metadata
alias rmet="exiftool -all= -overwrite_original $argv[1]"

# Start and Disable SSH Services
alias shs="sudo systemctl enable --now sshd;sudo systemctl enable --now sshguard"
alias shd="sudo systemctl disable sshd;sudo systemctl disable sshguard"

# Regenerate initramfs and grub 
alias rgi="sudo grub-mkconfig -o /boot/grub/grub.cfg;sudo mkinitcpio -p linux-zen"

# Fix audio
alias afx='systemctl --user restart pipewire.service pipewire.socket wireplumber.service pipewire-pulse.service pipewire-pulse.socket pipewire-session-manager.service'

# Journal Logs
alias jl='journalctl -b -p3 --no-hostname --no-pager'


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

### Ignore golang directory
set go_loc_var (echo "go")

# Utility variable

# Search Files in current working directory
function searchFilesCurrent

    if test -z "$argv[1]"
        fd --exclude "$go_loc_var" --type f . | fzf --prompt "Open File:" --reverse --preview "bat --theme gruvbox-dark --style numbers,changes --color=always {}" | read -t args
    else
        fd --exclude "$go_loc_var" --type f --hidden . | fzf --prompt "Open File:" --reverse --preview "bat --theme gruvbox-dark --style numbers,changes --color=always {}" | read -t args
    end

    if test -z "$args"
        echo "Exited from searching files in current working directory!"
    else
        set ft (xdg-mime query filetype $args)
        set def (xdg-mime query default $ft)

        switch $def
            case "nvim.desktop"
                nvim (realpath "$args"); or clear && vim (realpath "$args")
            case ""
                nvim (realpath "$args"); or clear && vim (realpath "$args")
            case '*'
                setsid xdg-open (realpath "$args")
        end
    end
end


# Search Directories in current working directory
function searchDirCurrent

    if test -z "$argv[1]"
        fd --exclude "$go_loc_var" --type d . | fzf --prompt "Go to:" --reverse --preview "ls {}" | read -t args
    else
        fd --exclude "$go_loc_var" --type d --hidden . | fzf --prompt "Open File:" --reverse --preview "ls {}" | read -t args
    end

    if test -z "$args"
        echo "Exited from searching directories in current working directory!"
    else
        cd $args
    end
end

# Search Inside Files
function searchContents
    rg --line-number -g "!$go_loc_var" -g "!./.*" -g "!node_modules" . | awk '{ print $0 }' | fzf --prompt "Find By Words:" --color 'hl:-1:underline,hl+:-1:underline:reverse' --preview 'set loc {}
set loc1 (string split ":" {} -f2)
set loc (string split ":" {} -f1)
bat --theme gruvbox-dark --style numbers,changes --color=always --highlight-line $loc1 --line-range $loc1: $loc' | awk -F':' '{ print $1 "``@``" $2}' | read -t args
    set fl (string split "``@``" $args -f1)
    set ln (string split "``@``" $args -f2)
    if test -z "$fl"
        echo "Exited from searching contents inside files in the current working directory!"
    else
        nvim -c ".+$ln" $fl
    end
end

# Terminal Schenanigans
function suprise
    set getPic (find $HOME/terminal_pics/ -type f -name "*.jpg" -o -name "*.png" -name "*.gif" | shuf -n 1)
    kitty +kitten icat --align=left "$getPic" && fortune -sn80
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

# Set Wallpaper
function setWall
    set getWall (prev.sh -p .)
    set wallPath (realpath "$getWall")
    set DE (echo $XDG_CURRENT_DESKTOP)

    if test -n "$getWall"
        if [ "$DE" = KDE ]
            dbus-send --session --dest=org.kde.plasmashell --type=method_call /PlasmaShell org.kde.PlasmaShell.evaluateScript "string:
    var Desktops = desktops();                                                                                                                       
    for (i=0;i<Desktops.length;i++) {
            d = Desktops[i];
            d.wallpaperPlugin = 'org.kde.image';
            d.currentConfigGroup = Array('Wallpaper',
                                        'org.kde.image',
                                        'General');
            d.writeConfig('Image', '$wallPath');
    }"
        else
            feh --bg-fill "$wallPath"
        end
    end
end

# Jump to Mounted drive
function gotoMounteddrive
    if test "$checkOS" = Linux
        set choice0 (echo "")
        set choice1 (echo "")

        if test (exa "/run/media/$USER" 2>/dev/null)
            set choice0 (exa /run/media/$USER)
        end

        if test (exa "/run/user/1000/gvfs" 2>/dev/null)
            set choice1 (exa /run/user/1000/gvfs)
        end

        if test (echo "$choice0") || test (echo "$choice1")
            set getChoice (echo -e "$choice0\n$choice1" |fzf)
            if test -z (string match -i "$getChoice*" "$choice0")
                if test (echo "$getChoice")
                    cd "/run/user/1000/gvfs/$getChoice"
                end
            else
                if test -z (string match -i "$getChoice*" "$choice1")
                    if test (echo "$getChoice")
                        cd "/run/media/$USER/$getChoice"
                    end
                end
            end
        end
    else
        set choice0 (exa /media/)
        set getChoice (echo -e "$choice0\n$choice1"|xargs|tr " " "\n"|fzf --preview "ls /media/{}")
        cd "/media/$getChoice"
    end
end

# Find and replace with specific word
function replaceWithSpecificWord
    set directoryName $argv[1]
    set queryString $argv[2]
    set tobeRepacedWith $argv[3]
    fd . "$directoryName" | sad "$queryString" "$tobeRepacedWith"
end

# Microphone Volume 
function micVOl
    if test -z $argv[1]
        bash -c "while :
        do amixer -D pulse sset Capture 30000
        pkill -RTMIN+10 dwmblocks
        sleep 1
        done" >/dev/null
    else

        bash -c "while :
        do amixer -D pulse sset Capture $argv[1]
        pkill -RTMIN+10 dwmblocks
        sleep 1
        done" >/dev/null
    end
end

# Upgrade Neovim
function upgradeNeovim
    # Save input as a variable
    set choice (echo "")
    set input (echo "$argv[1]")

    # Get choice
    if [ "$input" = repo ]
        set choice (echo "2")
    else if [ "$input" = source ]
        set choice (echo "1")
    else
        set choice (echo -e "1.Build from source\n2.Install from repository" | fzf | awk -F"." '{print $1}')
    end

    if [ "$choice" != "" ]
        # Remove old config
        sudo rm /usr/local/bin/nvim
        sudo rm -r /usr/local/share/nvim
        rm -rf ~/.config/nvim
        rm -rf ~/.local/share/nvim
        pip uninstall cmake -y
        sudo pacman -Rns --noconfirm neovim

        # Start Installation
        sudo pacman -S --noconfirm cmake ninja tree-sitter

        if [ $choice = 1 ]
            git clone https://github.com/neovim/neovim --depth 1
            cd neovim
            sudo make CMAKE_BUILD_TYPE=Release install || sudo pacman -S --noconfirm neovim
            cd ..
            sudo rm -rf neovim
        else
            sudo pacman -S --noconfirm neovim
        end

        # Copy Config and sync plugins
        cp -r ~/setup/configs/nvim ~/.config
        for i in (seq 100)
            nvim --headless "+Lazy! sync" +qa
        end
    end
end

# ===================================================================
#                            Theme
# ===================================================================


function chooseTheme
    set choosen (printf "simple\nclassic\nminimal" | fzf)
    if test "$checkOS" = Linux
        sed -i "716s/.*/ $choosen/" ~/.config/fish/config.fish && source ~/.config/fish/config.fish
    else
        gsed -i "716s/.*/ $choosen/" ~/.config/fish/config.fish && source ~/.config/fish/config.fish
    end
end

function simple
    set -l last_command_status $status

    set_color C7F377 --bold
    printf " ● "
    set_color 83a598
    printf "%s" "$USER "
    set_color normal
    printf (pwd | sed "s|^$HOME|~|")
    printf " "

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
    set_color black -b 458588
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
    simple
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

# ENV Export
export EDITOR=nvim
export SUDO_ASKPASS=/usr/lib/ssh/ssh-askpass
export FZF_DEFAULT_OPTS='--color=bg+:#4f4b49,spinner:#fb4934,hl:#928374,fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934,marker:#fb4934,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934'

# Bar as Manpager
set -x MANPAGER "sh -c 'col -bx | bat --theme=gruvbox-dark -l man -p'"

# NNN File Manager
export NNN_PLUG='f:fzcd;o:fzopen;p:preview-tui;d:dragdrop'
export NNN_FCOLORS='c1e20406006033f7c6d6abc4'
export NNN_FIFO='/tmp/nnn.fifo'
export NNN_TRASH=1

# QT Platform
set plat (echo "$XDG_CURRENT_DESKTOP")
if test -n "$plat"
else
    export QT_QPA_PLATFORMTHEME=qt5ct
end

# ENV Nvidia CUDA Export
set venvname (echo "play")
set cudnnLocation (echo "$HOME/.pyenv/versions/$venvname/lib/python3.11/site-packages/nvidia/cudnn")
if test -d "$cudnnLocation"
    set CUDNN_PATH $cudnnLocation $CUDNN_PATH
    set LD_LIBRARY_PATH /opt/cuda/lib64 $LD_LIBRARY_PATH
    set PATH /opt/cuda/bin/ $PATH
end

### SystemD

function sysd
    set services (systemctl list-unit-files --type=service | fzf | awk '{print $1}'| xargs)
    set choice (echo -e "Start\nStop\nRestart\nStatus\nEnable\nDisable" | fzf | xargs)

    if [ "$choice" = Start ]
        sudo systemctl start "$services"
        echo "Started!"

    else if [ "$choice" = Stop ]
        sudo systemctl stop "$services"
        echo "Stopped!"

    else if [ "$choice" = Restart ]
        sudo systemctl restart "$services"
        echo "Restarted!"

    else if [ "$choice" = Status ]
        echo "Status check"
        sudo systemctl status "$services"

    else if [ "$choice" = Enable ]
        sudo systemctl enable "$services"
        echo "Enabled!"

    else if [ "$choice" = Disable ]
        sudo systemctl disable "$services"
        echo "Disabled!"
    end
end

### Pyenv 

# Function to activate virtual environment
function acv
    set pyenvLocation (echo "$HOME/.pyenv")
    mkdir -p "$pyenvLocation/versions/systempython"

    if test -n "$VIRTUAL_ENV"
        echo -e "You are inside a Python virtual environment. It can create confusion.\nFirst Deactive the virtual env and run this command again"
    else
        if test -d "$pyenvLocation"
            set getChoice (fd . $HOME/.pyenv/versions --type=d --max-depth=1 | rev | awk -F"/" '{print $2}'| rev | fzf)
            if [ $getChoice = systempython ]
                echo "Switch to systems python!"
                pyenv local --unset
                python --version
            else
                if test -z "$getChoice"
                    true
                else
                    set isPython (echo "$getChoice" | grep -E '^([0-9]+)\.[0-9]+(\.[0-9]+)?$')
                    if test -z "$isPython"
                        set venvLocation (echo "$HOME/.pyenv/versions/$getChoice/bin/activate.fish")
                        source "$venvLocation"
                        echo "Swtiched to virtual environment $getChoice!"
                    else
                        pyenv local --unset
                        pyenv local "$getChoice"
                        echo "Python Interpreter switched!"
                        python --version
                    end
                end
            end
        end
    end
end

# Source Pyenv
set pyenvLocation (echo "$HOME/.pyenv")
if test -d "$pyenvLocation"
    set -Ux PYENV_ROOT $HOME/.pyenv
    fish_add_path $PYENV_ROOT/bin
    pyenv init - | source
end
