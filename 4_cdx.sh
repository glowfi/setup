#!/bin/fish

# Source Helper
set SCRIPT_DIR (cd (dirname (status -f)); and pwd)
source "$SCRIPT_DIR/helperf.fish"

### PACKAGES
install "postgresql python-pip gitui github-cli" "pac"
install "insomnia-bin" "yay"
cp -r ~/setup/configs/Insomnia/ ~/.config

echo ""
echo ------------------------------------------------------------------------
echo "--------------Installing Python Modules...------------------------------"
echo ------------------------------------------------------------------------
echo ""

# FIX WARNING

sudo rm -rf /usr/lib/python3.11/EXTERNALLY-MANAGED

# UPGRADE PIP TO LATEST VERSION

for i in (seq 2)
python -m ensurepip --upgrade
pip install --upgrade pip
pip install setuptools
end

# PYTHON MODULES

for i in (seq 2)
pip install virtualenv twine wheel
end

# JUPYTER SETUP

for i in (seq 2)
pip install jupyter pandas matplotlib numpy scikit-learn openpyxl xlrd
pip install notebook-as-pdf jupyter_contrib_nbextensions jupyter_nbextensions_configurator nbconvert lxml pygments
jupyter contrib nbextension install --user
jupyter nbextensions_configurator enable --user
pyppeteer-install
end

# PYTHON MISC

pip install pyfzf

install "libxres" "pac"
git clone "https://github.com/glowfi/ueberzug-tabbed"
cd ueberzug-tabbed
python -m pip install .
cd ..
rm -rf ueberzug-tabbed

echo ""
echo ------------------------------------------------------------------------
echo "--------------Installing Node Modules...--------------------------------"
echo ------------------------------------------------------------------------
echo ""

# DOWNLOAD NODEJS

set ver (echo "20.3.0")
wget https://nodejs.org/dist/v$ver/node-v$ver-linux-x64.tar.xz -O ~/node.tar.xz
tar -xf ~/node.tar.xz -C ~
rm -rf ~/node.tar.xz
mv ~/node-v"$ver"-linux-x64 ~/.local/bin/nodeJS
source ~/.config/fish/config.fish

# NODE MODULES

npm i -g yarn
npm update -g npm
npm install npm@latest -g

echo ""
echo ------------------------------------------------------------------------
echo "--------------Installing Rust...----------------------------------------"
echo ------------------------------------------------------------------------
echo ""

# INSTALL RUST

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
git clone https://github.com/rust-analyzer/rust-analyzer.git
cd rust-analyzer
cargo xtask install --server
cd ..
rm -rf rust-analyzer


echo ""
echo --------------------------------------------------------------------------
echo "--------------Installing Golang...----------------------------------------"
echo --------------------------------------------------------------------------
echo ""

# INSTALL GOLANG

curl https://go.dev/dl/ | grep -e linux | head -2 | grep -e href | awk -F href '{print $2}' | tr -d "=" | tr -d ">" | xargs -I {} wget https://go.dev{} -O go.tar.gz
tar -xzf go.tar.gz
rm -rf go.tar.gz

# GOLANG MODULES

go install golang.org/x/tools/gopls@latest

echo ""
echo --------------------------------------------------------------------------
echo "--------------Installing Clangd...----------------------------------------"
echo --------------------------------------------------------------------------
echo ""

# INSTALL CLANGD LSP

set clangd_ver (echo "15.0.6")
install "clang" "pac"
wget "https://github.com/clangd/clangd/releases/download/$clangd_ver/clangd-linux-$clangd_ver.zip" -O ~/clangd.zip
unzip ~/clangd.zip -d ~
rm -rf ~/clangd.zip
mv ~/clangd_"$clangd_ver" ~/.local/bin/clangd
source ~/.config/fish/config.fish



echo ""
echo ---------------------------------------------------------------------------------------------
echo "--------------Installing LUA LSP AND LUA FORMATTER...----------------------------------------"
echo ---------------------------------------------------------------------------------------------
echo ""

# INSTALL LUA LSP

set lua_ver (echo "3.6.10")
wget "https://github.com/sumneko/lua-language-server/releases/download/$lua_ver/lua-language-server-$lua_ver-linux-x64.tar.gz" -O ~/lua-ls.tar.gz
mkdir -p ~/lua-ls
tar -xf ~/lua-ls.tar.gz -C ~/lua-ls/
rm -rf ~/lua-ls.tar.gz
mv ~/lua-ls ~/.local/bin/luaLSP

# INSTALL LUA FORAMTTER

cargo install stylua

echo ""
echo -----------------------------------------------------------------------------------
echo "--------------Installing Fuzzy File Finder (fzf)...--------------------------------"
echo -----------------------------------------------------------------------------------
echo ""


# FZF TERMINAL INTEGRATION

install "fzf" "pac"

echo ""
echo -------------------------------------------------------------------------------
echo "--------------Installing terminal utilities...---------------------------------"
echo -------------------------------------------------------------------------------
echo ""

# INSTALL checkur

mkdir -p ~/.local/bin
pip install rich
git clone https://github.com/glowfi/check-ur-requests
cd check-ur-requests
cp -r ./checkur.py ~/.local/bin/
cd ..
rm -rf check-ur-requests
chmod +x ~/.local/bin/checkur.py

# INSTALL xhibit

install "lsb-release" "pac"
pip install xhibit

# INSTALL sYT

pip install numerize
install "jq aria2" "pac"
git clone https://github.com/glowfi/sYT
cp -r sYT/sYT.py ~/.local/bin/
cp -r sYT/sYT.sh ~/.local/bin/
rm -rf sYT
chmod +x ~/.local/bin/sYT.py
chmod +x ~/.local/bin/sYT.sh
mkdir -p .config/mpv/scripts
touch ~/.config/mpv/mpv.conf
echo "script-opts-append=ytdl_hook-ytdl_path=yt-dlp" >>~/.config/mpv/mpv.conf

