#!/bin/sh

### Plasma Bindings

## File Manager
#super + f
dolphin

## System Settings
#super + u
systemsettings

## Toggle Panel
#alt + p
qdbus6 org.kde.plasmashell /PlasmaShell evaluateScript "p = panelById(panelIds[0]); p.height = p.height>=35?-1:35;"

## Toggle Tiling/Floating mode
#alt + t
FILE="$HOME/.config/tiling"

if [ -f "$FILE" ]; then
	ps aux | grep -E "cortile" | head | awk '{print $2}' | head -1 | xargs -I {} kill -9 "{}"
	killall -9 "cortile"
	rm "$FILE"
	kwriteconfig6 --file kwinrc --group Plugins --key diminactiveEnabled false
	kwriteconfig6 --file breezerc --group "Windeco Exception 0" --key Enabled false
	qdbus6 org.kde.plasmashell /PlasmaShell evaluateScript "p = panelById(panelIds[0]); p.location = 'bottom';p.height = 44;"
	sed -i '$d' ~/.xprofile
	sed -i '$d' ~/.xprofile
	sed -i '$d' ~/.xprofile
	notify-send 'Normal Mode'
	qdbus6 org.kde.KWin /KWin reconfigure
else
	nohup $HOME/.config/cortile/cortile &
	touch "$FILE"
	kwriteconfig6 --file kwinrc --group Plugins --key diminactiveEnabled true
	kwriteconfig6 --file breezerc --group "Windeco Exception 0" --key Enabled true
	qdbus6 org.kde.plasmashell /PlasmaShell evaluateScript "p = panelById(panelIds[0]); p.location = 'top';p.height = 35;"
	echo -e "\n# Cortile\n~/.config/cortile/cortile &" >>~/.xprofile
	notify-send 'Tiling Mode'
	qdbus6 org.kde.KWin /KWin reconfigure
fi

## Logout/Restart/Shutdown
#super+x
varInit=$(cat /proc/1/comm)
if [[ "$varInit" = "systemd" ]]; then
	ctl="systemctl"
else
	ctl="loginctl"
fi
case "$(printf "Lock\nSleep\nReboot\nShutdown" | bemenu -p "Choose:" -i)" in
'Lock') qdbus org.freedesktop.ScreenSaver /ScreenSaver Lock ;;
'Sleep') "$ctl" suspend ;;
'Reboot') "$ctl" reboot ;;
'Shutdown') "$ctl" poweroff ;;
*) exit 1 ;;
esac

## PlasmaShell Replace
#super+shift+q
nohup plasmashell --replace &

### Global bindings

## Terminal
#super + t
kitty

## Browser
#super + b
choice=$(echo -e "1.Default Profile[Brave]\n2.Temp Profile[Brave]\n3.Default Profile[Librewolf]" | bemenu -p "Choose Profile :" -i | awk -F"." '{print $1}')
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
#Print
sed -i '126s/.*/fading = false;/' ~/.config/picom/picom.conf
windowshot.sh
sed -i '126s/.*/fading = true;/' ~/.config/picom/picom.conf

## bemenu
#super + p
bemenu-run -p "Run:" -i

## Scrap YT
#super + y
fish -c "sYT -p "bemenu""

## NighColor
#super + r
FILE="$HOME/.config/nightcolor"

if [ -f "$FILE" ]; then
	notify-send "NighColor Disabled!"
	rm ""${FILE}
	redshift -x
else
	notify-send "NighColor Enabled!"
	touch "${FILE}"
	redshift -P -O 4500K
fi

## Random Wallpaper
#super + z
randImage=$(fd . ~/wall/ --type file | shuf -n 1)
dbus-send --session --dest=org.kde.plasmashell --type=method_call /PlasmaShell org.kde.PlasmaShell.evaluateScript "string:
var Desktops = desktops();                                                                                                                       
for (i=0;i<Desktops.length;i++) {
        d = Desktops[i];
        d.wallpaperPlugin = 'org.kde.image';
        d.currentConfigGroup = Array('Wallpaper',
                                    'org.kde.image',
                                    'General');
        d.writeConfig('Image', '$randImage');
}"

## Favourite Wallpaper
#super + c
favwall=$(printf "143.jpg\n40.png\n103.png" | shuf -n 1)
dbus-send --session --dest=org.kde.plasmashell --type=method_call /PlasmaShell org.kde.PlasmaShell.evaluateScript "string:
var Desktops = desktops();                                                                                                                       
for (i=0;i<Desktops.length;i++) {
        d = Desktops[i];
        d.wallpaperPlugin = 'org.kde.image';
        d.currentConfigGroup = Array('Wallpaper',
                                    'org.kde.image',
                                    'General');
        d.writeConfig('Image', '$HOME/wall/$favwall');
}"

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
	notify-send "Easyeffects Deactivated!"
	rm nohup.out
