#!/bin/bash

inputDirectory="$1"
index=$2
directoryPath=""

rename() {
	for f in $directoryPath; do
		fileName=$(echo "$f" | awk -F "/" '{print $NF}')
		fileExtension=$(echo "$fileName" | awk -F "." '{print $NF}')
		mv "$f" "$inputDirectory$index.$fileExtension"
		((index++))
	done
}

if [[ -d "$1" ]]; then
	checkForwardSlash="${inputDirectory:0-1}"
	if [[ "$checkForwardSlash" == "/" ]]; then
		inputDirectory="$1"
		directoryPath="$inputDirectory*.*"
		rename
	else
		inputDirectory="$1/"
		directoryPath="$inputDirectory*.*"
		rename
	fi
else
	echo "Such Directory does not exists!"
fi
