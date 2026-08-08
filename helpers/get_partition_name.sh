#!/bin/bash

part() {
	DISK="${1}"
	if [[ "$DISK" =~ (nvme|mmcblk|loop) ]]; then
		echo "${DISK}p${2}"
	else
		echo "${DISK}${2}"
	fi
}
