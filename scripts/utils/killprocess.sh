#!/usr/bin/env bash

if [[ "$1" = "unattended" ]]; then
	# Get Processes
	getProcesses=$(ps aux | sed "1d" | dmenu -i -l 20 -p "Kill:" | sed '$d')

	# Kill based on process id
	pids=$(echo "$getProcesses" | awk '{print $2}')
	echo "$pids" | sudo -A xargs -ro kill -9

	# Kill based on process name
	processNames=$(echo "$getProcesses" | awk '{print $NF}')
	echo "$processNames" | sudo -A xargs killall -9
else
	# Get Processes
	getProcesses=$(ps aux | sed "1d" | fzf -m --prompt "Kill:")

	# Kill based on process id
	pids=$(echo "$getProcesses" | awk '{print $2}')
	echo "$pids" | sudo -A xargs -ro kill -9

	# Kill based on process name
	processNames=$(echo "$getProcesses" | awk '{print $NF}')
	echo "$processNames" | sudo -A xargs killall -9
fi
