#!/bin/bash

line_check=$(sed -n '45p' ~/.config/kitty/kitty.conf)

if [[ "$line_check" == "## Tabs" ]]; then
	cp -r ~/setup/configs/kitty/kitty.conf ~/.config/kitty/
else
	sed -i '45,48d' ~/.config/kitty/kitty.conf
fi
