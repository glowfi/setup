#!/bin/fish

### PACKAGES
sudo pacman -S --noconfirm postgresql python-pip gitui github-cli
yay -S --noconfirm mongodb-bin insomnia-bin
cp -r ~/setup/configs/Insomnia/ ~/.config

echo ""
echo ------------------------------------------------------------------------
echo "--------------Installing Python Modules...------------------------------"
echo ------------------------------------------------------------------------
echo ""

# UPGRADE PIP TO LATEST VERSION

python -m ensurepip --upgrade

# PYTHON MODULES

pip install jupyter pandas matplotlib numpy scikit-learn openpyxl xlrd
pip install virtualenv twine wheel

# JUPYTER SETUP

pip install notebook-as-pdf jupyter_contrib_nbextensions jupyter_nbextensions_configurator nbconvert lxml pygments
jupyter contrib nbextension install --user
jupyter nbextensions_configurator enable --user
pyppeteer-install

# PYTHON MISC

pip install ueberzug

echo ""
echo ------------------------------------------------------------------------
echo "--------------Installing Node Modules...--------------------------------"
echo ------------------------------------------------------------------------
echo ""

# DOWNLOAD NODEJS

set ver (curl -s https://nodejs.org/en/ | grep -e "Current" | tail -1|xargs| cut -d " " -f 1)
wget https://nodejs.org/dist/v$ver/node-v$ver-linux-x64.tar.xz -O ~/node.tar.xz
tar -xf ~/node.tar.xz -C ~
rm -rf ~/node.tar.xz
mv ~/node-v"$ver"-linux-x64 ~/.local/bin/nodeJS
source ~/.config/fish/config.fish

# NODE MODULES

npm i -g yarn

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
go install github.com/mholt/archiver/v3/cmd/arc@latest

echo ""
echo --------------------------------------------------------------------------
echo "--------------Installing Clangd...----------------------------------------"
echo --------------------------------------------------------------------------
echo ""

# INSTALL CLANGD LSP

set clangd_ver (echo "14.0.3")
sudo pacman -S --noconfirm clang
wget "https://github.com/clangd/clangd/releases/download/$clangd_ver/clangd-linux-$clangd_ver.zip" -O ~/clangd.zip
unzip ~/clangd.zip -d ~
rm -rf clangd.zip
mv ~/clangd_"$clangd_ver" ~/.local/bin/clangd
source ~/.config/fish/config.fish



echo ""
echo ---------------------------------------------------------------------------------------------
echo "--------------Installing LUA LSP AND LUA FORMATTER...----------------------------------------"
echo ---------------------------------------------------------------------------------------------
echo ""

# INSTALL LUA LSP

set lua_ver (echo "3.2.4")
wget "https://github.com/sumneko/lua-language-server/releases/download/$lua_ver/lua-language-server-$lua_ver-linux-x64.tar.gz" -O ~/lua-ls.tar.gz
mkdir -p ~/lua-ls
tar -xf ~/lua-ls.tar.gz -C ~/lua-ls/
rm -rf lua-ls.tar.gz
mv ~/lua-ls ~/.local/bin/luaLSP

# INSTALL LUA FORAMTTER

cargo install stylua

echo ""
echo -----------------------------------------------------------------------------------
echo "--------------Installing Fuzzy File Finder (fzf)...--------------------------------"
echo -----------------------------------------------------------------------------------
echo ""


# FZF TERMINAL INTEGRATION

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
yes | ~/.fzf/install

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

pip install xhibit

# INSTALL sYT

sudo pacman -S --noconfirm jq aria2
git clone https://github.com/glowfi/sYT
cp -r sYT/sYT.py ~/.local/bin/
cp -r sYT/sYT.sh ~/.local/bin/
rm -rf sYT
chmod +x ~/.local/bin/sYT.py
chmod +x ~/.local/bin/sYT.sh
mkdir -p .config/mpv/scripts
touch ~/.config/mpv/mpv.conf
echo "script-opts-append=ytdl_hook-ytdl_path=yt-dlp" >>~/.config/mpv/mpv.conf

# ADDITIONAL SCRIPTS

cp -r ~/setup/scripts/int.sh ~/.local/bin/
chmod +x ~/.local/bin/int.sh

cp -r ~/setup/scripts/formatDisk.sh ~/.local/bin/
chmod +x ~/.local/bin/formatDisk.sh

cp -r ~/setup/scripts/rename.sh ~/.local/bin/
chmod +x ~/.local/bin/rename.sh

sudo pacman -S --noconfirm xorg-xdpyinfo xdotool xorg-xprop xorg-xwininfo
cp -r ~/setup/scripts/dm-record.sh ~/.local/bin/
chmod +x ~/.local/bin/dm-record.sh

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

yay -S --noconfirm ani-cli-git
sudo sed -i '141s/.*/yt-dlp --external-downloader aria2c --external-downloader-args \"-j 16 -x 16 -s 16 -k 1M\" \"\$2\" -o \"\$download_dir\/\$3.mp4\";;/' /usr/bin/ani-cli
sudo sed -i '143s/.*/yt-dlp --external-downloader aria2c --external-downloader-args \"-j 16 -x 16 -s 16 -k 1M\" \"\$2\" -o \"\$download_dir\/\$3.mp4\";;/' /usr/bin/ani-cli

git clone https://github.com/mov-cli/mov-cli
cd mov-cli
cp -r ~/setup/scripts/scraper.py ./mov_cli/utils/
pip install -r requirements.txt
python setup.py install --user
cd ..
rm -rf mov-cli

git clone https://github.com/thameera/vimv
cd vimv
cp -r vimv ~/.local/bin/
cd ..
rm -rf vimv

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

pip install neovim black flake8
npm i -g neovim typescript typescript-language-server pyright vscode-langservers-extracted ls_emmet @fsouza/prettierd eslint_d diagnostic-languageserver browser-sync
sudo pacman -S --noconfirm cmake unzip ninja tree-sitter xclip shfmt
git clone https://github.com/neovim/neovim --depth 1
cd neovim
sudo make CMAKE_BUILD_TYPE=Release install
cd ..
sudo rm -r neovim

# MAKE NEOVIM HANDLE FILES IN PLAIN TEXT

xdg-mime default nvim.desktop text/plain


# COPY NEOVIM SETTINGS

cp -r ~/setup/configs/nvim ~/.config
nvim -c PackerSync
nvim -c PackerSync
nvim -c PackerSync


# CONFIGURING GIT ALIASES

git config --global user.name -
git config --global user.email -
