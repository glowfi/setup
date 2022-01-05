#!/bin/sh

dwm_pulse() {
	VOL=$(pamixer --get-volume)
	STATE=$(pamixer --get-mute)

	printf "%s" "$SEP1"
	if [ "$STATE" = "true" ] || [ "$VOL" -eq 0 ]; then
		printf "Muted"
	elif [ "$VOL" -gt 0 ] && [ "$VOL" -le 33 ]; then
		printf "Volume: %s%%" "$VOL"
	elif [ "$VOL" -gt 33 ] && [ "$VOL" -le 66 ]; then
		printf "Volume: %s%%" "$VOL"
	else
		printf "Volume: %s%%" "$VOL"
	fi
	printf "%s" "$SEP2"
}

dwm_pulse
