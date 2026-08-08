#!/bin/bash

# Script Directory
SCRIPT_EXEC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

install() {
	local packages=($1)
	local repo="${2:-pac}"
	local cmd

	case "$repo" in
	pac) cmd=(sudo pacman -S --noconfirm --needed) ;;
	yay) cmd=(yay -S --noconfirm --needed) ;;
	*)
		echo "install: unknown repo '$repo'" >&2
		return 1
		;;
	esac

	for _ in 1 2 3 4 5; do
		"${cmd[@]}" "${packages[@]}" && return 0
		sleep 1
	done

	echo "${packages[*]}" >>"$SCRIPT_EXEC_DIR/err.txt"
	echo "install: FAILED after 5 tries: ${packages[*]}" >&2
	return 1
}
