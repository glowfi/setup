#!/bin/fish

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Installing Python Modules...------------------------------"
echo "------------------------------------------------------------------------"
echo ""

# UPGRADE PIP TO LATEST VERSION

python -m ensurepip --upgrade

# PYTHON MODULES

pip install jupyter pandas matplotlib numpy scikit-learn openpyxl xlrd
pip install virtualenv twine wheel
pip install lookatme lookatme.contrib.qrcode lookatme.contrib.image_ueberzug lookatme.contrib.render

# JUPYTER SETUP

pip install notebook-as-pdf  jupyter_contrib_nbextensions jupyter_nbextensions_configurator nbconvert lxml pygments
jupyter contrib nbextension install --user
jupyter nbextensions_configurator enable --user
pyppeteer-install

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Installing Node Modules...--------------------------------"
echo "------------------------------------------------------------------------"
echo ""

# DOWNLOAD NODEJS

set ver (curl -s https://nodejs.org/en/ | grep -e "Current" -e | tail -1|xargs| cut -d " " -f 1)
set line (echo "set PATH ~/node-v$ver-linux-x64/bin/ \$PATH # Sets NodeJS paths")
echo $line | xargs -t -I {} awk 'NR==14{print "{}"}1' ~/.config/fish/config.fish > ~/config.fish 
sed -i '15d' ~/config.fish
cp -r ~/config.fish ~/.config/fish/config.fish
rm -rf ~/config.fish
echo ""
wget https://nodejs.org/dist/v$ver/node-v$ver-linux-x64.tar.xz -O ~/node.tar.xz
tar -xf ~/node.tar.xz -C ~
rm -rf ~/node.tar.xz
source ~/.config/fish/config.fish

# NODE MODULES

npm i -g yarn

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Installing Rust...----------------------------------------"
echo "------------------------------------------------------------------------"
echo ""

# INSTALL RUST

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
git clone https://github.com/rust-analyzer/rust-analyzer.git 
cd rust-analyzer 
cargo xtask install --server
cd .. 
rm -rf rust-analyzer

echo ""
echo "--------------------------------------------------------------------------"
echo "--------------Installing Golang...----------------------------------------"
echo "--------------------------------------------------------------------------"
echo ""

# INSTALL GOLANG

curl https://go.dev/dl/ |grep -e "linux" | head -2 | grep -e "href" | awk -F "href" '{print $2}' | tr -d "=" | tr -d ">" | xargs -I {} wget  https://go.dev{} -O go.tar.gz
tar -xzf go.tar.gz
rm -rf go.tar.gz

# GOLANG MODULES 

go get github.com/ericchiang/pup
go install golang.org/x/tools/gopls@latest
go install github.com/mholt/archiver/v3/cmd/arc@latest

echo ""
echo "--------------------------------------------------------------------------"
echo "--------------Installing Clangd...----------------------------------------"
echo "--------------------------------------------------------------------------"
echo ""

# INSTALL CLANGD LSP

set clangd_ver (echo "13.0.0")
sudo pacman -S --noconfirm clang
wget "https://github.com/clangd/clangd/releases/download/$clangd_ver/clangd-linux-$clangd_ver.zip" -O ~/clangd.zip
unzip ~/clangd.zip -d ~
rm -rf clangd.zip

set line (echo "set PATH ~/clangd_$clangd_ver/bin \$PATH # Sets clangd path")
echo $line | xargs -t -I {} awk 'NR==18{print "{}"}1' ~/.config/fish/config.fish > ~/config.fish 
sed -i '19d' ~/config.fish
cp -r ~/config.fish ~/.config/fish/config.fish
rm -rf ~/config.fish
source ~/.config/fish/config.fish



echo ""
echo "---------------------------------------------------------------------------------------------"
echo "--------------Installing LUA LSP AND LUA FORMATTER...----------------------------------------"
echo "---------------------------------------------------------------------------------------------"
echo ""

# INSTALL LUA LSP

set lua_ver (echo "2.6.6")
wget "https://github.com/sumneko/lua-language-server/releases/download/$lua_ver/lua-language-server-$lua_ver-linux-x64.tar.gz" -O ~/lua-ls.tar.gz
mkdir -p ~/lua-ls
tar -xf ~/lua-ls.tar.gz -C ~/lua-ls/
rm -rf lua-ls.tar.gz 

# INSTALL LUA FORAMTTER

cargo install stylua



echo ""
echo "-----------------------------------------------------------------------------------"
echo "--------------Installing Fuzzy File Finder (fzf)...--------------------------------"
echo "-----------------------------------------------------------------------------------"
echo ""


# FZF TERMINAL INTEGRATION

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
yes | ~/.fzf/install

echo ""
echo "-------------------------------------------------------------------------------"
echo "--------------Installing terminal utilities...---------------------------------"
echo "-------------------------------------------------------------------------------"
echo ""

# INSTALL CHECKUR

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
cd sYT
cp -r ./sYT.py ~/.local/bin/
cp -r ./sYT.sh ~/.local/bin/
cd ..
rm -rf sYT
chmod +x ~/.local/bin/sYT.py
chmod +x ~/.local/bin/sYT.sh
mkdir -p .config/mpv/scripts;
wget https://raw.githubusercontent.com/Samillion/mpv-ytdlautoformat/master/ytdlautoformat.lua -O ytdlautoformat.lua;
rm -rf ytdlautoformat.lua.1;
cp -r ./ytdlautoformat.lua ~/.config/mpv/scripts/;
rm -rf ytdlautoformat.lua

# ADDITIONAL SCRIPTS

cp -r ~/setup/dmenu-scripts/dm-wifi.sh ~/.local/bin/
chmod +x ~/.local/bin/dm-wifi.sh

sudo pacman -S --noconfirm xorg-xdpyinfo xdotool xorg-xprop xorg-xwininfo
cp -r ~/setup/dmenu-scripts/dm-record.sh ~/.local/bin/
chmod +x ~/.local/bin/dm-record.sh

cp -r ~/setup/scripts/sgrec.sh ~/.local/bin/
chmod +x ~/.local/bin/sgrec.sh

cp -r ~/setup/scripts/opa.sh ~/.local/bin/
chmod +x ~/.local/bin/opa.sh

cp -r ~/setup/scripts/send.sh ~/.local/bin/
chmod +x ~/.local/bin/send.sh

git clone https://github.com/pystardust/ani-cli;
cp -r ani-cli/ani-cli ~/.local/bin
rm -rf ani-cli 

git clone https://github.com/thameera/vimv
cd vimv
cp -r vimv ~/.local/bin/
cd ..
rm -rf vimv 

# SETUP POSTGRES

echo ""
echo "---------------------------------------------------------------------------------"
echo "--------------Setting up Database...---------------------------------------------"
echo "---------------------------------------------------------------------------------"
echo ""

sudo su - postgres -c "initdb --locale en_US.UTF-8 -D /var/lib/postgres/data;exit"
sudo systemctl start postgresql
sudo su - postgres -c "(echo $USER;echo 'password';echo 'password';echo y;)|createuser --interactive -P;createdb -O $USER delta;exit"

# DOWNLOAD NEOVIM

echo ""
echo "---------------------------------------------------------------------------------------------"
echo "--------------Installing the best text editor in the world...--------------------------------"
echo "---------------------------------------------------------------------------------------------"
echo ""

pip install neovim ueberzug black flake8
npm i -g neovim typescript typescript-language-server pyright vscode-langservers-extracted ls_emmet @fsouza/prettierd eslint_d diagnostic-languageserver browser-sync
sudo pacman -S --noconfirm cmake unzip ninja tree-sitter xclip shfmt
git clone https://github.com/neovim/neovim --depth 1
cd neovim
sudo make CMAKE_BUILD_TYPE=Release install
cd ..
sudo rm -r neovim


# COPY NEOVIM SETTINGS

cp -r ~/setup/configs/nvim ~/.config
nvim -c "PackerSync"
nvim -c "PackerSync"
nvim -c "PackerSync"


# CONFIGURING GIT ALIASES

git config --global user.name "-";git config --global user.email "-"
