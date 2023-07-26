#!/bin/bash

getChoice=$(echo -e "1.Install Powerplan\n2.Remove Powerplan\n3.Force Powersave\n4.Force Performance" | dmenu -i -p "Choose:" | awk -F"." '{print $1}')

if [[ "$getChoice" = "1" ]]; then
	sudo -A auto-cpufreq --install
elif [[ "$getChoice" = "2" ]]; then
	sudo -A auto-cpufreq --remove
elif [[ "$getChoice" = "3" ]]; then
	sudo -A auto-cpufreq --force=powersave
elif [[ "$getChoice" = "4" ]]; then
	sudo -A auto-cpufreq --force=performance
fi
