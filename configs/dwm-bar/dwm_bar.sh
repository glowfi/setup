#!/bin/sh

# Import functions with "$include /route/to/module"
# It is recommended that you place functions in the subdirectory ./bar-functions and use: . "$DIR/bar-functions/dwm_example.sh"

# Store the directory the script is running from
LOC=$(readlink -f "$0")
DIR=$(dirname "$LOC")

# Change the charachter(s) used to seperate modules. If two are used, they will be placed at the start and end.
export SEP1=" "
export SEP2=" "

# Import the modules
. "$DIR/bar-functions/resources.sh"
. "$DIR/bar-functions/battery.sh"
. "$DIR/bar-functions/brightness.sh"
. "$DIR/bar-functions/volume.sh"
. "$DIR/bar-functions/network.sh"
. "$DIR/bar-functions/time_date.sh"

parallelize() {
    while true
    do
        printf "Running parallel processes\n"
        ~/dwm-bar/bar-functions/network.sh &
        sleep 5
    done
}
parallelize &

# Update dwm status bar every second
while true
do
    # Append results of each func one by one to the upperbar string
    upperbar=""
    upperbar="$upperbar$(~/dwm-bar/bar-functions/resources.sh)"
    upperbar="$upperbar$(~/dwm-bar/bar-functions/volume.sh)"
    upperbar="$upperbar$(~/dwm-bar/bar-functions/brightness.sh)"
    upperbar="$upperbar$(~/dwm-bar/bar-functions/network.sh)"
    upperbar="$upperbar$(~/dwm-bar/bar-functions/battery.sh)"
    upperbar="$upperbar$(~/dwm-bar/bar-functions/time_date.sh)"
   
    xsetroot -name "$upperbar"
    sleep 1
done
