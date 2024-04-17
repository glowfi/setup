#!/bin/fish

# Source Helper
set SCRIPT_DIR (cd (dirname (status -f)); and pwd)
source "$SCRIPT_DIR/helperf.fish"

# Git clone helper
function klone
    for i in (seq 10)
        git clone "$argv[1]" && break
    end
end

# Create the user local bin
mkdir -p $HOME/.local/bin/

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Installing Python Modules...------------------------------"
echo "------------------------------------------------------------------------"
echo ""

# FIX WARNING

set pyloc (sudo fd . /usr/lib/ --type f --max-depth 2 | grep "EXTERNALLY-MANAGED" | head -1)
sudo rm -rf "$pyloc"

# UPGRADE PIP TO LATEST VERSION

install "python-pip" "pac"

for i in (seq 2)
    python -m ensurepip --upgrade
    pip install --upgrade pip
    pip install setuptools
    pip install sortedcontainers
end

# ======================================================= Can Be Deleted for minimal install =======================================================

# PYTHON MODULES

for i in (seq 2)
    pip install virtualenv twine wheel
    pip install pygobject
end

# JUPYTER SETUP

for i in (seq 3)
    pip install jupyter pandas matplotlib numpy scikit-learn openpyxl xlrd networkx graphviz
    pip install notebook==6.4.12
    pip install pygments tqdm
    pip install lxml html5lib
    pip install notebook-as-pdf jupyter_contrib_nbextensions jupyter_nbextensions_configurator nbconvert
    jupyter contrib nbextension install --user
    jupyter nbextensions_configurator enable --user
    pyppeteer-install
    yes | pip uninstall notebook traitlets
    pip install notebook traitlets
end

# PYTHON MISC

pip install pyautogui pynput
pip install pyfzf
pip install poetry
pip install rich pygments

# Install Ollama

sudo echo ""
curl "https://ollama.ai/install.sh" | sh
nohup ollama serve &
rm nohup.out
nohup ollama serve &
rm nohup.out
ollama pull mistral
ollama pull zephyr:7b-beta
ps aux | grep -i 'ollama' | awk '{print $2}' | xargs -ro kill -9

# ======================================================= END ======================================================================================

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Installing Node Modules...--------------------------------"
echo "------------------------------------------------------------------------"
echo ""

# DOWNLOAD NODEJS

