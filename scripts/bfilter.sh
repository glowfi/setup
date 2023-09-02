#!/usr/bin/env bash

current_hour=$(date +%k)

if ((current_hour >= 6 && current_hour < 18)); then
	echo "Daytime!"
	redshift -P -O 6500K
else
	echo "Nighttime!"
	redshift -P -O 4500K
fi
