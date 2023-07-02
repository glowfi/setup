#!/bin/sh


rand=$((RANDOM % 3))

if [[ "$rand" = "0" ]]; then
    paplay $HOME/.misc/audio_0.ogg
elif [[ "$rand" = "1" ]]; then
    paplay $HOME/.misc/audio_1.ogg
else
    paplay $HOME/.misc/audio_2.ogg
fi
