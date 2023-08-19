#!/bin/fish

# Source Helper
set SCRIPT_DIR (cd (dirname (status -f)); and pwd)
source "$SCRIPT_DIR/helperf.fish"

### PACKAGES
install "postgresql python-pip gitui github-cli" "pac"
install "insomnia-bin" "yay"
cp -r $HOME/setup/configs/Insomnia/ $HOME/.config

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

install "libxres openslide" "pac"
install "ueberzugpp" "yay"

# Install pyenv , setup local GPT

echo ""
echo -----------------------------------------------------------------------------------------------------------------
echo "--------------Installing pyenv , Setting up local GPT , Installing base packages...------------------------------"
echo -----------------------------------------------------------------------------------------------------------------
echo ""

cd

### Utility Function to download
function download
    aria2c -j 16 -x 16 -s 16 -k 1M "$argv[1]" -o "$argv[2]"
end

### System Modules
install "cuda cudnn python-tensorflow-opt-cuda python-opt_einsum numactl" "pac"
install "python-opencv" "pac"

### Install Pyenv

# Download pyenv
curl https://pyenv.run | bash

# Create a Virtual env
set venvname (echo "play")
pyenv virtualenv "$venvname"
set venvLocation (echo "$HOME/.pyenv/versions/$venvname/bin/activate.fish")
source "$venvLocation"

### Setup local GPT

# Clone Repo
git clone https://github.com/h2oai/h2ogpt
cd h2ogpt
pip install -r requirements.txt
pip install -r reqs_optional/requirements_optional_langchain.txt
pip install -r reqs_optional/requirements_optional_gpt4all.txt

# Download LLM Models
download "https://huggingface.co/TheBloke/Llama-2-7B-Chat-GGML/resolve/main/llama-2-7b-chat.ggmlv3.q8_0.bin" "llama-2-7b-chat.ggmlv3.q8_0.bin"
download "https://huggingface.co/TheBloke/CodeUp-Llama-2-13B-Chat-HF-GGML/resolve/main/codeup-llama-2-13b-chat-hf.ggmlv3.q4_K_S.bin" "llama-2-13b-chat-hf.ggmlv3.q4_K_S.bin"

# Create a script
echo 'python generate.py --base_model="llama" --model-path=llama-2-13b-chat-hf.ggmlv3.q4_K_S.bin --prompt_type=llama2 --hf_embedding_model=sentence-transformers/all-MiniLM-L6-v2 --langchain_mode=UserData --user_path=user_path --llamacpp_dict="{'n_gpu_layers':25,'n_batch':128,'n_threads':6}" --load_8bit=True' > run.sh
chmod +x run.sh

### Install Base Packages for this env

for i in (seq 2)
    pip install torch torchvision torchaudio
    pip install opencv-contrib-python
    pip install wrapt gast astunparse opt_einsum
    pip uninstall tensorflow
end

### Copy and Download required scripts

# Copy tensorflow
set destinationLocation (echo "$HOME/.pyenv/versions/$venvname/lib/python3.11/site-packages/")
sudo cp -r /usr/lib/python3.11/site-packages/tensorflow "$destinationLocation"

# Copy libiomp5.so
set libiomp5Location (fd . /usr/lib/python3.11/site-packages | grep "solib" | head -1)
sudo cp -r "$libiomp5Location" "$destinationLocation"

# Copy a script
pip install -U g4f
cp -r $HOME/setup/scripts/ai .
chmod +x ai

### Cleanup

deactivate
rm -rf blog/ ci/ docs .git papers/ docker-compose.yml Dockerfile h2o-logo.svg LICENSE README.md
cd ..
mv h2ogpt llm
cd


echo ""
echo ------------------------------------------------------------------------
echo "--------------Installing Node Modules...--------------------------------"
echo ------------------------------------------------------------------------
echo ""

# DOWNLOAD NODEJS

set ver (echo "20.3.0")
wget https://nodejs.org/dist/v$ver/node-v$ver-linux-x64.tar.xz -O $HOME/node.tar.xz
tar -xf $HOME/node.tar.xz -C $HOME
rm -rf $HOME/node.tar.xz
mv $HOME/node-v"$ver"-linux-x64 $HOME/.local/bin/nodeJS
source $HOME/.config/fish/config.fish

# NODE MODULES

