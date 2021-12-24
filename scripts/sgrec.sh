#!/bin/bash

echo "Recognizing ....."
output=$(songrec audio-file-to-recognized-song "$1" | jq -r "[.track.title,.track.subtitle,.track.share.image] | @csv" | awk -F, '{print $1 "\n" $2 "\n" $3}')

songName=$(echo "$output" | head -1 | tr -d '"')
artistName=$(echo "$output" | head -2 | tail -1 | tr -d '"')
imageLocation=$(echo "$output" | tail -1 | tr -d '"')
wget "$imageLocation" -O ~/.cache/tmp.jpg 2>/dev/null

clear
kitty +kitten icat --align=left ~/.cache/tmp.jpg
echo "Song Name : $songName"
echo "Artist(s)   : $artistName"
