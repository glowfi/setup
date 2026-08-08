#!/bin/fish

# Setup
set SCRIPT_DIR (cd (dirname (status -f)); and pwd)
set INIT_SCRIPT (echo "$SCRIPT_DIR/helpers/detect_init.sh")
set initType (bash "$INIT_SCRIPT")
source "$SCRIPT_DIR/helpers/pkg_installer.fish"
source "$SCRIPT_DIR/helpers/header.fish"
source "$SCRIPT_DIR/helpers/git_clone.fish"

# Python
header "Configuring python"

mkdir -p $HOME/.local/bin/
set pyloc (sudo fd . /usr/lib/ --type f --max-depth 2 | grep "EXTERNALLY-MANAGED" | head -1)
sudo rm -rf "$pyloc"
sudo sed -i "25s/.*/IgnorePkg = python/" /etc/pacman.conf

install python-pip pac
for i in (seq 3)
    python -m ensurepip --upgrade
    pip install --upgrade pip
    pip install setuptools sortedcontainers virtualenv twine wheel pygobject
    pip install pyautogui pynput pyfzf poetry rich pygments
end

# Miniconda
header "Installing miniconda3"

mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm -rf ~/miniconda3/miniconda.sh
touch ~/.config/conda-activated

# Tmux,direnv
header "Installing mux,direnv"

install "direnv tmux" pac

# NodeJS
header "Installing nodeJS"

