#!/bin/sh

dwm_time_date() {

	printf "%s" "$SEP1"
	output=$(date '+Date: %b %d %a %y Time: %I:%M%p')
	printf "%s\n" "$output"
}

dwm_time_date
