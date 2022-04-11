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
feh --bg-fill "$(find $HOME/wall -type f -name *.jpg -o -name *.png | shuf -n 1)"
cd
cat .fehbg | tail -1 | awk '{print $NF}' | awk -F"/" '{print $5}' | tr -d "'" | xargs -I {} wal -s -q -t --backend haishoku -i ~/wall/{}
sed -i '9,11d' ~/.cache/wal/colors-wal-dwm.h
sed -i '14d' ~/.cache/wal/colors-wal-dwm.h
cd ~/.config/dwm-6.2/
make clean
make
cd
xdotool key super+shift+q
