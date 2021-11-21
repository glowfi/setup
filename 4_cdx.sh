#!/bin/fish

echo "------------------------------------------------------------------------"
echo "--------------Installing Python Modules...------------------------------"
echo "------------------------------------------------------------------------"

# PYTHON MODULES

pip install jupyter pandas matplotlib numpy scikit-learn openpyxl xlrd
pip install virtualenv

# JUPYTER SETUP

pip install notebook-as-pdf  jupyter_contrib_nbextensions jupyter_nbextensions_configurator nbconvert
jupyter contrib nbextension install --user
jupyter nbextensions_configurator enable --user
pyppeteer-install

echo "------------------------------------------------------------------------"
echo "--------------Installing Node Modules...--------------------------------"
echo "------------------------------------------------------------------------"

# DOWNLOAD NODEJS

wget https://nodejs.org/dist/v17.1.0/node-v17.1.0-linux-x64.tar.xz -O ~/node.tar.xz
tar -xf ~/node.tar.xz -C ~
rm -rf ~/node.tar.xz

# NODE MODULES

npm i -g yarn

echo "-------------------------------------------------------------------------------"
echo "--------------Installing a Fuzzy File Finder...--------------------------------"
echo "-------------------------------------------------------------------------------"

# FZF TERMINAL INTEGRATION

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

echo "-------------------------------------------------------------------------------"
echo "--------------Installing terminal utilities...---------------------------------"
echo "-------------------------------------------------------------------------------"

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

pip install tcolorpy
sudo pacman -S --noconfirm wmctrl
git clone https://github.com/glowfi/xhibit
cd xhibit
cp -r ./xhibit.py ~/.local/bin/
cd ..
rm -rf xhibit
chmod +x ~/.local/bin/xhibit.py

# SETUP POSTGRES

echo "-------------------------------------------------------------------------------"
echo "--------------Setuping Database...---------------------------------------------"
echo "-------------------------------------------------------------------------------"

sudo su - postgres -c "initdb --locale en_US.UTF-8 -D /var/lib/postgres/data;exit"
sudo systemctl start postgresql
sudo su - postgres -c "(echo $USER;echo 'password';echo 'password';echo y;)|createuser --interactive -P;createdb -O $USER delta;exit"

# DOWNLOAD NEOVIM

echo "---------------------------------------------------------------------------------------------"
echo "--------------Installing the best text editor in the world...--------------------------------"
echo "---------------------------------------------------------------------------------------------"

pip install neovim ueberzug black flake8
npm i -g neovim typescript typescript-language-server pyright vscode-langservers-extracted ls_emmet @fsouza/prettierd eslint_d diagnostic-languageserver browser-sync
npx npm-check-updates -g
sudo pacman -S --noconfirm cmake unzip ninja tree-sitter xclip
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
