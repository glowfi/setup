#!/bin/sh

print_date() {
	date '+%F_%T' | sed -e 's/:/-/g'
}

SCREENSHOTDIR="${HOME}/Pictures/ScreenShots"
SCREENSHOTNAME="${SCREENSHOTDIR}/$(print_date).png"

note() {
	notify-send "screenshot name ${SCREENSHOTNAME}"
}

mkdir -p "${SCREENSHOTDIR}"

_end() {
	note
	xdg-open "${SCREENSHOTNAME}"
	xclip -in -selection clipboard -target image/png ${SCREENSHOTNAME}
	exit 0
}

region() {
	killall unclutter
	import "${SCREENSHOTNAME}"
	setsid unclutter &
	_end
}
window() {
	import -window "$(xprop -root | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}')" "${SCREENSHOTNAME}"
	_end
}
root() {
	import -window root "${SCREENSHOTNAME}"
	_end
}

# Default Prompt For Selection
prompter() {
	case "$(printf 'a selected area\ncurrent window\nfull screen' | dmenu -l 6 -i -p 'Screenshot which area?')" in
	"a selected area") region ;;
	"current window") window ;;
	"full screen") root ;;
	*) exit ;;
	esac
	_end
}

while getopts cwr: o; do
	case "$o" in
	c) region ;;
	w) window ;;
	r) root ;;
	\?) printf 'Invalid option: -%s\n' "${o}" && exit ;;
	esac
done
prompter
