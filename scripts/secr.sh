#!/usr/bin/env bash

# Dependencies
sudo pacman -S --noconfirm pass

# Generate GPG KEY
gpg --full-generate-key
key=$(gpg --list-secret-keys --keyid-format long | tail -4 | head -1 | xargs)
pass init "$key"
gpg-connect-agent reloadagent /bye

# Extras
yay -S --noconfirm openrazer-meta polychromatic
sudo gpasswd -a $USER plugdev
