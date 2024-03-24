#!/bin/sh

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
