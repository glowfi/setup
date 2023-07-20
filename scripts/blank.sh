#!/usr/bin/env bash

tmpfile="$HOME/.cache/blank"

generate() {
    echo "generate!"
    touch "$tmpfile"
    ps aux | grep -E "wall.sh" | head | awk '{print $2}'|head -1|xargs -I {} kill -9 "{}";
    ps aux | grep -E "xautolock" | head | awk '{print $2}'|head -1|xargs -I {} kill -9 "{}";
    convert -size 1920x1080 xc:black png:- | feh --bg-fill -
    xdotool key alt+b
}

restore(){
    echo "restore!"
    sh $HOME/.local/bin/wall.sh &
    xautolock -time 10 -locker $HOME/.local/bin/screenlocker &
    rm -rf "$tmpfile"
    xdotool key alt+b
}


if [[ -f "$tmpfile" ]]; then
    restore
else
    generate
fi
