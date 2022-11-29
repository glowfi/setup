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

case "$(printf "Lock\nDisplay off\nLogout\nSleep\nReboot\nShutdown" | dmenu -p "Choose:" -i)" in
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
firefox

## Network
#super + n
kitty -e "nmtui"

## Audio
#super + v
kitty -e "pulsemixer"

## Screenshot
#alt + a
windowshot.sh

## Scrap YT
#super + y
fish -c "sYT -p "dmenu""

## Random Wallpaper
#super + z
feh --bg-fill "$(find ~/wall -type f | shuf -n 1)"

## Favourite Wallpaper
#super + c
randWall=$(printf "14.png\n76.jpg" | shuf -n 1)
feh --bg-fill ~/wall/"$randWall"

## Clipboard
#super + e
clipmenu

## Intelligent Tools
#alt + i
int.sh

## Kill Process
#alt + k
process=$(ps aux | sed "1d" | dmenu -i -l 20 -p "Kill:" | awk '{print $NF}')
killall "$process"

## Increase Volume
#super + F8
pamixer -i 5 --allow-boost
pkill -RTMIN+10 dwmblocks

## Decrease Volume
#super + F7
pamixer -d 5 --allow-boost
pkill -RTMIN+10 dwmblocks

## Mute/Unmute Mic Volume
#super + F6
pamixer -t
pkill -RTMIN+10 dwmblocks

## Increase Brightness
#super + F3
brightnessctl s 30+
pkill -RTMIN+10 dwmblocks

## Decrease Brightness
#super + F2
brightnessctl s 30-
pkill -RTMIN+10 dwmblocks

## Decrease Mic Volume
#super + F9
amixer sset Capture 5%-
pkill -RTMIN+10 dwmblocks

## Increase Mic Volume
#super + F11
amixer sset Capture 5%+
pkill -RTMIN+10 dwmblocks

## Mute/Unmute Mic Volume
#super + F10
amixer -D pulse sset Capture toggle
pkill -RTMIN+10 dwmblocks
