#!/bin/sh

### Plasma Bindings

## File Manager
#super + f
dolphin

## System Settings
#super + u
export QT_QPA_PLATFORMTHEME=
systemsettings

## Toggle Panel
#alt + p
qdbus org.kde.plasmashell /PlasmaShell evaluateScript "p = panelById(panelIds[0]); p.height = p.height>=35?-1:35;"

## Toggle Tiling/Floating mode
#alt + t
current=$(kreadconfig5 --file kwinrc --group Plugins --key krohnkiteEnabled)

if [ $current = "true" ]; then
	kwriteconfig5 --file kwinrc --group Plugins --key krohnkiteEnabled false
	kwriteconfig5 --file kwinrc --group Plugins --key diminactiveEnabled false
	kwriteconfig5 --file breezerc --group "Windeco Exception 0" --key Enabled false
	qdbus org.kde.plasmashell /PlasmaShell evaluateScript "p = panelById(panelIds[0]); p.location = 'bottom';p.height = 44;"
	notify-send 'Normal Mode'

elif [ $current = "false" ]; then
	kwriteconfig5 --file kwinrc --group Plugins --key krohnkiteEnabled true
	kwriteconfig5 --file kwinrc --group Plugins --key diminactiveEnabled true
	kwriteconfig5 --file breezerc --group "Windeco Exception 0" --key Enabled true
	qdbus org.kde.plasmashell /PlasmaShell evaluateScript "p = panelById(panelIds[0]); p.location = 'top';p.height = 35;"
	notify-send 'Tiling Mode'
fi
qdbus org.kde.KWin /KWin reconfigure

## Logout/Restart/Shutdown
#super+x
qdbus org.kde.ksmserver /KSMServer org.kde.KSMServerInterface.logout -1 -1 -1

## PlasmaShell Replace
#super+shift+q
nohup plasmashell --replace

### Global bindings

## Terminal
#super + t
kitty

## Browser
#super + b
choice=$(echo -e "1.Default Profile[Brave]\n2.Temp Profile[Brave]\n3.Librewolf" | dmenu -p "Choose Profile :" -i | awk -F"." '{print $1}')
if [[ "$choice" != "" ]]; then
	if [[ "$choice" = "1" ]]; then
		brave --profile-directory=Default
	elif [[ "$choice" = "2" ]]; then
		brave --profile-directory="Tmp"
	elif [[ "$choice" = "3" ]]; then
		libw "librewolf:$(date +%s)"
fi

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

## Dmenu
#super + p
dmenu_run -p "Run:" -i

## Scrap YT
#super + y
fish -c "sYT -p "dmenu""

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
favwall=$(printf "143.jpg\n40.png" | shuf -n 1)
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
sed -i '126s/.*/fading = false;/' ~/.config/picom/picom.conf
int.sh
sed -i '126s/.*/fading = true;/' ~/.config/picom/picom.conf

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
brightnessctl s 30+
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
brightnessctl s 30-
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
