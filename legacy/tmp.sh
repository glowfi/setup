#!/bin/bash

echo "set PATH ~/Downloads/jdk-17.0.3+7/bin/ \$PATH" >>~/.config/fish/config.fish
echo "set CATALINA_HOME ~/Downloads/jdk-17.0.3+7/bin/ \$CATALINA_HOME" >>~/.config/fish/config.fish
echo "alias jk='javac \$argv;java \$argv'" >>~/.config/fish/config.fish

sed -i '213i 	elseif filetype == "java" then' ~/.config/nvim/lua/core/statusline.lua
sed -i '214i 		a = "LS:jdtls " .. a' ~/.config/nvim/lua/core/statusline.lua
sed -i '233i 	elseif filetype == "c" or filetype == "cpp" or filetype == "java" then' ~/.config/nvim/lua/core/statusline.lua

sed -i '274i     use({ "mfussenegger/nvim-jdtls" })' ~/.config/nvim/lua/plugins.lua

cp -r ~/setup/legacy/ftplugin ~/.config/nvim
