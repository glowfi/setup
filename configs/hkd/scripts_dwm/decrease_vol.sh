#!/bin/sh

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
