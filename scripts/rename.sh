#!/bin/sh

path="$1"
i=1
echo "Renaming ..."
for files in $path*; do
	filename=$(echo "$files" | awk -F"/" '{print $NF}' | awk -F"." '{print $1}' | xargs)
	ext=$(echo "$files" | awk -F"/" '{print $NF}' | awk -F"." '{print $2}' | xargs)
	timestamp=$(date +%s)
	mv "$files" "$path""$i-img-$timestamp"."$ext"
	((i = i + 1))
done
echo "Done!"
