#!/bin/sh

### Plasma Bindings

## File Manager
#super + f
dolphin

## System Settings
#super + u
systemsettings5

## Toggle Panel
#alt + p
qdbus org.kde.plasmashell /PlasmaShell evaluateScript "p = panelById(panelIds[0]); p.height = p.height>=25?-1:25;"

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
	qdbus org.kde.plasmashell /PlasmaShell evaluateScript "p = panelById(panelIds[0]); p.location = 'top';p.height = 25;"
	notify-send 'Tiling Mode'
fi
qdbus org.kde.KWin /KWin reconfigure

## Logout/Restart/Shutdown
#super+x
qdbus org.kde.ksmserver /KSMServer org.kde.KSMServerInterface.logout -1 -1 -1

### Global bindings

## Terminal
#super + t
kitty

## Browser
#super + b
firefox --new-tab "https://duckduckgo.com/?kae=d"

## Browser Custom Tab
#alt + t
firefox --new-tab "https://duckduckgo.com/?kae=d"

## Alternate Browser
#super + shift + b
brave

## Screenshot
#alt + a
windowshot.sh

## Dmenu
#super + w
dmenu_run -p "Run:" -i

## Intelligent Tools
#alt + i
int.sh

## Kill Process
#alt + k
getProcess=$(ps aux | sed "1d" | dmenu -i -l 20 -p "Kill:")
pid=$(echo "$getProcess" | awk '{print $2}' | xargs)
kill -9 "$pid"
processName=$(echo "$getProcess" | awk '{print $NF}' | xargs)
killall -9 "$processName"
