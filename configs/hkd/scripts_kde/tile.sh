#!/bin/sh

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
