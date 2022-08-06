#!/bin/sh

dwm_pulse() {
	VOL=$(pamixer --get-volume)
	STATE=$(pamixer --get-mute)

	printf "%s" "$SEP1"

	# Print Output
	if [ "$STATE" = "true" ] || [ "$VOL" -eq 0 ]; then
		printf "🔇"
	elif [ "$VOL" -gt 0 ] && [ "$VOL" -le 33 ]; then
		printf "🔈 %s%%" "$VOL"
	elif [ "$VOL" -gt 33 ] && [ "$VOL" -le 66 ]; then
		printf "🔉 %s%%" "$VOL"
	else
		printf "🔊 %s%%" "$VOL"
	fi

	printf "%s" "$SEP2"
}

dwm_pulse
