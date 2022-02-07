#!/bin/sh

dwm_time_date() {

	printf "%s" "$SEP1"
	output=$(date '+📅 %b %d %a %y  🕒 %I:%M%p')
	printf "%s\n" "$output"
}

dwm_time_date