npm i -g yarn
npm update -g npm
npm install npm@latest -g
npm i -g md-to-pdf
sudo mv $HOME/.local/bin/nodeJS/lib/node_modules/md-to-pdf/node_modules/highlight.js/styles/base16/* $HOME/.local/bin/nodeJS/lib/node_modules/md-to-pdf/node_modules/highlight.js/styles
sudo rm -rf $HOME/.local/bin/nodeJS/lib/node_modules/md-to-pdf/node_modules/highlight.js/styles/base16/

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

# RUST MODULES

cargo install ripdrag

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
wget "https://github.com/clangd/clangd/releases/download/$clangd_ver/clangd-linux-$clangd_ver.zip" -O $HOME/clangd.zip
unzip $HOME/clangd.zip -d $HOME
rm -rf $HOME/clangd.zip
mv $HOME/clangd_"$clangd_ver" $HOME/.local/bin/clangd
source $HOME/.config/fish/config.fish



echo ""
echo ---------------------------------------------------------------------------------------------
echo "--------------Installing LUA LSP AND LUA FORMATTER...----------------------------------------"
echo ---------------------------------------------------------------------------------------------
echo ""

# INSTALL LUA LSP

set lua_ver (echo "3.6.10")
wget "https://github.com/sumneko/lua-language-server/releases/download/$lua_ver/lua-language-server-$lua_ver-linux-x64.tar.gz" -O $HOME/lua-ls.tar.gz
mkdir -p $HOME/lua-ls
tar -xf $HOME/lua-ls.tar.gz -C $HOME/lua-ls/
rm -rf $HOME/lua-ls.tar.gz
mv $HOME/lua-ls $HOME/.local/bin/luaLSP

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

mkdir -p $HOME/.local/bin
pip install rich
git clone https://github.com/glowfi/check-ur-requests
cd check-ur-requests
cp -r ./checkur.py $HOME/.local/bin/
cd ..
rm -rf check-ur-requests
chmod +x $HOME/.local/bin/checkur.py

# INSTALL xhibit

install "lsb-release" "pac"
pip install xhibit

# INSTALL sYT

pip install numerize
install "jq aria2" "pac"
git clone https://github.com/glowfi/sYT
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

cd .config/mpv/scripts/;git clone https://github.com/4ndrs/PureMPV;cd

# ADDITIONAL SCRIPTS

cp -r $HOME/setup/scripts/int.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/int.sh

cp -r $HOME/setup/scripts/speech2text $HOME/.local/bin/
chmod +x $HOME/.local/bin/speech2text
$HOME/.local/bin/speech2text

cp -r $HOME/setup/scripts/formatDisk.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/formatDisk.sh

cp -r $HOME/setup/scripts/rename.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/rename.sh

install "xorg-xdpyinfo xdotool xorg-xprop xorg-xwininfo" "pac"
cp -r $HOME/setup/scripts/dm-record.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/dm-record.sh

cp -r $HOME/setup/scripts/dm-bluetooth $HOME/.local/bin/
chmod +x $HOME/.local/bin/dm-bluetooth

cp -r $HOME/setup/scripts/sgrec.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/sgrec.sh

cp -r $HOME/setup/scripts/windowshot.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/windowshot.sh

cp -r $HOME/setup/scripts/opa.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/opa.sh

cp -r $HOME/setup/scripts/send.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/send.sh

cp -r $HOME/setup/scripts/prev.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/prev.sh

cp -r $HOME/setup/scripts/gtfu.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/gtfu.sh

cp -r $HOME/setup/scripts/lowbat.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/lowbat.sh

cp -r $HOME/setup/scripts/klp $HOME/.local/bin/
chmod +x $HOME/.local/bin/klp

cp -r $HOME/setup/scripts/kdeconnect $HOME/.local/bin/
chmod +x $HOME/.local/bin/kdeconnect

yes | pip uninstall pathlib
pip install pyinstaller
pip install ffmpeg-python typing-extensions
sudo pacman -S --noconfirm gifsicle
git clone https://github.com/winstxnhdw/ezgif-essentials
cd ezgif-essentials
pyinstaller --onefile main.py
cd dist
mv ./main $HOME/.local/bin/ezgif
cd ../..
rm -rf ezgif-essentials
pip install pathlib
yes | pip uninstall pyinstaller
cp -r $HOME/setup/scripts/edit.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/edit.sh

install "ani-cli-git" "yay"
install "lobster-git" "yay"

pip install poetry
git clone https://github.com/mov-cli/mov-cli
cd mov-cli
cp -r $HOME/setup/scripts/scraper.py ./mov_cli/utils/
pip install -r requirements.txt
poetry build
pip install dist/*.tar.gz
cd ..
rm -rf mov-cli

git clone https://github.com/thameera/vimv
cd vimv
cp -r vimv $HOME/.local/bin/
cd ..
rm -rf vimv

cp -r $HOME/setup/scripts/dex.py $HOME/.local/bin/
chmod +x $HOME/.local/bin/dex.py

wget https://git.io/translate -O trans
chmod +x ./trans
mv ./trans $HOME/.local/bin/
cp -r $HOME/setup/scripts/tran.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/tran.sh

cp -r $HOME/setup/scripts/fixWords.py $HOME/.local/bin/
chmod +x $HOME/.local/bin/fixWords.py

cp -r $HOME/setup/scripts/blank.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/blank.sh

cp -r $HOME/setup/scripts/mp $HOME/.local/bin/
chmod +x $HOME/.local/bin/mp

cp -r $HOME/setup/scripts/batchmover $HOME/.local/bin/
chmod +x $HOME/.local/bin/batchmover

# ADDITIONAL PROGRAMS

install "atbswp" "yay"
install "tk python-wxpython" "pac"
pip install pyautogui pynput

# SETUP DOCKER

install "docker docker-compose" "pac"
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
pip install neovim black flake8
npm i -g neovim typescript typescript-language-server pyright vscode-langservers-extracted ls_emmet @fsouza/prettierd eslint_d diagnostic-languageserver bash-language-server browser-sync
pip uninstall -y cmake
end
install "cmake ninja tree-sitter xclip shfmt" "pac"
git clone https://github.com/neovim/neovim --depth 1
cd neovim
sudo make CMAKE_BUILD_TYPE=Release install || install "neovim" "pac"
cd ..
sudo rm -rf neovim

# MAKE NEOVIM HANDLE FILES IN PLAIN TEXT

xdg-mime default nvim.desktop text/plain


# COPY NEOVIM SETTINGS

cp -r $HOME/setup/configs/nvim $HOME/.config
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
" >>$HOME/.gitconfig
