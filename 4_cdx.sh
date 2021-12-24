#!/bin/fish

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Installing Python Modules...------------------------------"
echo "------------------------------------------------------------------------"
echo ""

# PYTHON MODULES

pip install jupyter pandas matplotlib numpy scikit-learn openpyxl xlrd
pip install virtualenv twine wheel

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
echo "---------------------------------------------------------------------------------------------"
echo "--------------Installing LUA LSP AND LUA FORMATTER...----------------------------------------"
echo "---------------------------------------------------------------------------------------------"
echo ""

# INSTALL LUA LSP

set lua_ver (curl https://github.com/sumneko/lua-language-server| grep "releases" | tail -2 | head -1 | awk '{print $6}'|awk -F "\/" '{print $NF}' | awk '{$0=substr($0,1,length($0)-2); print $0}')
wget "https://github.com/sumneko/lua-language-server/releases/download/$lua_ver/lua-language-server-$lua_ver-linux-x64.tar.gz" -O ~/lua-ls.tar.gz
mkdir -p ~/lua-ls
tar -xf ~/lua-ls.tar.gz -C ~/lua-ls/
rm -rf lua-ls.tar.gz 

# INSTALL LUA FORAMTTER

git clone --recurse-submodules https://github.com/Koihik/LuaFormatter.git
cd LuaFormatter
cmake .
make
sudo make install
cd ..
rm -rf LuaFormatter



echo ""
echo "-------------------------------------------------------------------------------"
echo "--------------Installing a Fuzzy File Finder...--------------------------------"
echo "-------------------------------------------------------------------------------"
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

# INSTALL RECORD SCRIPT 

cp -r ~/setup/scripts/record.sh ~/.local/bin/
chmod +x ~/.local/bin/record.sh

# ADDITIONAL SCRIPTS

git clone https://github.com/pystardust/ani-cli;
cd ani-cli
sudo make
cd ..
rm -rf ani-cli  

git clone https://github.com/pystardust/waldl
cp -r ./waldl/waldl .local/bin/
rm -rf waldl

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
# npx npm-check-updates -g | tail -2 | xargs -t -I {} fish -c "{}" 
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
