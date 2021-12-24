#!/bin/bash -x

INRES="1366x768"
OUTRES="1366x768"
FPS="30"

ffmpeg -f x11grab -s "$INRES" -r "$FPS" -i :0.0 -f alsa -ac 2 \
-i default -vcodec libx264 -s "$OUTRES" \
-acodec libmp3lame -ab 128k -ar 44100 \
-threads 0 -f flv $1
