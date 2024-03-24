#!/bin/sh

amixer -D pulse sset Capture toggle
MVOL=$(amixer -D pulse sget Capture | grep 'Left:' | awk -F'[][]' '{ print $2 }')
MSTATE=$(amixer -D pulse get Capture | sed 5q | tail -1 | awk -F " " '{print $NF}')
if [ "$MSTATE" = "[on]" ] || [ "$VOL" -eq 0 ]; then
	notify-send "$MVOL [Mic]"
else
	notify-send "Volume on mute! [Mic]"
fi
