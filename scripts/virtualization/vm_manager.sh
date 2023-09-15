#!/usr/bin/env bash

# Virtual Machines Location
VM_PATH="$HOME/Downloads/VMS"

# Choose VM
vmlist=$(fd . "$VM_PATH" --type directory --max-depth 1 | rev | cut -d"/" -f2 | rev)
if [[ "$vmlist" = "" ]]; then
	echo "No VMS exists or created till now!"
	exit 1
fi
choice1=$(echo "$vmlist" | fzf --prompt "Choose VM:")

reconfigure() {
	goto="$1"
	name="$2"
	fish -c "vs -reconf yes -n ${name} -g ${goto}"
}

update() {

	goto="$1"
	name="$2"
	fish -c "vs -ups yes -n ${name} -g ${goto}"

}

# Perform the choosen task
if [[ "$choice1" != "" ]]; then
	# Choose what to do
	choice2=$(echo -e "1.Start VM (UEFI)\n2.Fallback Start Script(UEFI)\n3.Fallback Start Script (Legacy BIOS)\n4.Close VM\n5.Delete VM\n6.Reconfigure VM\n7.Update Scripts" | fzf | awk -F"." '{print $1}')
	cd "${VM_PATH}/${choice1}"

	if [[ "$choice2" != "" && "$choice2" == "5" ]]; then
		cd
		rm -rf "${VM_PATH}/${choice1}"
	else
		if [[ "$choice2" != "" ]]; then
			if [[ "$choice2" == "1" ]]; then
				./start.sh
			elif [[ "$choice2" == "2" ]]; then
				./fallback-start.sh
			elif [[ "$choice2" == "3" ]]; then
				./fallback-start-BIOS.sh
			elif [[ "$choice2" == "4" ]]; then
				./clean.sh
			elif [[ "$choice2" == "6" ]]; then
				reconfigure "${VM_PATH}/${choice1}" "${choice1}"
			elif [[ "$choice2" == "7" ]]; then
				update "${VM_PATH}/${choice1}" "${choice1}"
			fi
		fi
	fi
fi
