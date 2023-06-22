#!/bin/sh


rand=$((RANDOM % 2))

if [[ "$rand" = "0" ]]; then
    paplay ~/.misc/audio_0.ogg
else
    paplay ~/.misc/audio_1.ogg

fi
