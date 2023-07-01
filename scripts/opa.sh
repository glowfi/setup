#!/bin/bash

line_check=$(sed -n '47p' ~/.config/kitty/kitty.conf)

if [[ "$line_check" == "## Tabs" ]]; then
    cp -r ~/setup/configs/kitty/kitty.conf ~/.config/kitty/
else
    sed -i '46,50d' ~/.config/kitty/kitty.conf
fi

# Reload Kitty Config
kill -SIGUSR1 $(pgrep kitty)