else
	nohup easyeffects --gapplication-service &
	notify-send "Easyeffects Activated!"
	rm ~/nohup.out
fi

## Increase Volume
#super + F8
pamixer -i 5 --allow-boost
VOL=$(pamixer --get-volume)
STATE=$(pamixer --get-mute)
cap=100
if [ "$VOL" -gt "$cap" ]; then
	notify-send "$VOL [Speaker]"
else
	if [ "$STATE" = "true" ] || [ "$VOL" -eq 0 ]; then
		notify-send "Volume on mute! [Speaker]"
	else
		notify-send "$VOL [Speaker]"
	fi
fi

## Decrease Volume
#super + F7
pamixer -d 5 --allow-boost
VOL=$(pamixer --get-volume)
STATE=$(pamixer --get-mute)
cap=100
if [ "$VOL" -gt "$cap" ]; then
	notify-send "$VOL [Speaker]"
else
	if [ "$STATE" = "true" ] || [ "$VOL" -eq 0 ]; then
		notify-send "Volume on mute! [Speaker]"
	else
		notify-send "$VOL [Speaker]"
	fi
fi

## Mute/Unmute Volume
#super + F6
VOL=$(pamixer --get-volume)
STATE=$(pamixer --get-mute)
pamixer -t
if [ "$STATE" = "true" ] || [ "$VOL" -eq 0 ]; then
	notify-send "$VOL [Speaker]"
else
	notify-send "Volume on mute! [Speaker]"
fi

## Increase Brightness
#super + F3
brightnessctl s 1000+
currBrightness=$(brightnessctl | head -2 | tail -1 | xargs | cut -d '(' -f2 | cut -d ')' -f1 | tr -d "%" | xargs)
cap=100
if [ "$currBrightness" -gt "$cap" ]; then
	notify-send 100
else
	if [ "$currBrightness" -eq 0 ]; then
		notify-send "Zero Brightness!"
	else
		notify-send $currBrightness
	fi
fi

## Decrease Brightness
#super + F2
brightnessctl s 1000-
currBrightness=$(brightnessctl | head -2 | tail -1 | xargs | cut -d '(' -f2 | cut -d ')' -f1 | tr -d "%")
cap=100
if [ "$currBrightness" -gt "$cap" ]; then
	notify-send 100
else
	if [ "$currBrightness" -eq 0 ]; then
		notify-send "Zero Brightness!"
	else
		notify-send $currBrightness
	fi
fi

## Decrease Mic Volume
#super + F9
amixer -D pulse sset Capture 5%-
MVOL=$(amixer -D pulse sget Capture | grep 'Left:' | awk -F'[][]' '{ print $2 }')
MSTATE=$(amixer get Capture | sed 5q | tail -1 | awk -F " " '{print $NF}')
cap=100
if [ "$VOL" -gt "$cap" ]; then
	notify-send "$MVOL [Mic]"
else
	if [ "$MSTATE" = "true" ] || [ "$VOL" -eq 0 ]; then
		notify-send "Volume on mute! [Mic]"
	else
		notify-send "$MVOL [Mic]"
	fi
fi

## Increase Mic Volume
#super + F11
amixer -D pulse sset Capture 5%+
MVOL=$(amixer -D pulse sget Capture | grep 'Left:' | awk -F'[][]' '{ print $2 }')
MSTATE=$(amixer get Capture | sed 5q | tail -1 | awk -F " " '{print $NF}')
cap=100
if [ "$VOL" -gt "$cap" ]; then
	notify-send "$MVOL [Mic]"
else
	if [ "$MSTATE" = "true" ] || [ "$VOL" -eq 0 ]; then
		notify-send "Volume on mute! [Mic]"
	else
		notify-send "$MVOL [Mic]"
	fi
fi

## Mute/Unmute Mic Volume
#super + F10
amixer -D pulse sset Capture toggle
MVOL=$(amixer -D pulse sget Capture | grep 'Left:' | awk -F'[][]' '{ print $2 }')
MSTATE=$(amixer -D pulse get Capture | sed 5q | tail -1 | awk -F " " '{print $NF}')
if [ "$MSTATE" = "[on]" ] || [ "$VOL" -eq 0 ]; then
	notify-send "$MVOL [Mic]"
else
	notify-send "Volume on mute! [Mic]"
fi
