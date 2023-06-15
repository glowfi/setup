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

case "$(printf "Lock\nDisplay off\nSleep\nReboot\nShutdown" | dmenu -p "Choose:" -i)" in
'Lock') slock ;;
'Display off') xset dpms force off ;;
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
#alt + a
sed -i '126s/.*/fading = false;/' ~/.config/picom/picom.conf
windowshot.sh
sed -i '126s/.*/fading = true;/' ~/.config/picom/picom.conf

## Scrap YT
#super + y
fish -c "sYT -p "dmenu""

## Random Wallpaper
#super + z
feh --bg-fill "$(find ~/wall -type f | shuf -n 1)"

## Favourite Wallpaper
#super + c
randWall=$(printf "136.png\n53.jpg" | shuf -n 1)
feh --bg-fill ~/wall/"$randWall"

## Clipboard
#super + e
clipmenu

## Intelligent Tools
#alt + i
sed -i '126s/.*/fading = false;/' ~/.config/picom/picom.conf
int.sh
sed -i '126s/.*/fading = true;/' ~/.config/picom/picom.conf

## Kill Process
#alt + k
getProcess=$(ps aux | sed "1d" | dmenu -i -l 20 -p "Kill:")
pid=$(echo "$getProcess" | awk '{print $2}' | xargs)
kill -9 "$pid"
processName=$(echo "$getProcess" | awk '{print $NF}' | xargs)
killall -9 "$processName"

## Activate Deactivate Easyeffects
#alt + g
isRunning=$(ps aux | grep "easyeffects" | wc -lc | xargs | cut -d" " -f1)

if [[ "$isRunning" = "2" ]]; then
	getProcess=$(ps aux | grep "easyeffects" | head -1)
	pid=$(echo "$getProcess" | awk '{print $2}' | xargs)
	kill -9 "$pid"
	dunstify -I ~/.misc/easyno.png "Easyeffects Deactivated!"
	rm nohup.out
else
	nohup easyeffects --gapplication-service &
	dunstify -I ~/.misc/easy.png "Easyeffects Activated!"
	rm ~/nohup.out
fi

## Increase Volume
#super + F8
pamixer -i 5 --allow-boost
pkill -RTMIN+10 dwmblocks
VOL=$(pamixer --get-volume)
STATE=$(pamixer --get-mute)
cap=100
if [ "$VOL" -gt "$cap" ]; then
	volnoti-show 100
else
	if [ "$STATE" = "true" ] || [ "$VOL" -eq 0 ]; then
		volnoti-show -m
	else
		volnoti-show $VOL
	fi
fi

## Decrease Volume
#super + F7
pamixer -d 5 --allow-boost
pkill -RTMIN+10 dwmblocks
VOL=$(pamixer --get-volume)
STATE=$(pamixer --get-mute)
cap=100
if [ "$VOL" -gt "$cap" ]; then
	volnoti-show 100
else
	if [ "$STATE" = "true" ] || [ "$VOL" -eq 0 ]; then
		volnoti-show -m
	else
		volnoti-show $VOL
	fi
fi

## Mute/Unmute Volume
#super + F6
VOL=$(pamixer --get-volume)
STATE=$(pamixer --get-mute)
pamixer -t
pkill -RTMIN+10 dwmblocks
if [ "$STATE" = "true" ] || [ "$VOL" -eq 0 ]; then
	volnoti-show $VOL
else
	volnoti-show -m
fi

## Increase Brightness
#super + F3
brightnessctl s 30+
pkill -RTMIN+10 dwmblocks
currBrightness=$(brightnessctl | head -2 | tail -1 | xargs | cut -d '(' -f2 | cut -d ')' -f1 | tr -d "%" | xargs)
cap=100
if [ "$currBrightness" -gt "$cap" ]; then
	volnoti-show 100
else
	if [ "$currBrightness" -eq 0 ]; then
		volnoti-show -m
	else
		volnoti-show -s /usr/share/pixmaps/volnoti/display-brightness-symbolic.svg $currBrightness
	fi
fi

## Decrease Brightness
#super + F2
brightnessctl s 30-
pkill -RTMIN+10 dwmblocks
currBrightness=$(brightnessctl | head -2 | tail -1 | xargs | cut -d '(' -f2 | cut -d ')' -f1 | tr -d "%")
cap=100
if [ "$currBrightness" -gt "$cap" ]; then
	volnoti-show 100
else
	if [ "$currBrightness" -eq 0 ]; then
		volnoti-show -s /usr/share/pixmaps/volnoti/display-brightness-symbolic.svg $currBrightness
	else
		volnoti-show -s /usr/share/pixmaps/volnoti/display-brightness-symbolic.svg $currBrightness
	fi
fi

## Decrease Mic Volume
#super + F9
amixer sset Capture 5%-
pkill -RTMIN+10 dwmblocks
MVOL=$(amixer -D pulse sget Capture | grep 'Left:' | awk -F'[][]' '{ print $2 }')
MSTATE=$(amixer get Capture | sed 5q | tail -1 | awk -F " " '{print $NF}')
cap=100
if [ "$VOL" -gt "$cap" ]; then
	volnoti-show 100
else
	if [ "$MSTATE" = "true" ] || [ "$VOL" -eq 0 ]; then
		volnoti-show -m
	else
		volnoti-show $MVOL
	fi
fi

## Increase Mic Volume
#super + F11
amixer sset Capture 5%+
pkill -RTMIN+10 dwmblocks
MVOL=$(amixer -D pulse sget Capture | grep 'Left:' | awk -F'[][]' '{ print $2 }')
MSTATE=$(amixer get Capture | sed 5q | tail -1 | awk -F " " '{print $NF}')
cap=100
if [ "$VOL" -gt "$cap" ]; then
	volnoti-show 100
else
	if [ "$MSTATE" = "true" ] || [ "$VOL" -eq 0 ]; then
		volnoti-show -m
	else
		volnoti-show $MVOL
	fi
fi

## Mute/Unmute Mic Volume
#super + F10
amixer -D pulse sset Capture toggle
pkill -RTMIN+10 dwmblocks
MVOL=$(amixer -D pulse sget Capture | grep 'Left:' | awk -F'[][]' '{ print $2 }')
MSTATE=$(amixer get Capture | sed 5q | tail -1 | awk -F " " '{print $NF}')
if [ "$MSTATE" = "[on]" ] || [ "$VOL" -eq 0 ]; then
	volnoti-show $MVOL
else
	volnoti-show -m
fi
