#!/bin/sh

dwm_battery () {
    CHARGE=$(cat /sys/class/power_supply/BAT1/capacity)
    STATUS=$(cat /sys/class/power_supply/BAT1/status)

    printf "%s" "$SEP1"
    if [ "$STATUS" = "Charging" ]; then
        printf "🔌 %s%% %s" "$CHARGE" "$STATUS"
    else
        printf "🔋 %s%% %s" "$CHARGE" "$STATUS"
    fi
    printf "%s" "$SEP2"
}

dwm_battery
