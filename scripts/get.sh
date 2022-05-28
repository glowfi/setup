#!/bin/bash

link="$1"
fileType="$2"

if [[ "$fileType" == "f" ]]; then
	name=$(echo "$link" | awk -F"/" '{print $NF}')
	wget "$link" -O ~/"$name"
elif [[ "$fileType" == "c" ]]; then
	name=$(echo "$link" | awk -F"/" '{print $NF}')
	curl "$link" -o ~/"$name"
else
	echo "Provide a fileType! For downloading a file give f or just contens give c"
fi
