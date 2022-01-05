#!/bin/sh

dwm_brightness () {

    printf "%s" "$SEP1"
    output=$(brightnessctl | head -2 | tail -1|xargs|cut -d '(' -f2 | cut -d ')' -f1)
    printf "☀ %s\n" "$output"
}

dwm_brightness
