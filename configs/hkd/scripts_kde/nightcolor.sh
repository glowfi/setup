#!/usr/bin/env bash

FILE="$HOME/.config/nightcolor"

if [ -f "$FILE" ]; then
	rm ""${FILE}
	redshift -x
else
	touch "${FILE}"
	redshift -P -O 4500K
fi
