#!/bin/sh

choice=$(printf "Connect\nDisconnect" | dmenu -p "Select:" -i -nb "#32302f" -nf "#bbbbbb" -sb "#477D6F" -sf "#eeeeee" -l 10)

if [[ "$choice" = "Connect" ]]; then
	bssid=$(nmcli device wifi list | sed -n '1!p' | cut -b 9- | dmenu -p "Select Wifi 📶:" -i -nb "#32302f" -nf "#bbbbbb" -sb "#477D6F" -sf "#eeeeee" -l 10 | cut -d " " -f1)
	password=$(echo >/dev/null | dmenu -i -nb "#32302f" -nf "#bbbbbb" -sb "#477D6F" -sf "#eeeeee" -p "Password 🔑:")
	nmcli device wifi connect "$bssid" password "$password"
	notify-send "Connected to wifi!"

elif [[ "$choice" = "Disconnect" ]]; then
	currentNetwork=$(iwgetid -r)
	nmcli con down id "$currentNetwork"
	notify-send "Disconnected from wifi!"
fi
