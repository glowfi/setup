#!/usr/bin/env bash

# Script Directory
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

deleteLines() {

	length=$(cat "$1" | grep -n "# ======================================================= Can Be Deleted for minimal install =======================================================" | wc -l)

	for ((i = 0; i < $length; i++)); do
		matchesStart=$(cat "$1" | grep -n "# ======================================================= Can Be Deleted for minimal install =======================================================" | head -1 | xargs)
		start=$(echo "$matchesStart" | cut -d":" -f1)
		echo "$start"

		matchesEnd=$(cat "$1" | grep -n "# ======================================================= END ======================================================================================" | head -1 | xargs)
		end=$(echo "$matchesEnd" | cut -d":" -f1)
		echo "$end"

		sed -i "$start,$end d" "$1"
	done

}

location="$SCRIPT_DIR/3_0_packages.sh"
deleteLines "$location"

location="$SCRIPT_DIR/4_cdx.sh"
deleteLines "$location"
