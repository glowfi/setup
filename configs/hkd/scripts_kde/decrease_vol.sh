#!/bin/sh

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
