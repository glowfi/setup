#!/usr/bin/env bash

if [[ "$1" = "unattended" ]]; then
	# Get Processes
	getProcesses=$(ps aux | sed "1d" | bemenu -i -l 20 -p "Kill:")

	# Multi Processes
	if [[ "$(echo "$getProcesses" | wc -l)" -gt 1 ]]; then

		# Delete the last process [bemenu fix]
		getProcesses=$(echo "$getProcesses" | sed '$d')

		# Kill based on process id
		pids=$(echo "$getProcesses" | awk '{print $2}')
		echo "$pids" | xargs -ro kill -9

		# Kill based on process name
		processNames=$(echo "$getProcesses" | awk '{print $NF}')
		echo "$processNames" | xargs killall -9
	else
		# Single Process

		# Kill based on process id
		pid=$(echo "$getProcesses" | awk '{print $2}' | xargs)
		kill -9 "$pid"

		# Kill based on process name
		processName=$(echo "$getProcesses" | awk '{print $NF}' | xargs)
		killall -9 "$processName"
	fi

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
