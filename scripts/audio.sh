#!/bin/sh


rand=$((RANDOM % 3))

if [[ "$rand" = "0" ]]; then
    paplay ~/.misc/audio_0.ogg
elif [[ "$rand" = "1" ]]; then
    paplay ~/.misc/audio_1.ogg
else
    paplay ~/.misc/audio_2.ogg
fi
