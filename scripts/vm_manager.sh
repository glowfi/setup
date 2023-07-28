#!/usr/bin/env bash

# Virtual Machines Location
VM_PATH="$HOME/Downloads/VMS/"

# Choose VM
vmlist=$(fd . "$VM_PATH" --type directory --max-depth 1 | rev | cut -d"/" -f2 | rev)
choice1=$(echo "$vmlist" | fzf --prompt "Choose VM:")

# Perform the choosen task
if [[ "$choice1" != "" ]]; then
	# Choose what to do
	choice2=$(echo -e "1.Start VM\n2.Fallback Start Script\n3.Close VM\n4.Delete VM" | fzf | awk -F"." '{print $1}')
	cd "${VM_PATH}/${choice1}"

	if [[ "$choice2" != "" && "$choice2" == "4" ]]; then
		cd
		rm -rf "${VM_PATH}/${choice1}"
	else
		if [[ "$choice2" != "" ]]; then
			if [[ "$choice2" == "1" ]]; then
				./start.sh
			elif [[ "$choice2" == "2" ]]; then
				./fallback-start.sh
			elif [[ "$choice2" == "3" ]]; then
				./clean.sh
			fi
		fi
	fi
fi
