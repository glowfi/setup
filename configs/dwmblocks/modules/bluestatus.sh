#!/bin/bash

out=$(systemctl status bluetooth.service | head -2 | tail -1 | grep -Eo "enabled")

Red=$'\e[1;31m'
Green=$'\e[1;32m'
Blue=$'\e[1;34m'

if [[ "$out" = "" ]]; then
	echo "$Red Off"
else
	echo "$Blue On [$(bluetoothctl devices Connected | wc -l | xargs)]"
fi
