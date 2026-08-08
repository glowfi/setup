#!/bin/bash

detect_gpu() {
	if lspci | grep -qE "NVIDIA|GeForce"; then
		echo "nvidia"
	elif lspci | grep -qE "Radeon"; then
		echo "amd"
	elif lspci | grep -qiE "Intel Corporation (UHD|HD)|Integrated Graphics Controller"; then
		echo "intel"
	else
		echo "none"
	fi
}
