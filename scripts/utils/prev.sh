#!/bin/sh

export FIFO="/tmp/image-preview.fifo"

cache="/home/$USER/.cache/prev.sh/"
mkdir -p "$cache"

start_ueberzug() {
	rm -f "$FIFO"
	mkfifo "$FIFO"
	ueberzug layer --parser json <"$FIFO" &
	exec 3>"$FIFO"
}
stop_ueberzug() {
	exec 3>&-
	rm -f "$FIFO"
}

preview_img() {
	[ -d "$1" ] && echo "$1 is a directory" ||
		printf '%s\n' '{"action": "add", "identifier": "image-preview", "path": "'"$1"'", "x": "2", "y": "1", "width": "'"$FZF_PREVIEW_COLUMNS"'", "height": "'"$FZF_PREVIEW_LINES"'"}' >"$FIFO"
	metadata="$(mediainfo "$1" | tail -10)"
	printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
	echo "$metadata"
}
[ "$1" = "preview_img" ] && {
	preview_img "$2"
	exit
}

start_ueberzug

vent() {
	find "$path"/* | tac | fzf --color=16 --preview-window="left:50%:wrap" --preview "sh $0 preview_img {}" || stop_ueberzug
	stop_ueberzug
}

# CLI
USAGE="Usage: ${0##*/} [-hp]
-p		Specify the path to look in."

fail() {
	echo ${0##*/}: "$*" 1>&2
	exit 1
}

path=""

while getopts hdcp: opt; do
	case "$opt" in
	p)
		path=$OPTARG
		vent
		;;
	[h?]) fail "$USAGE" ;;
	esac
done
