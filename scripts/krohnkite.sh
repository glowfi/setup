#!/bin/fish

# Download Krohnkite

cd
git clone https://github.com/esjeon/krohnkite
sed -i '226 a //@ts-ignore' $HOME/krohnkite/src/driver/kwin/kwindriver.ts
cd krohnkite
make install
mkdir -p $HOME/.local/share/kservices5/
ln -s $HOME/.local/share/kwin/scripts/krohnkite/metadata.desktop $HOME/.local/share/kservices5/krohnkite.desktop
cd ..
rm -rf krohnkite

# Creating Breezerc to hide title bars

touch $HOME/.config/breezerc
kwriteconfig5 --file breezerc --group "Windeco Exception 0" --key BorderSize 0
kwriteconfig5 --file breezerc --group "Windeco Exception 0" --key Enabled false
kwriteconfig5 --file breezerc --group "Windeco Exception 0" --key ExceptionPattern .\*
kwriteconfig5 --file breezerc --group "Windeco Exception 0" --key ExceptionType 0
kwriteconfig5 --file breezerc --group "Windeco Exception 0" --key HideTitleBar true
kwriteconfig5 --file breezerc --group "Windeco Exception 0" --key Mask 16
