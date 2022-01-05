#!/bin/sh

df_check_location='/home'

dwm_resources() {

	printf "%s" "$SEP1"
	# get all the infos first to avoid high resources usage
	free_output=$(free -h | grep Mem)
	df_output=$(df -h $df_check_location | tail -n 1)

	# Used and total memory
	MEMUSED=$(echo $free_output | awk '{print $3}')
	MEMTOT=$(echo $free_output | awk '{print $2}')

	# CPU temperature
	CPU=$(top -bn1 | grep Cpu | awk '{print $2}')%

	# Used and total storage in /home (rounded to 1024B)
	STOUSED=$(echo $df_output | awk '{print $3}')
	STOTOT=$(echo $df_output | awk '{print $2}')
	STOPER=$(echo $df_output | awk '{print $5}')

	printf "MEM: %s/%s  CPU: %s  DISK: %s/%s :%s" "$MEMUSED" "$MEMTOT" "$CPU" "$STOUSED" "$STOTOT" "$STOPER"
	printf "%s" "$SEP2"
}

dwm_resources
