#!/bin/sh

file_loc=$(fd --type f . | fzf --reverse --height 10)

if [[ "$file_loc" ]]; then
	curl -F "file=@$file_loc" https://0x0.st | xclip -selection c
	notify-send " File send. Link copied to clipboard !"
fi
