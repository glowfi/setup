#!/bin/bash

# Script Directory
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

install() {

	packages=($(echo "$1" | awk -F" " '{ print $0}'))
	iteration=1
	max_iteration=5

	# Handle Repository
	if [[ "$2" == "pac" ]]; then
		while [ $iteration -le $max_iteration ]; do
			sudo pacman -S --noconfirm "${packages[@]}" && break
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
