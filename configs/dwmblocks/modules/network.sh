#!/bin/sh

dwm_networkmanager() {

	CONNAME=$(nmcli -a | grep 'Wired connection' | awk 'NR==1{print $1}')

	printf "%s" "$SEP1"
	if [ "$CONNAME" = "" ]; then
		CONNAME=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -c 5-)
	fi
	printf "%s" "$SEP2"
	if [ "$CONNAME" = "" ]; then
		printf "❌ %s\n" "noWifi"
	else
		printf "🌐 %s\n" "$CONNAME"
	fi
}

dwm_networkmanager
