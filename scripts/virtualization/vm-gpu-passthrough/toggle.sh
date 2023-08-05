#!/usr/bin/env bash

tmpFile="$HOME/.config/gpupass"

red_prefix="\033[31m"
red_suffix="\033[00m"

bold_green_prefix="\033[1;32m"
bold_green_suffix="\033[00m"

if [[ -f "${tmpFile}" ]]; then
	# If file exist means we have already passthroughed our GPU
	echo -e "${red_prefix}Removing passthrough settings!${red_suffix}"
	sleep 3
	rm "${tmpFile}"
	sudo ./uninstall.sh
else
	# If file does not exist it means we are yet to passthrough our GPU
	echo -e "${bold_green_prefix}Adding passthrough settings!${bold_green_suffix}"
	sleep 3
	touch "${tmpFile}"
	sudo ./vm_gpu_passthrough.sh
fi
