#!/bin/sh

dwm_time_date() {

    printf "%s" "$SEP1"

    # Print Output
    output=$(date '+📅 %b %d %a %y  🕒 %I:%M%p')
    printf "%s\n" "$output"

    printf "%s" "$SEP2"
}

dwm_time_date
