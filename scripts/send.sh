#!/bin/sh

### Sends a File to Null Pointer server and copies the link to clipboard

file_loc=$(fd --type f . | fzf --prompt "Choose File to Send:" --reverse --height 20)

if [[ "$file_loc" ]]; then
    curl -F "file=@$file_loc" https://0x0.st | xclip -selection c
    notify-send " File send. Link copied to clipboard !"
else
    echo "Exited!"
fi
