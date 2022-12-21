#!/bin/bash

# Settings

original=$(echo 'user_pref("keyword.enabled", false);')
required=$(echo 'user_pref("keyword.enabled", true);')

# Get Default-release Location

findLocation=$(find ~/.mozilla/firefox/ | grep -E "default-release" | head -1)

# Activate Settings

cd "$findLocation"
wget https://raw.githubusercontent.com/arkenfox/user.js/master/user.js -O user.js
sed -i "s/$original/$required/g" user.js
cd

## Browser
#super + b
# firefox

## Alternate Browser Profile
#super + shift + b
# firefox -p "surf"

# vim.cmd("let g:mkdp_browser = '/usr/bin/brave'")
