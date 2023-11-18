#!/bin/bash

detect_INIT_SYSTEM() {
	os=$(uname -o)
	if [[ $os = Android ]]; then
		varInit="init.rc"
	elif ! pidof -q systemd; then
		if [[ -f "/sbin/openrc" ]]; then
			varInit="openrc"
		else
			read -r varInit </proc/1/comm
		fi
	else
		varInit="systemD"
	fi

	varInit=$(echo "$varInit" | sed 's/[ \t]*$//')
	echo "${varInit}"
}

detect_INIT_SYSTEM
