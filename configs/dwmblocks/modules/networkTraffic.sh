#!/bin/sh

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
printf "🔻%3sB 🔺%2sB\\n" $(numfmt --to=iec $rx $tx)
