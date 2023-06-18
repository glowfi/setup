#!/bin/sh

print_date() {
    date '+%F_%T' | sed -e 's/:/-/g'
}

SCREENSHOTDIR="${HOME}/.cache/ScreenShot"
image="${SCREENSHOTDIR}/$(print_date).png"
icon="/home/$USER/.misc/lock.png"
hue=(-level "0%,100%,0.6")
effect=(-filter Gaussian -resize 20% -define "filter:sigma=1.5" -resize 500.5%)


# Create Directory if not present
mkdir -p "${SCREENSHOTDIR}"

root() {
    import -window root "${image}"

    rm -rf ~/.cache/output-0.png
    rm -rf ~/.cache/output-1.png

    convert "$image" "${hue[@]}" "${effect[@]}" -pointsize 26 -fill "#28282B" -gravity center -annotate +0+160 "LOCKED !" "$icon" -gravity center -composite "$image" "/home/$USER/.cache/output.png"

    mv ~/.cache/output-0.png ~/.cache/out.png
    rm -rf ~/.cache/output-1.png
}


# Take ScreenShot
root


# Start Python Script
~/.local/bin/screenLock.py &

# Start i3
i3lock -i ~/.cache/out.png &