set ver (curl https://nodejs.org/en | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep -E "node-v"|head -1|cut -d"/" -f5|xargs)
wget "https://nodejs.org/dist/$ver/node-$ver-linux-x64.tar.xz" -O $HOME/node.tar.xz
tar -xf $HOME/node.tar.xz -C $HOME
rm -rf $HOME/node.tar.xz
mv $HOME/node-"$ver"-linux-x64 $HOME/.local/bin/nodeJS
source $HOME/.config/fish/config.fish

# NODE MODULES

for i in (seq 3)
    npm update -g npm
    npm install npm@latest -g
    npm i -g yarn
    npm i -g md-to-pdf
    sudo mv $HOME/.local/bin/nodeJS/lib/node_modules/md-to-pdf/node_modules/highlight.js/styles/base16/* $HOME/.local/bin/nodeJS/lib/node_modules/md-to-pdf/node_modules/highlight.js/styles
    sudo rm -rf $HOME/.local/bin/nodeJS/lib/node_modules/md-to-pdf/node_modules/highlight.js/styles/base16/
end

# ======================================================= Can Be Deleted for minimal install =======================================================

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Installing Rust...----------------------------------------"
echo "------------------------------------------------------------------------"
echo ""

# INSTALL RUST

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

klone "https://github.com/rust-analyzer/rust-analyzer.git"
cd rust-analyzer
rustup default stable
cargo xtask install --server
cd ..
rm -rf rust-analyzer

# RUST MODULES

cargo install ripdrag
cargo install csvlens
cargo install --git https://github.com/loichyan/nerdfix.git

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Installing Golang...--------------------------------------"
echo "------------------------------------------------------------------------"
echo ""

# INSTALL GOLANG

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

# GOLANG MODULES

go install golang.org/x/tools/gopls@latest
go install github.com/ericchiang/pup@latest

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Installing Clangd...--------------------------------------"
echo "------------------------------------------------------------------------"
echo ""

# INSTALL CLANGD LSP

install "clang" "pac"
set clangd_ver (curl "https://github.com/clangd/clangd" | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep -i "releases/tag" | cut -d"/" -f6|xargs)
wget "https://github.com/clangd/clangd/releases/download/$clangd_ver/clangd-linux-$clangd_ver.zip" -O $HOME/clangd.zip
unzip $HOME/clangd.zip -d $HOME
rm -rf $HOME/clangd.zip
mv $HOME/clangd_"$clangd_ver" $HOME/.local/bin/clangd
source $HOME/.config/fish/config.fish

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Installing LUA LSP AND LUA FORMATTER...-------------------"
echo "------------------------------------------------------------------------"
echo ""

# INSTALL LUA LSP

set lua_ver (curl "https://github.com/LuaLS/lua-language-server" | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep -i "releases/tag" | cut -d"/" -f6|xargs)
wget "https://github.com/LuaLS/lua-language-server/releases/download/$lua_ver/lua-language-server-$lua_ver-linux-x64.tar.gz" -O $HOME/lua-ls.tar.gz
mkdir -p $HOME/lua-ls
tar -xf $HOME/lua-ls.tar.gz -C $HOME/lua-ls/
rm -rf $HOME/lua-ls.tar.gz
mv $HOME/lua-ls $HOME/.local/bin/luaLSP

# INSTALL LUA FORAMTTER

cargo install stylua

# ======================================================= END ======================================================================================

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Installing Fuzzy File Finder (fzf)...---------------------"
echo "------------------------------------------------------------------------"
echo ""

# FZF TERMINAL INTEGRATION

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
yes | ~/.fzf/install

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Installing terminal utilities...--------------------------"
echo "------------------------------------------------------------------------"
echo ""

# INSTALL xhibit

# ===================== XORG Dependent ===================================
install "xorg-xdpyinfo xorg-xprop xorg-xwininfo xdotool" "pac"
# ===================== END Dependent ====================================
install "lsb-release" "pac"
pip install xhibit

# INSTALL sYT

pip install numerize
klone "https://github.com/glowfi/sYT"
cp -r sYT/sYT.py $HOME/.local/bin/
cp -r sYT/sYT.sh $HOME/.local/bin/
rm -rf sYT
chmod +x $HOME/.local/bin/sYT.py
chmod +x $HOME/.local/bin/sYT.sh
mkdir -p .config/mpv/scripts
touch $HOME/.config/mpv/mpv.conf
echo "script-opts-append=ytdl_hook-ytdl_path=yt-dlp" >>$HOME/.config/mpv/mpv.conf

# MPV Scripts

mkdir -p $HOME/.config/mpv/scripts
wget https://github.com/ekisu/mpv-webm/releases/download/latest/webm.lua -P $HOME/.config/mpv/scripts

wget https://github.com/marzzzello/mpv_thumbnail_script/releases/download/0.5.2/mpv_thumbnail_script_client_osc.lua -P $HOME/.config/mpv/scripts
wget https://github.com/marzzzello/mpv_thumbnail_script/releases/download/0.5.2/mpv_thumbnail_script_server.lua -P $HOME/.config/mpv/scripts
echo "osc=no" >>$HOME/.config/mpv/mpv.conf
echo 'save-position-on-quit' >>$HOME/.config/mpv/mpv.conf

cd .config/mpv/scripts/
klone "https://github.com/4ndrs/PureMPV"
cd

# SCRIPTS 

### Utils related scripts

# ===================== XORG Dependent ===================================
install "xorg-xrandr" "pac"
cp -r $HOME/setup/scripts/utils/dm-record.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/dm-record.sh
# ===================== END Dependent ====================================

cp -r $HOME/setup/scripts/utils/dm-bluetooth $HOME/.local/bin/
chmod +x $HOME/.local/bin/dm-bluetooth

cp -r $HOME/setup/scripts/utils/sgrec.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/sgrec.sh

cp -r $HOME/setup/scripts/utils/windowshot.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/windowshot.sh

cp -r $HOME/setup/scripts/utils/opa.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/opa.sh

cp -r $HOME/setup/scripts/utils/send.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/send.sh

cp -r $HOME/setup/scripts/utils/prev.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/prev.sh

cp -r $HOME/setup/scripts/utils/gtfu.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/gtfu.sh

cp -r $HOME/setup/scripts/utils/blank.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/blank.sh

cp -r $HOME/setup/scripts/utils/mp $HOME/.local/bin/
chmod +x $HOME/.local/bin/mp

cp -r $HOME/setup/scripts/utils/dex.py $HOME/.local/bin/
chmod +x $HOME/.local/bin/dex.py

cp -r $HOME/setup/scripts/utils/int.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/int.sh

cp -r $HOME/setup/scripts/utils/formatDisk.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/formatDisk.sh

cp -r $HOME/setup/scripts/utils/rename.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/rename.sh

cp -r $HOME/setup/scripts/utils/killprocess.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/killprocess.sh

cp -r $HOME/setup/scripts/utils/timer $HOME/.local/bin/
chmod +x $HOME/.local/bin/timer

cp -r $HOME/setup/scripts/utils/searchArchive.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/searchArchive.sh

cp -r $HOME/setup/scripts/utils/b64i $HOME/.local/bin/
chmod +x $HOME/.local/bin/b64i

cp -r $HOME/setup/scripts/utils/rlt $HOME/.local/bin/
chmod +x $HOME/.local/bin/rlt

cp -r $HOME/setup/scripts/utils/cpx $HOME/.local/bin/
chmod +x $HOME/.local/bin/cpx

klone "https://github.com/thameera/vimv"
cd vimv
cp -r vimv $HOME/.local/bin/
cd ..
rm -rf vimv

yes | pip uninstall pathlib
pip install pyinstaller
pip install ffmpeg-python typing-extensions
sudo pacman -S --noconfirm gifsicle
klone "https://github.com/winstxnhdw/ezgif-essentials"
cd ezgif-essentials
pyinstaller --onefile main.py
cd dist
mv ./main $HOME/.local/bin/ezgif
cd ../..
rm -rf ezgif-essentials
pip install pathlib
yes | pip uninstall pyinstaller
cp -r $HOME/setup/scripts/utils/edit.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/edit.sh

### System related scripts

cp -r $HOME/setup/scripts/system/bfilter.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/bfilter.sh

cp -r $HOME/setup/scripts/system/kdeconnect $HOME/.local/bin/
chmod +x $HOME/.local/bin/kdeconnect

cp -r $HOME/setup/scripts/system/lowbat.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/lowbat.sh

### Writing Tools

install "lorien-bin gromit-mpx" "yay"
install "kolourpaint" "pac"
cp -r $HOME/setup/scripts/system/klp $HOME/.local/bin/
chmod +x $HOME/.local/bin/klp

# ======================================================= Can Be Deleted for minimal install =======================================================

### SETUP DATABASE

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Setting up Database...------------------------------------"
echo "------------------------------------------------------------------------"
echo ""

install "dbeaver" "pac"
install "redis" "pac"
install "postgresql" "pac"
install "mongodb-bin mongodb-tools-bin" "yay"
sudo su - postgres -c "initdb --locale en_US.UTF-8 -D /var/lib/postgres/data;exit"
sudo systemctl start postgresql
sudo su - postgres -c "(echo $USER;echo 'password';echo 'password';echo y;)|createuser --interactive -P;createdb -O $USER delta;exit"
for i in (seq 2)
    pip install pgcli
end

### SETUP VIRTUALIZATION

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Setting up Virtualization...------------------------------"
echo "------------------------------------------------------------------------"
echo ""

bash -c '(
	echo y
	echo y
) | for i in {1..5}; do sudo pacman -S dnsmasq virt-manager qemu-base ebtables edk2-ovmf qemu-ui-sdl spice spice-gtk spice-vdagent qemu-hw-display-virtio-vga qemu-hw-display-virtio-vga-gl qemu-hw-display-virtio-gpu qemu-hw-display-virtio-gpu-gl qemu-hw-display-qxl virglrenderer qemu-hw-usb-redirect qemu-hw-usb-host qemu-ui-spice-app qemu-audio-spice virt-viewer qemu-audio-pa qemu-audio-pipewire && break || sleep 1; done'
install "libvirt" "pac"
install "cdrtools" "pac"
sudo usermod -G libvirt -a "$USER"
sudo systemctl start libvirtd
cp -r $HOME/setup/scripts/virtualization/vm_download.sh $HOME/setup/scripts/virtualization/vm_setup.sh $HOME/setup/scripts/virtualization/vm_manager.sh $HOME/setup/scripts/virtualization/vm-gpu-passthrough $HOME/.local/bin
chmod +x $HOME/.local/bin/vm_download.sh $HOME/.local/bin/vm_setup.sh $HOME/.local/bin/vm_manager.sh

# ======================================================= END ======================================================================================

### Restfox

install "restfox-bin" "yay"

### SETUP DOCKER

install "docker docker-compose" "pac"
sudo systemctl start docker.service
sudo usermod -aG docker $USER
sudo chmod 666 /var/run/docker.sock
sudo systemctl stop docker.service
# ======================================================= Can Be Deleted for minimal install =======================================================
go install github.com/jesseduffield/lazydocker@latest
# ======================================================= END ======================================================================================

### DOWNLOAD NEOVIM

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Installing the best text editor in the world...-----------"
echo "------------------------------------------------------------------------"
echo ""

for i in (seq 2)
    pip install neovim black flake8
    npm i -g neovim typescript pyright vscode-langservers-extracted ls_emmet @fsouza/prettierd eslint_d diagnostic-languageserver bash-language-server @tailwindcss/language-server browser-sync
    pip uninstall -y cmake
end

install "cmake ninja tree-sitter tree-sitter-cli xclip shfmt meson" "pac"
install "neovim" "pac"

# ======================================================= Can Be Deleted for minimal install =======================================================

for i in (seq 6)
    nvim --headless "+Lazy! sync" +qa
end

# ======================================================= END ======================================================================================


# MAKE NEOVIM HANDLE FILES IN PLAIN TEXT

xdg-mime default nvim.desktop text/plain


# COPY NEOVIM SETTINGS

cp -r $HOME/setup/configs/nvim $HOME/.config
cp -r $HOME/setup/configs/nvim/.vsnip/ $HOME

echo ""
echo "----------------------------------------------------"
echo "--------------Configuring git...--------------------"
echo "----------------------------------------------------"
echo ""

### Install Youtube-local

cd ~/.local/bin
klone "https://github.com/user234683/youtube-local"
cd youtube-local
python -m venv env
source "$HOME/.local/bin/youtube-local/env/bin/activate.fish"
pip install -r requirements.txt
cd

### Visualization

install "gource" "pac"

### OCR 

install "tesseract tesseract-data-eng" "pac"

### Ueberzug and Ueberzugpp

pip uninstall -y cmake
install "libxres openslide cmake chafa libvips libsixel python-opencv" "pac"
klone "https://github.com/jstkdng/ueberzugpp.git"
cd ueberzugpp
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
cmake --build .
mv ./ueberzug ./ueberzugpp
mv ./ueberzugpp ~/.local/bin/
cd ..;cd ..
rm -rf ueberzugpp

# ===================== XORG Dependent ===================================
klone "https://github.com/ueber-devel/ueberzug"
cd ueberzug/
pip install .
cd ..
rm -rf ueberzug
# ===================== END Dependent ====================================

echo ""
echo "----------------------------------------------------"
echo "--------------Configuring git...--------------------"
echo "----------------------------------------------------"
echo ""

### Configuring git

install "gitui github-cli" "pac"

git config --global user.name -
git config --global user.email -

echo "[core]
    pager = delta --syntax-theme 'gruvbox-dark'

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

### Add mongodb-compass

if test "$argv[1]" = "KDE"
    if test "$argv[2]" = "No"
        echo "yay -S --noconfirm mongodb-compass" >> "$SCRIPT_DIR/5_kde.sh"
    end
else
    if test "$argv[2]" = "No"
        echo "yay -S --noconfirm mongodb-compass" >> "$SCRIPT_DIR/5_dwm.sh"
    end
end
