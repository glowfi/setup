#!/bin/bash

out=$(systemctl status bluetooth.service | head -2 | tail -1 | grep -Eo "enabled")

if [[ "$out" = "" ]]; then
	echo " Off"
else
	echo " On [$(bluetoothctl devices Connected | wc -l | xargs)]"
fi
