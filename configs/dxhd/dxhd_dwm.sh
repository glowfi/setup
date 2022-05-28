#!/bin/sh

## File Manager
#super + f
pcmanfm

## Logout/Restart/Shutdown
#super+x
case "$(readlink -f /sbin/init)" in
*systemd*) ctl='systemctl' ;;
*) ctl='loginctl' ;;
esac

case "$(printf "Lock\nDisplay off\nLogout\nSleep\nReboot\nShutdown" | dmenu -p "Choose:" -i -nb "#32302f" -nf "#bbbbbb" -sb "#477D6F" -sf "#eeeeee")" in
'Lock') slock ;;
'Logout') kill -TERM "$(pgrep -u "$USER" "\bdwm$")" ;;
'Sleep') slock $ctl suspend ;;
'Reboot') $ctl reboot ;;
'Shutdown') $ctl poweroff ;;
*) exit 1 ;;
esac

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

## Audio
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
sed -i '19s/.*/static const char col_cyan[]        = "#477D6F";/' ~/.config/dwm-6.2/config.h
cd ~/.config/dwm-6.2/ 
make clean 
make
cd
feh --bg-fill "$(find ~/wall -type f | shuf -n 1)"
xdotool key super+shift+q

## Favourite Wallpaper
#super + c
sed -i '19s/.*/static const char col_cyan[]        = "#676085";/' ~/.config/dwm-6.2/config.h
cd ~/.config/dwm-6.2/ 
make clean 
make
cd
feh --bg-fill ~/wall/228.png
xdotool key super+shift+q
