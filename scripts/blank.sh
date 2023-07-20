#!/usr/bin/env bash

tmpfile="$HOME/.cache/blank"

generate() {
    echo "generate!"
    touch "$tmpfile"
    ps aux | grep -E "wall.sh" | head | awk '{print $2}'|head -1|xargs -I {} kill -9 "{}";killall wall.sh
    convert -size 1920x1080 xc:black png:- | feh --bg-fill -
}

restore(){
    echo "restore!"
    sh $HOME/.local/bin/wall.sh &
    rm -rf "$tmpfile"
}


if [[ -f "$tmpfile" ]]; then
    restore
else
    generate
fi
