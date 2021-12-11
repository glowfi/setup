#!/bin/sh

## File Manager
#super + f
    pcmanfm

## Logout/Restart/Shutdown
#super+x 
    chosen=$(echo -e "[Cancel]\nShutdown\nReboot\nLock" | dmenu -p "Choose:" -i -nb "#32302f" -nf "#bbbbbb" -sb "#477D6F" -sf "#eeeeee")

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

## Video Editor
#super + w
    kdenlive --platformtheme qt5ct

## Scrap YT
#super + y 
    fish -c "sYT -p "dmenu""

## Random Wallpaper
#super + z
    find $HOME/wall -type f -name *.jpg -o -name *.png | shuf -n 1 | xargs -I {} feh --bg-fill {}
