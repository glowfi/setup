#!/usr/bin/env bash

tmpFile="$HOME/.config/gpupass"

if [[ -f "${tmpFile}" ]]; then
	# If file exist means we have already passthroughed our GPU
	rm $HOME/.config/gpupass
	sudo ./uninstall.sh

else
	# If file does not exist it means we are yet to passthrough our GPU
	touch $HOME/.config/gpupass
	sudo ./vm_gpu_passthrough.sh
fi
