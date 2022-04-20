#!/bin/sh
while true; do
	feh --bg-fill "$(find ~/wall -type f | shuf -n 1)"
	cd
	cat .fehbg | tail -1 | awk '{print $NF}' | awk -F"/" '{print $5}' | tr -d "'" | xargs -I {} wal -s -q -t --backend haishoku -i ~/wall/{}
	sed -i '9,11d' ~/.cache/wal/colors-wal-dwm.h
	sed -i '14d' ~/.cache/wal/colors-wal-dwm.h
	cd ~/.config/dwm-6.2/
	make clean
	make
	cd
	sleep 900s
done &
