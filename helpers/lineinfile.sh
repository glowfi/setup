#!/bin/bash

lineinfile() {
	local file="$1" regex="$2" line="$3" create="${4:-}"
	local d=$'\x01' # delimiter unlikely to collide with '#' or other chars in regex/line

	if [[ "$create" == "create" ]]; then
		sudo mkdir -p "$(dirname "$file")"
		sudo touch "$file"
	fi

	if sudo grep -qE "$regex" "$file" 2>/dev/null; then
		sudo sed -i -E "s${d}${regex}.*${d}${line}${d}" "$file"
	else
		echo "$line" | sudo tee -a "$file" >/dev/null
	fi
}
