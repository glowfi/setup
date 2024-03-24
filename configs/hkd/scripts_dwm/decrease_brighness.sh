#!/bin/sh

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
