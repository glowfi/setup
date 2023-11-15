#!/bin/bash

# Script Directory
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

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
}

getPkgString() {
	if [[ "${initType}" == "systemD" ]]; then
		echo "systemD Detected!"
		pkgString=($(echo "${packages[@]}" | awk -F" " '{ print $0}'))
	else
		echo "$initType Detected!"
		pkgString=""
		for package in "${packages[@]}"; do
			packageExist=$(pacman -Ss "${package}-${initType}")
			if [[ "${packageExist}" != "" ]]; then
				pkgString+="${package}-${initType} "
			else
				pkgString+="${package} "
			fi
		done
		pkgString=($(echo "${pkgString}" | sed 's/^[ \t]*\(.*$\)/\1/' | awk -F" " '{ print $0}'))
	fi
}

install() {

	packages=($(echo "$1" | awk -F" " '{ print $0}'))
	iteration=1
	max_iteration=5
	initType="$varInit"
	getPkgString

	# Handle Repository
	if [[ "$2" == "pac" ]]; then
		while [ $iteration -le $max_iteration ]; do
			sudo pacman -S --noconfirm "${pkgString[@]}" && break
			iteration=$(($iteration + 1))
		done
	elif [[ "$2" == "yay" ]]; then
		while [ $iteration -le $max_iteration ]; do
			yay -S --noconfirm "${packages[@]}" && break
			iteration=$(($iteration + 1))
		done
	fi

	# Check Success
	if [[ $iteration -eq $max_iteration ]]; then
		# Append Failed to install packages to a file
		echo "${packages[@]}" >>"$SCRIPT_DIR/err.txt"
	else
		echo "All packages installed successfully!"
	fi

}

# Detect Init System
detect_INIT_SYSTEM
