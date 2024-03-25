#!/bin/sh

choice=$(echo -e "1.Default Profile[Brave]\n2.Temp Profile[Brave]\n3.Default Profile[Librewolf]" | bemenu -p "Choose Profile :" -i | awk -F"." '{print $1}')
if [[ "$choice" != "" ]]; then
	if [[ "$choice" = "1" ]]; then
		brave --profile-directory=Default
	elif [[ "$choice" = "2" ]]; then
		brave --profile-directory="Tmp"
	elif [[ "$choice" = "3" ]]; then
		~/.local/bin/libw "librewolf:$(date +%s)" "default-default" "librewolf"
	fi
fi