# MPV Scripts

mkdir -p $HOME/.config/mpv/scripts
wget https://github.com/ekisu/mpv-webm/releases/download/latest/webm.lua -P $HOME/.config/mpv/scripts

wget https://github.com/marzzzello/mpv_thumbnail_script/releases/download/0.5.2/mpv_thumbnail_script_client_osc.lua -P $HOME/.config/mpv/scripts
wget https://github.com/marzzzello/mpv_thumbnail_script/releases/download/0.5.2/mpv_thumbnail_script_server.lua -P $HOME/.config/mpv/scripts
echo "osc=no" >>~/.config/mpv/mpv.conf

cd .config/mpv/scripts/;git clone https://github.com/4ndrs/PureMPV;cd

# ADDITIONAL SCRIPTS

cp -r ~/setup/scripts/int.sh ~/.local/bin/
chmod +x ~/.local/bin/int.sh

cp -r ~/setup/scripts/formatDisk.sh ~/.local/bin/
chmod +x ~/.local/bin/formatDisk.sh

cp -r ~/setup/scripts/rename.sh ~/.local/bin/
chmod +x ~/.local/bin/rename.sh

install "xorg-xdpyinfo xdotool xorg-xprop xorg-xwininfo" "pac"
cp -r ~/setup/scripts/dm-record.sh ~/.local/bin/
chmod +x ~/.local/bin/dm-record.sh

cp -r ~/setup/scripts/dmenu-bluetooth ~/.local/bin/
chmod +x ~/.local/bin/dmenu-bluetooth

cp -r ~/setup/scripts/sgrec.sh ~/.local/bin/
chmod +x ~/.local/bin/sgrec.sh

cp -r ~/setup/scripts/windowshot.sh ~/.local/bin/
chmod +x ~/.local/bin/windowshot.sh

cp -r ~/setup/scripts/opa.sh ~/.local/bin/
chmod +x ~/.local/bin/opa.sh

cp -r ~/setup/scripts/send.sh ~/.local/bin/
chmod +x ~/.local/bin/send.sh

cp -r ~/setup/scripts/prev.sh ~/.local/bin/
chmod +x ~/.local/bin/prev.sh

cp -r ~/setup/scripts/gtfu.sh ~/.local/bin/
chmod +x ~/.local/bin/gtfu.sh

cp -r ~/setup/scripts/lowbat.sh ~/.local/bin/
chmod +x ~/.local/bin/lowbat.sh

install "ani-cli-git" "yay"

pip install poetry
git clone https://github.com/mov-cli/mov-cli
cd mov-cli
cp -r ~/setup/scripts/scraper.py ./mov_cli/utils/
pip install -r requirements.txt
poetry build
pip install dist/*.tar.gz
cd ..
rm -rf mov-cli

git clone https://github.com/thameera/vimv
cd vimv
cp -r vimv ~/.local/bin/
cd ..
rm -rf vimv

cp -r ~/setup/scripts/dex.py ~/.local/bin/
chmod +x ~/.local/bin/dex.py

wget https://git.io/translate -O trans
chmod +x ./trans
mv ./trans ~/.local/bin/
cp -r ~/setup/scripts/tran.sh ~/.local/bin/
chmod +x ~/.local/bin/tran.sh

cp -r ~/setup/scripts/fixWords.py ~/.local/bin/
chmod +x ~/.local/bin/fixWords.py

# ADDITIONAL PROGRAMS

install "atbswp" "yay"
install "tk python-wxpython" "pac"
pip install pyautogui pynput

# SETUP DOCKER

install "docker" "pac"
sudo systemctl start docker.service
sudo usermod -aG docker $USER
sudo chmod 666 /var/run/docker.sock
sudo systemctl stop docker.service && sudo systemctl disable docker.service


# SETUP POSTGRES

echo ""
echo ---------------------------------------------------------------------------------
echo "--------------Setting up Database...---------------------------------------------"
echo ---------------------------------------------------------------------------------
echo ""

sudo su - postgres -c "initdb --locale en_US.UTF-8 -D /var/lib/postgres/data;exit"
sudo systemctl start postgresql
sudo su - postgres -c "(echo $USER;echo 'password';echo 'password';echo y;)|createuser --interactive -P;createdb -O $USER delta;exit"

# DOWNLOAD NEOVIM

echo ""
echo ---------------------------------------------------------------------------------------------
echo "--------------Installing the best text editor in the world...--------------------------------"
echo ---------------------------------------------------------------------------------------------
echo ""

for i in (seq 2)
pip install neovim black flake8 beautysh
npm i -g neovim typescript typescript-language-server pyright vscode-langservers-extracted ls_emmet @fsouza/prettierd eslint_d diagnostic-languageserver bash-language-server browser-sync
pip uninstall -y cmake
end
install "cmake ninja tree-sitter xclip" "pac"
git clone https://github.com/neovim/neovim --depth 1
cd neovim
sudo make CMAKE_BUILD_TYPE=Release install || install "neovim" "pac"
cd ..
sudo rm -rf neovim

# MAKE NEOVIM HANDLE FILES IN PLAIN TEXT

xdg-mime default nvim.desktop text/plain


# COPY NEOVIM SETTINGS

cp -r ~/setup/configs/nvim ~/.config
nvim -c PackerSync
nvim -c PackerSync
nvim -c PackerSync


# CONFIGURING GIT

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
    hunk-header-style = file line-number syntax
" >>~/.gitconfig
