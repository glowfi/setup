#!/bin/sh

amixer -D pulse sset Capture 5%-
pkill -RTMIN+10 dwmblocks
MVOL=$(amixer -D pulse sget Capture | grep 'Left:' | awk -F'[][]' '{ print $2 }')
MSTATE=$(amixer get Capture | sed 5q | tail -1 | awk -F " " '{print $NF}')
cap=100
if [ "$VOL" -gt "$cap" ]; then
	volnoti-show 100
else
	if [ "$MSTATE" = "true" ] || [ "$VOL" -eq 0 ]; then
		volnoti-show -m
	else
		volnoti-show $MVOL
	fi
fi
