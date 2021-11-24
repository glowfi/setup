#!/bin/sh

## File Manager
#super + f
    pcmanfm

## Logout/Restart/Shutdown
#super+x 
    chosen=$(echo -e "[Cancel]\nShutdown\nReboot\nLock" | dmenu -i -nb "#32302f" -nf "#bbbbbb" -sb "#98971a" -sf "#eeeeee")

    if [[ $chosen = "Shutdown" ]]; then
        systemctl poweroff
    elif [[ $chosen = "Reboot" ]]; then
        systemctl reboot
    elif [[ $chosen = "Lock" ]]; then
        slock
    elif [[ $chosen = "[Cancel]" ]]; then
        notify-send -t 1000 "Program terminated!" 
    fi

### Global bindings

## Terminal
#super + t
    kitty

## Browser
#super + b
    brave

## Network
#super + n
    kitty -e "nmtui"

## Network
#super + v
    kitty -e "pulsemixer"

## Screenshot
#alt + s
    flameshot gui

## Dmenu
#super + w
    dmenu_run -l 10 -fn "Fantasque Sans Mono Bold" -nb "#32302f" -nf "#bbbbbb" -sb "#98971a" -sf "#eeeeee" -p ">"

## Random Wallpaper
#super + z
    find $HOME/wall -type f -name *.jpg -o -name *.png | shuf -n 1 | xargs -I {} feh --bg-fill {}
