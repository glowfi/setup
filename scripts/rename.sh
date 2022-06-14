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
		echo "entered 1"
		inputDirectory="$1"
		directoryPath="$inputDirectory*.*"
		rename
	else
		echo "entered 2"
		inputDirectory="$1/"
		directoryPath="$inputDirectory*.*"
		rename
	fi
else
	echo "Such Directory does not exists!"
fi

# path="$1"
# i=1
# echo "Renaming ..."
# for files in $path*; do
# 	filename=$(echo "$files" | awk -F"/" '{print $NF}' | awk -F"." '{print $1}' | xargs)
# 	ext=$(echo "$files" | awk -F"/" '{print $NF}' | awk -F"." '{print $2}' | xargs)
# 	timestamp=$(date +%s)
# 	mv "$files" "$path""$i-img-$timestamp"."$ext"
# 	((i = i + 1))
# done
# echo "Done!"
