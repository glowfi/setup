#!/bin/sh

## File Manager
#super + f
fish -c "pcmanfm"

## Logout/Restart/Shutdown
#super+x
varInit=$(cat /proc/1/comm)
if [[ "$varInit" = "systemd" ]]; then
	ctl="systemctl"
else
	ctl="loginctl"
fi
case "$(printf "Lock\nSleep\nReboot\nShutdown" | dmenu -p "Choose:" -i)" in
'Lock') slock ;;
'Sleep') "$ctl" suspend ;;
'Reboot') "$ctl" reboot ;;
'Shutdown') "$ctl" poweroff ;;
*) exit 1 ;;
esac

### Global bindings

## Terminal
#super + t
kitty

## Browser
#super + b
choice=$(echo -e "1.Default Profile[Brave]\n2.Temp Profile[Brave]\n3.Default Profile[Librewolf]" | dmenu -p "Choose Profile :" -i | awk -F"." '{print $1}')
if [[ "$choice" != "" ]]; then
	if [[ "$choice" = "1" ]]; then
		brave --profile-directory=Default
	elif [[ "$choice" = "2" ]]; then
		brave --profile-directory="Tmp"
	elif [[ "$choice" = "3" ]]; then
		~/.local/bin/libw "librewolf:$(date +%s)" "default-default" "librewolf"
	fi
fi

## Network
#super + n
kitty -e "nmtui"

## Audio
#super + v
kitty -e "pulsemixer"

## Screenshot
#alt + a
sed -i "35s/.*/fading = false;/" .config/picom/picom.conf
windowshot.sh
sed -i "35s/.*/fading = true;/" .config/picom/picom.conf

## Scrap YT
#super + y
fish -c "sYT -p "dmenu""

## Random Wallpaper
#super + z
feh --bg-fill "$(fd . ~/wall/ --type file | shuf -n 1)"

## Favourite Wallpaper
#super + c
randWall=$(printf "143.jpg\n40.png\n103.png" | shuf -n 1)
feh --bg-fill ~/wall/"$randWall"

## Clipboard
#super + e
clipmenu

## Intelligent Tools
#alt + i
int.sh

## Kill Process
#alt + k
$HOME/.local/bin/killprocess.sh "unattended"

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
amixer -D pulse sset Capture 5%-
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
amixer -D pulse sset Capture 5%+
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
MSTATE=$(amixer -D pulse get Capture | sed 5q | tail -1 | awk -F " " '{print $NF}')
if [ "$MSTATE" = "[on]" ] || [ "$VOL" -eq 0 ]; then
	volnoti-show $MVOL
else
	volnoti-show -m
fi
