#!/usr/bin/env bash

VM_PATH="$HOME/Downloads/VMS/"

# Choose VM
vmlist=$(fd . "$VM_PATH" --type directory --max-depth 1 | rev | cut -d"/" -f2 | rev)
choice1=$(echo "$vmlist" | fzf --prompt "Choose VM:")

# Choose what to do
choice2=$(echo -e "1.Start VM\n2.Fallback Start Script\n3.Close VM" | fzf | awk -F"." '{print $1}')

# Perform the choice
if [[ "$choice1" != "" ]]; then
	cd "${VM_PATH}/${choice1}"
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
