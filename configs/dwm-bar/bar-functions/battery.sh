#!/bin/sh

dwm_battery () {
    CHARGE=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0|grep "percentage"|xargs|awk -F":" '{print $2}'|xargs)
    STATUS=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0|grep "state"|xargs|awk -F":" '{print $2}'|xargs )

    printf "%s" "$SEP1"
    if [ "$STATUS" = "Charging" ]; then
        printf "🔌 %s%% %s" "$CHARGE" "$STATUS"
    else
        printf "🔋 %s%% %s" "$CHARGE" "$STATUS"
    fi
    printf "%s" "$SEP2"
}

dwm_battery
