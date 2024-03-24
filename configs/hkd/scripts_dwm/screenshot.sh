#!/bin/sh

sed -i "35s/.*/fading = false;/" ~/.config/picom/picom.conf
~/.local/bin/windowshot.sh
sed -i "35s/.*/fading = true;/" ~/.config/picom/picom.conf
