#!/bin/sh

dwm_pulse() {
	VOL=$(pamixer --get-volume)
	STATE=$(pamixer --get-mute)

	MVOL1=$(amixer -D pulse sget Capture | grep 'Left:' | awk -F'[][]' '{ print $2 }' | xargs)
	MVOL2=$(amixer -D pulse sget Capture | grep 'Mono:' | awk -F'[][]' '{ print $2 }' | xargs)
	if [[ "$MVOL1" != "" ]]; then
		MVOL="${MVOL1}"
	elif [[ "$MVOL2" != "" ]]; then
		MVOL="${MVOL2}"
	fi
	MSTATE=$(amixer -D pulse get Capture | sed 5q | tail -1 | awk -F " " '{print $NF}' | xargs)

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

	if [ "$MSTATE" = "[off]" ] || [ "$VOL" -eq 0 ]; then
		printf "  🎤🔇"
	else
		printf "  🎤 %s%" "$MVOL"
	fi

	printf "%s" "$SEP2"
}

dwm_pulse
