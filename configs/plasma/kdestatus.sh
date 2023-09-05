#!/usr/bin/env bash

SEP1=" | "
SEP2=" | "

kde_brightness() {

	printf "%s" "$SEP1"

	# Print Output
	output=$(brightnessctl | head -2 | tail -1 | xargs | cut -d '(' -f2 | cut -d ')' -f1)
	printf "☀ %s\n" "$output"

	printf "%s" "$SEP2"
}

kde_nettraf() {

	case $BLOCK_BUTTON in
	1) setsid -f "$TERMINAL" -e bmon ;;
	3) notify-send "🌐 Network traffic module" "🔻: Traffic received
        🔺: Traffic transmitted" ;;
	6) "$TERMINAL" -e "$EDITOR" "$0" ;;
	esac

	update() {
		sum=0
		for arg; do
			read -r i <"$arg"
			sum=$((sum + i))
		done
		cache=${XDG_CACHE_HOME:-$HOME/.cache}/${1##*/}
		[ -f "$cache" ] && read -r old <"$cache" || old=0
		printf %d\\n "$sum" >"$cache"
		printf %d\\n $((sum - old))
	}

	rx=$(update /sys/class/net/[ew]*/statistics/rx_bytes)
	tx=$(update /sys/class/net/[ew]*/statistics/tx_bytes)

	# Print Output
	printf " %3sB   %3sB\\n" $(numfmt --to=iec $rx $tx)
}

kde_resources() {
	df_check_location='/home'

	printf "%s" "$SEP1"

	# Get all the infos first to avoid high resources usage
	free_output=$(free -h --si | grep Mem)
	df_output=$(df -h $df_check_location | tail -n 1)

	# Used and total memory
	MEMUSED=$(echo $free_output | awk '{print $3}')
	MEMTOT=$(echo $free_output | awk '{print $2}')

	# CPU temperature
	CPU=$(top -bn1 | grep Cpu | awk '{print $2}')%

	# Used and total storage in /home (rounded to 1024B)
	STOUSED=$(echo $df_output | awk '{print $3}')
	STOTOT=$(echo $df_output | awk '{print $2}')
	STOPER=$(echo $df_output | awk '{print $5}')

	# Print Output
	printf "󰍛 %s/%s  🖥 %s  󰋊 %s/%s:%s" "$MEMUSED" "$MEMTOT" "$CPU" "$STOUSED" "$STOTOT" "$STOPER"

	printf "%s" "$SEP2"
	echo ""
}

kde_pulse() {
	VOL=$(pamixer --get-volume)
	STATE=$(pamixer --get-mute)

	MVOL=$(amixer -D pulse sget Capture | grep 'Left:' | awk -F'[][]' '{ print $2 }' | xargs)
	MSTATE=$(amixer -D pulse get Capture | sed 5q | tail -1 | awk -F " " '{print $NF}' | xargs)

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
		printf " 󰍭"
	else
		printf " 󰍮 %s%" "$MVOL"
	fi
}

output() {
	kde_brightness
	kde_nettraf
	kde_resources
	kde_pulse
}

out=$(output)

echo "$out" | tr "\n" " "
