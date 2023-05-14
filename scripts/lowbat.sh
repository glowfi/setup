#!/bin/bash

# Set the battery threshold (in percentage)
THRESHOLD1=30
THRESHOLD2=20
THRESHOLD3=10

clearCache=0

# Check if the laptop is running on battery power
while true; do
	if [[ $(acpi -a | grep off-line) ]]; then
		# Get the battery level
		BATTERY_LEVEL=$(acpi -b | awk '{print $4}' | tr -d '%,')

		if [ -e "$HOME/.cache/lowbat30" ]; then
			true
		else
			# Send a notification if the battery level is below the threshold
			if [[ $BATTERY_LEVEL -lt $THRESHOLD1 ]]; then
				touch "$HOME/.cache/lowbat30"
				notify-send "🪫Low Battery Warning" "Battery level is at $BATTERY_LEVEL%"
			fi

		fi

		if [ -e "$HOME/.cache/lowbat20" ]; then
			true
		else
			# Send a notification if the battery level is below the threshold
			if [[ $BATTERY_LEVEL -lt $THRESHOLD2 ]]; then
				touch "$HOME/.cache/lowbat20"
				notify-send "🪫Low Battery Warning" "Battery level is at $BATTERY_LEVEL%"
			fi

		fi

		if [ -e "$HOME/.cache/lowbat15" ]; then
			true
		else
			# Send a notification if the battery level is below the threshold
			if [[ $BATTERY_LEVEL -lt $THRESHOLD3 ]]; then
				touch "$HOME/.cache/lowbat15"
				notify-send "🪫Low Battery Warning" "Battery level is at $BATTERY_LEVEL%"
			fi

		fi
	fi
	((clearCache = clearCache + 1))
	if [ $(($clearCache % 450)) -eq 0 ]; then
		find "$HOME/.cache/" -name 'lowbat*' -delete
	fi
done
