#!/bin/sh

VOL=$(pamixer --get-volume)
STATE=$(pamixer --get-mute)
pamixer -t
pkill -RTMIN+10 dwmblocks
if [ "$STATE" = "true" ] || [ "$VOL" -eq 0 ]; then
	volnoti-show $VOL
else
	volnoti-show -m
fi
