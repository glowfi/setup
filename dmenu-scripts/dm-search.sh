#!/bin/bash

output=$(echo "" >/dev/null | dmenu -p "Search" -nb "#32302f" -nf "#bbbbbb" -sb "#477D6F" -sf "#eeeeee")
xdg-open "https://search.brave.com/search?q=$output"
