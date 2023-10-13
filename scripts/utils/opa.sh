#!/bin/bash

line_check=$(sed -n '47p' $HOME/.config/kitty/kitty.conf)

if [[ "$line_check" == "## Tabs" ]]; then
	cp -r $HOME/setup/configs/kitty/kitty.conf $HOME/.config/kitty/
else
	sed -i '46,50d' $HOME/.config/kitty/kitty.conf
fi

# Reload Kitty Config
kill -SIGUSR1 $(pgrep kitty)
