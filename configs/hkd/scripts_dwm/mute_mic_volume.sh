#!/bin/sh

amixer -D pulse sset Capture toggle
pkill -RTMIN+10 dwmblocks
MVOL=$(amixer -D pulse sget Capture | grep 'Left:' | awk -F'[][]' '{ print $2 }')
MSTATE=$(amixer -D pulse get Capture | sed 5q | tail -1 | awk -F " " '{print $NF}')
if [ "$MSTATE" = "[on]" ] || [ "$VOL" -eq 0 ]; then
	volnoti-show $MVOL
else
	volnoti-show -m
fi
