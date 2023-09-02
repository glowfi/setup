#!/usr/bin/env bash

isDay="no"
isNight="no"

while true; do
	current_hour=$(date +%k)

	if ((current_hour >= 6 && current_hour < 18)); then
		if [[ "$isDay" = "no" ]]; then
			isDay="yes"
			isNight="no"
			redshift -P -O 6500K
			echo "Day!"
		fi
	else
		if [[ "$isNight" = "no" ]]; then
			isDay="no"
			isNight="yes"
			redshift -P -O 4500K
			echo "Night!"
		fi
	fi
done
