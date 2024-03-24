#!/bin/sh

VOL=$(pamixer --get-volume)
STATE=$(pamixer --get-mute)
pamixer -t
if [ "$STATE" = "true" ] || [ "$VOL" -eq 0 ]; then
	notify-send "$VOL [Speaker]"
else
	notify-send "Volume on mute! [Speaker]"
fi