set ver (curl https://nodejs.org/en/download | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep -i "releases/tag" | cut -d"/" -f8| xargs)
wget "https://nodejs.org/dist/$ver/node-$ver-linux-x64.tar.xz" -O $HOME/node.tar.xz
tar -xf $HOME/node.tar.xz -C $HOME
rm -rf $HOME/node.tar.xz
mv $HOME/node-"$ver"-linux-x64 $HOME/.local/bin/nodeJS
source $HOME/.config/fish/config.fish

for i in (seq 3)
    npm update -g npm
    npm install npm@latest -g
    npm i -g console-log-cleaner
    npm i -g md-to-pdf
    sudo mv $HOME/.local/bin/nodeJS/lib/node_modules/md-to-pdf/node_modules/highlight.js/styles/base16/* $HOME/.local/bin/nodeJS/lib/node_modules/md-to-pdf/node_modules/highlight.js/styles
    sudo rm -rf $HOME/.local/bin/nodeJS/lib/node_modules/md-to-pdf/node_modules/highlight.js/styles/base16/
end

curl -fsSL https://bun.sh/install | bash

# Rust
header "Installing Rust"

function installRust
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    rustup default stable
end

for i in (seq 10)
    if test -f ~/.cargo/bin/rustc
        break
    else
        installRust
    end
end

git_clone "https://github.com/rust-analyzer/rust-analyzer.git" /tmp/rust-analyzer 1
cd /tmp/rust-analyzer
rustup default stable
cargo xtask install --server
cd ..
rm -rf /tmp/rust-analyzer

cargo install ripdrag
cargo install csvlens
cargo install --git https://github.com/loichyan/nerdfix.git

# Golang
header "Installing Golang"

function installGolang
    cd ~/.local/bin
    curl https://go.dev/dl/ | grep -e linux | head -2 | grep -e href | awk -F href '{print $2}' | tr -d "=" | tr -d ">" | xargs -I {} wget https://go.dev{} -O go.tar.gz
    tar -xzf go.tar.gz
    rm -rf go.tar.gz
    mv ./go ./golang
    cd
end

for i in (seq 10)
    cd
    if test -d ~/.local/bin/golang/
        break
    else
        installGolang
    end
end

go install github.com/ericchiang/pup@latest
go install golang.org/x/tools/gopls@latest
go install github.com/segmentio/golines@latest
go install golang.org/x/tools/cmd/goimports@latest
go install mvdan.cc/gofumpt@latest
go install github.com/fatih/gomodifytags@latest
go install github.com/josharian/impl@latest
go install github.com/koron/iferr@latest
go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
go install github.com/pressly/goose/v3/cmd/goose@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
go install github.com/golangci/misspell/cmd/misspell@latest

# Lua
header "Installing Lua"

set lua_ver (curl "https://github.com/LuaLS/lua-language-server" | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep -i "releases/tag" | cut -d"/" -f6|xargs)
wget "https://github.com/LuaLS/lua-language-server/releases/download/$lua_ver/lua-language-server-$lua_ver-linux-x64.tar.gz" -O $HOME/lua-ls.tar.gz
mkdir -p $HOME/lua-ls
tar -xf $HOME/lua-ls.tar.gz -C $HOME/lua-ls/
rm -rf $HOME/lua-ls.tar.gz
mv $HOME/lua-ls $HOME/.local/bin/luaLSP

cargo install stylua

# Fzf
header "Installing FZF"

git_clone "https://github.com/junegunn/fzf.git" "$HOME/.fzf" 1
yes | ~/.fzf/install

# MPV
header "Configuring MPV"
set MPV_CONF_DIR "$HOME/.config/mpv"
set MPV_SCRIPTS_DIR "$MPV_CONF_DIR/scripts"

mkdir -p $MPV_SCRIPTS_DIR
chmod 0755 $MPV_CONF_DIR
chmod 0755 $MPV_SCRIPTS_DIR

set MPV_CONF_FILE "$MPV_CONF_DIR/mpv.conf"
touch $MPV_CONF_FILE

set YTDL_LINE "script-opts-append=ytdl_hook-ytdl_path=yt-dlp"
grep -Fxq $YTDL_LINE $MPV_CONF_FILE; or echo $YTDL_LINE >>$MPV_CONF_FILE

set SAVE_POS_LINE save-position-on-quit
grep -Fxq $SAVE_POS_LINE $MPV_CONF_FILE; or echo $SAVE_POS_LINE >>$MPV_CONF_FILE

echo save-position-on-quit >>$HOME/.config/mpv/mpv.conf

wget -q -O "$MPV_SCRIPTS_DIR/webm.lua" "https://github.com/ekisu/mpv-webm/releases/download/latest/webm.lua"
chmod 0644 "$MPV_SCRIPTS_DIR/webm.lua"

wget -q -O "$MPV_SCRIPTS_DIR/thumbfast.lua" "https://raw.githubusercontent.com/po5/thumbfast/master/thumbfast.lua"
chmod 0644 "$MPV_SCRIPTS_DIR/thumbfast.lua"

wget -q -O "$MPV_SCRIPTS_DIR/osc.lua" "https://raw.githubusercontent.com/po5/thumbfast/vanilla-osc/player/lua/osc.lua"
chmod 0644 "$MPV_SCRIPTS_DIR/osc.lua"

git_clone "https://github.com/4ndrs/PureMPV" "$MPV_SCRIPTS_DIR/PureMPV" 1

# Terminal utilities
header "Installing Terminal utilities"
cp -r "$HOME/.dotfiles/configs/btop" "$HOME/.config"

set scripts \
    blank.sh \
    cpx \
    edit.sh \
    gpatch.sh \
    gtfu.sh \
    int.sh \
    killprocess.sh \
    mp \
    opa.sh \
    prev.sh \
    rename.sh \
    rlt \
    saveScraper.py \
    searchArchive.sh \
    send.sh \
    dir2clip.sh \
    clipmenu.sh \
    kdcapp.sh

set SCRIPTS_SRC_DIR "$HOME/.dotfiles/scripts"
set SCRIPTS_DST_DIR "$HOME/.local/bin"

for script in $scripts
    set src "$SCRIPTS_SRC_DIR/$script"
    set dst "$SCRIPTS_DST_DIR/$script"

    if test -e $src
        cp -a $src $dst; and chmod 0755 $dst
    else
        echo "Source file not found: $src" >&2
    end
end

pip install numerize
git_clone "https://github.com/glowfi/sYT" /tmp/sYT 1
cp -r "/tmp/sYT/sYT.py" $HOME/.local/bin/
cp -r "/tmp/sYT/sYT.sh" $HOME/.local/bin/
rm -rf /tmp/sYT
chmod +x $HOME/.local/bin/sYT.py
chmod +x $HOME/.local/bin/sYT.sh

git_clone "https://github.com/thameera/vimv" /tmp/vimv 1
cp -r /tmp/vimv/vimv $HOME/.local/bin/
rm -rf vimv

install lsb-release pac
pip install xhibit

git_clone "https://github.com/user234683/youtube-local" /tmp/youtube-local 1
cd /tmp/youtube-local
python -m venv env
source "/tmp/youtube-local/env/bin/activate.fish"
pip install -r requirements.txt
deactivate
cd
mv /tmp/youtube-local "$HOME/.local/bin/"

# Beekeeper
header "Installing Beekeeper"
set beekeeper_ver (curl "https://github.com/beekeeper-studio/beekeeper-studio" | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep -i "releases/tag" | cut -d"/" -f6|xargs|tr -d "v")
wget "https://github.com/beekeeper-studio/beekeeper-studio/releases/download/v$beekeeper_ver/Beekeeper-Studio-$beekeeper_ver.AppImage" -O ~/.local/bin/beekeeper
chmod +x ~/.local/bin/beekeeper

# Bruno
header "Installing Bruno"
set brunover (curl "https://github.com/usebruno/bruno" | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep -i "releases/tag" | cut -d"/" -f6|xargs|tr -d "v")
set url (string join "" "https://github.com/usebruno/bruno/releases/download/v$brunover/bruno_" "$brunover" "_x86_64_linux.AppImage")
wget "$url" -O ~/.local/bin/bruno
chmod +x ~/.local/bin/bruno

# Virtualization
header "Configuring virtualization"

sudo pacman -Rdd --noconfirm iptables
set virt_packages "dnsmasq virt-manager qemu-base ebtables edk2-ovmf qemu-ui-sdl spice spice-gtk spice-vdagent qemu-hw-display-virtio-vga qemu-hw-display-virtio-vga-gl qemu-hw-display-virtio-gpu qemu-hw-display-virtio-gpu-gl qemu-hw-display-qxl virglrenderer qemu-hw-usb-redirect qemu-hw-usb-host qemu-ui-spice-app qemu-audio-spice virt-viewer qemu-audio-pa qemu-audio-pipewire libvirt cdrtools"
install "$virt_packages" pac

set user (whoami)
sudo usermod -aG libvirt $user

set src_dir "$HOME/.dotfiles/scripts/virtualization"
set dst_dir "/home/$user/.local/bin"

mkdir -p $dst_dir

for script in vm_download.sh vm_setup.sh vm_manager.sh
    if test -f "$src_dir/$script"
        sudo cp -a "$src_dir/$script" "$dst_dir/$script"
        sudo chmod 0755 "$dst_dir/$script"
    end
end

# Docker
header "Installing Docker"
set user (whoami)
if test "$initType" = systemD
    install "docker docker-compose" pac
    sudo systemctl start docker.service
    sudo usermod -aG docker $USER
    sudo chmod 666 /var/run/docker.sock
    sudo systemctl stop docker.service
    go install github.com/jesseduffield/lazydocker@latest
else
    install "docker-openrc docker-compose" pac
    sudo rc-update add docker default
    sudo rc-service docker start
    sudo usermod -aG docker $USER
    sudo chmod 666 /var/run/docker.sock
    sudo rc-update del docker default
    sudo rc-service docker stop
    go install github.com/jesseduffield/lazydocker@latest
end

# k8s
header "Installing kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl $HOME/.local/bin
go install github.com/derailed/k9s@latest

# Zed 
header "Installing Zed"
install zed pac

# Neovim
header "Installing Neovim"
install "tree-sitter tree-sitter-cli shfmt" pac
install neovim pac
pip install neovim black ruff djlint
npm i -g neovim typescript pyright vscode-langservers-extracted ls_emmet @fsouza/prettierd eslint_d diagnostic-languageserver bash-language-server @tailwindcss/language-server browser-sync graphql-language-service-cli
cp -r "$HOME/.dotfiles/configs/nvim" "$HOME/.config"
nvim --headless "+Lazy! sync" +qa

# Installing extra utilities
header "Installing extra utilities"
install "tesseract tesseract-data-eng" pac

# Configuring git
install "gitui github-cli" pac

git config --global user.name -
git config --global user.email -

echo "[core]
    pager = delta --syntax-theme gruvbox-dark

[interactive]
    diffFilter = delta --color-only --features=interactive

[delta]
    features = decorations

[delta \"interactive\"]
    keep-plus-minus-markers = false

[delta \"decorations\"]
    commit-decoration-style = blue ol
    commit-style = raw
    file-style = omit
    hunk-header-decoration-style = blue box
    hunk-header-file-style = red
    hunk-header-line-number-style = \"#067a00\"
    hunk-header-style = file line-number syntax" >>$HOME/.gitconfig
