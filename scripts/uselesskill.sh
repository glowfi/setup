#!/bin/bash

# Kill all Unecessary Processes
c=0
while true; do
	if [[ "$(pgrep 'openrazer')" != "" ]]; then
		ps aux | grep -E "openrazer" | head | awk '{print $2}' | head -1 | xargs -I {} kill -9 "{}"
		((c++))
	fi
	if [[ "$(pgrep 'polychromatic')" != "" ]]; then
		ps aux | grep -E "polychromatic" | head | awk '{print $2}' | head -1 | xargs -I {} kill -9 "{}"
		((c++))
	fi
	if [[ "$(pgrep 'kdeconnectd')" != "" ]]; then
		ps aux | grep -E "kdeconnectd" | head | awk '{print $2}' | head -1 | xargs -I {} kill -9 "{}"
		((c++))
	fi
	if [[ "$c" = 3 ]]; then
		exit 0
	fi
done
