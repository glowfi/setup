#!/bin/sh

dwm_pulse() {
    VOL=$(pamixer --get-volume)
    STATE=$(pamixer --get-mute)

    MVOL=$(amixer -D pulse sget Capture | grep 'Left:' | awk -F'[][]' '{ print $2 }')
    MSTATE=$(amixer -D pulse get Capture | sed 5q | tail -1 | awk -F " " '{print $NF}')

    printf "%s" "$SEP1"

    # Print Output
    if [ "$STATE" = "true" ] || [ "$VOL" -eq 0 ]; then
        printf "🔇"
    elif [ "$VOL" -gt 0 ] && [ "$VOL" -le 33 ]; then
        printf "🔈 %s%%" "$VOL"
    elif [ "$VOL" -gt 33 ] && [ "$VOL" -le 66 ]; then
        printf "🔉 %s%%" "$VOL"
    else
        printf "🔊 %s%%" "$VOL"
    fi

    if [ "$MSTATE" = "[off]" ] || [ "$VOL" -eq 0 ]; then
        printf "  🎤🔇"
    else
        printf "  🎤 %s%" "$MVOL"
    fi

    printf "%s" "$SEP2"
}

dwm_pulse
