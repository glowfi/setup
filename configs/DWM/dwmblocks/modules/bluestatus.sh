#!/bin/bash

out1=$(systemctl status bluetooth.service | head -2 | tail -1 | grep -Eo "enabled")
out2=$(systemctl status bluetoothd.service | grep -Eo "started")

if [[ "$out1" != "" ]]; then
	out="${out1}"
elif [[ "$out2" != "" ]]; then
	out="${out2}"
fi

if [[ "$out" = "" ]]; then
	echo " Off"
else
	echo " On [$(bluetoothctl devices Connected | wc -l | xargs)]"
fi
