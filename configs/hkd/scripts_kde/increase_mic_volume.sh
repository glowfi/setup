#!/bin/sh

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
