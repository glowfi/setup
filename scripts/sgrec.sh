#!/bin/bash

mic="no"
file="$1"

usage() {
    cat <<EOF
    -m   | --mic           Record audio or not
    -f   | --file          Recognize audio from file
    -h   | --help          Prints help

    ## EXAMPLE (To recognize from microphone)
    sgrec.sh --mic "yes"

    ## EXAMPLE (To recognize from file)
    sgrec.sh --file audio.mp3

EOF
}

while [[ $# > 0 ]]; do
    case "$1" in

        -m | --mic)
            mic="$2"
            shift
            ;;

        -f | --file)
            file="$2"
            shift
            ;;

        --help | *)
            usage
            exit 1
            ;;
    esac
    shift
done

if [[ "$mic" = "yes" ]]; then
    echo "Listening with you microphone ....."
    setsid songrec
    exit 1
fi

echo "Recognizing ....."
output=$(songrec audio-file-to-recognized-song "$file" | jq -r "[.track.title,.track.subtitle,.track.share.image] | @csv" | awk -F, '{print $1 "\n" $2 "\n" $3}')

songName=$(echo "$output" | head -1 | tr -d '"')
if [[ "$songName" = "" ]]; then
    echo "Did not find any song!"
    exit 1
fi

artistName=$(echo "$output" | head -2 | tail -1 | tr -d '"')
imageLocation=$(echo "$output" | tail -1 | tr -d '"')
wget "$imageLocation" -O ~/.cache/tmp.jpg 2>/dev/null

clear
kitty +kitten icat --align=left ~/.cache/tmp.jpg
echo "Song Name : $songName"
echo "Artist(s)   : $artistName"
