#!/bin/bash

choosen=$(printf "1.Image search in Google\n2.Extract Text From Image\n3.Take screenshot and search image in Google\n4.Extract Text From Image Multi Language" | dmenu -i -p "Choose:")
choosen=$(echo "$choosen" | awk -F"." '{print $1}')

#### Functions

## Image Search in Google
callreverseSearch() {
    image=$(fd --type f . | dmenu -l 30 -i -p "Choose Image:")
    searchUrl="https://www.google.com/searchbyimage/upload"

    if [[ "$image" != "" ]]; then
        link=$(curl -i -F sch=sch -F encoded_image=@"$image" "$searchUrl" | grep -oP 'location: \K.*')
        notify-send "Done! Showing results in Browser ..."
        xdg-open "$link"
    fi
}

## Take screenshot and search image in Google
callreverseSearchV2() {
    print_date() {
        date '+%F_%T' | sed -e 's/:/-/g'
    }

    SCREENSHOTDIR="${HOME}/Pictures/ScreenShots"
    mkdir -p "${SCREENSHOTDIR}"
    SCREENSHOTNAME="${SCREENSHOTDIR}/$(print_date).png"
    searchUrl="https://www.google.com/searchbyimage/upload"

    killall unclutter
    import "${SCREENSHOTNAME}"
    setsid unclutter &

    if [[ "$SCREENSHOTNAME" != "" ]]; then
        link=$(curl -i -F sch=sch -F encoded_image=@"$SCREENSHOTNAME" "$searchUrl" | grep -oP 'location: \K.*')
        notify-send "Done! Showing results in Browser ..."
        xdg-open "$link"
    fi
}

## Extract Text From Image
callTesseract() {
    print_date() {
        date '+%F_%T' | sed -e 's/:/-/g'
    }

    SCREENSHOTDIR="${HOME}/Pictures/ScreenShots"
    mkdir -p "${SCREENSHOTDIR}"
    SCREENSHOTNAME="${SCREENSHOTDIR}/$(print_date).png"

    killall unclutter
    import "${SCREENSHOTNAME}"
    setsid unclutter &

    extractedText=$(tesseract "$SCREENSHOTNAME" -)
    if [[ "$extractedText" != "" ]]; then
        echo "$extractedText" | xclip -sel c
        notify-send "Extracted Text copied to clipboard!"
    fi
}

multiLangTesseract() {
    print_date() {
        date '+%F_%T' | sed -e 's/:/-/g'
    }

    SCREENSHOTDIR="${HOME}/Pictures/ScreenShots"
    mkdir -p "${SCREENSHOTDIR}"
    SCREENSHOTNAME="${SCREENSHOTDIR}/$(print_date).png"

    killall unclutter
    import "${SCREENSHOTNAME}"
    setsid unclutter &

    getLang=$(tesseract --list-langs | awk 'NR!=1' | dmenu -i -l 10 -p "Choose Language:")
    extractedText=$(tesseract -l "$getLang" "$SCREENSHOTNAME" -)
    if [[ "$extractedText" != "" ]]; then
        echo "$extractedText" | xclip -sel c
        notify-send "Extracted Text copied to clipboard!"
    fi
}

#### Handle Choosen
if [[ "$choosen" == "1" ]]; then
    callreverseSearch
elif
[[ "$choosen" == "2" ]]
then
    callTesseract
elif
[[ "$choosen" == "3" ]]
then
    callreverseSearchV2
elif
[[ "$choosen" == "4" ]]
then
    multiLangTesseract
fi
