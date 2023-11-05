#!/bin/fish

# INSTALL VSCODIUM
yay -S --noconfirm vscodium-bin

# FAKE COMMAND TO INITIALIZE VSCODIUM
vscodium --list-extensions

# COPY API
cp -r ~/setup/configs/legacy/Vscodium/product.json ~/.config/VSCodium/

# VSCODIUM EXTENSIONS

vscodium --install-extension CoenraadS.bracket-pair-colorizer-2
vscodium --install-extension esbenp.prettier-vscode
vscodium --install-extension oderwat.indent-rainbow
vscodium --install-extension adamsome.vscode-theme-gruvbox-minor

vscodium --install-extension formulahendry.code-runner

vscodium --install-extension ms-python.python
vscodium --install-extension ms-python.vscode-pylance
vscodium --install-extension ms-toolsai.jupyter
vscodium --install-extension cstrap.python-snippets
vscodium --install-extension WyattFerguson.jinja2-snippet-kit

vscodium --install-extension dbaeumer.vscode-eslint
vscodium --install-extension dsznajder.es7-react-js-snippets
vscodium --install-extension GraphQL.vscode-graphql
vscodium --install-extension svelte.svelte-vscode
vscodium --install-extension ritwickdey.LiveServer

vscodium --install-extension mtxr.sqltools
vscodium --install-extension mtxr.sqltools-driver-pg

# COPY VSCODIUM SETTINGS
cp -r ~/setup/configs/legacy/Vscodium/settings.json ~/.config/VSCodium/User/
