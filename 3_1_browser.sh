#!/bin/bash

### Source Helper
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/helper.sh"

### Install
install "brave-bin librewolf-bin" "yay"

######## Brave ########

sudo rm -rf /etc/brave/
rm -rf $HOME/.config/BraveSoftware/

### Policies
sudo mkdir -p /etc/brave/policies/managed/
sudo touch /etc/brave/policies/managed/brave-policy.json
cat $HOME/setup/configs/brave/policy.json | sudo tee -a /etc/brave/policies/managed/brave-policy.json >/dev/null

### Create Default Profile

sudo -u "$USER" brave --headless=new &
sleep 3
pkill -u "$USER" brave
rm -rf $HOME/.config/BraveSoftware/Brave-Browser/SingletonLock

### Create Secondary Profile
sudo -u "$USER" brave --headless=new --profile-directory=Tmp &
sleep 3
pkill -u "$USER" brave
rm -rf $HOME/.config/BraveSoftware/Brave-Browser/SingletonLock

### Copy Settings
sleep 3
cat $HOME/setup/configs/brave/settings.json >$HOME/.config/BraveSoftware/Brave-Browser/Default/Preferences
sleep 3
cat $HOME/setup/configs/brave/settings.json >"$HOME/.config/BraveSoftware/Brave-Browser/Tmp/Preferences"

######## Librewolf ########

rm -rf $HOME/.librewolf/

###### Start Librewolf ######

sudo -u "$USER" librewolf --headless &
sleep 6
pkill -u "$USER" librewolf

### Copy a script to start librewolf without volume auto adjust
mkdir -p $HOME/.local/bin/
cp -r $HOME/setup/scripts/system/libw $HOME/.local/bin/
chmod +x $HOME/.local/bin/libw

### Add Extensions

extensions=("https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi" "https://addons.mozilla.org/firefox/downloads/latest/decentraleyes/latest.xpi" "https://addons.mozilla.org/firefox/downloads/latest/libredirect/latest.xpi")

for i in "${extensions[@]}"; do
	c=$(cat /usr/lib/librewolf/distribution/policies.json | grep -n "Install" | head -1 | awk -F":" '{print $1}' | xargs)
	sudo sed -i "${c} a \"${i}\"," /usr/lib/librewolf/distribution/policies.json
done

###### Arkenfox Profile ######

# Get Default-release Location
findLocation=$(find ~/.librewolf/ | grep -E "default-default" | head -1)

# Go to default-release profile
cd "$findLocation"

# User CSS
mkdir chrome
cd chrome
cd ..

# Get Arkenfox user.js
wget https://raw.githubusercontent.com/arkenfox/user.js/master/user.js -O user.js

# Settings
echo -e "\n" >>user.js
echo "// ****** OVERRIDES ******" >>user.js
echo "" >>user.js
echo 'user_pref("keyword.enabled", true);' >>user.js
echo "user_pref('toolkit.legacyUserProfileCustomizations.stylesheets', true);" >>user.js
echo 'user_pref("general.smoothScroll",                                       true);' >>user.js
echo 'user_pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12);' >>user.js
echo 'user_pref("general.smoothScroll.msdPhysics.enabled",                    true);' >>user.js
echo 'user_pref("general.smoothScroll.msdPhysics.motionBeginSpringConstant",  600);' >>user.js
echo 'user_pref("general.smoothScroll.msdPhysics.regularSpringConstant",      650);' >>user.js
echo 'user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaMS",         25);' >>user.js
echo 'user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaRatio",      2.0);' >>user.js
echo 'user_pref("general.smoothScroll.msdPhysics.slowdownSpringConstant",     250);' >>user.js
echo 'user_pref("general.smoothScroll.currentVelocityWeighting",              1.0);' >>user.js
echo 'user_pref("general.smoothScroll.stopDecelerationWeighting",             1.0);' >>user.js
echo 'user_pref("mousewheel.default.delta_multiplier_y",                      300);' >>user.js

cd

### Download Libredirect

cd $HOME/Downloads
wget "https://0x0.st/HVZQ.0.json" -O "libredirect-settings.json"
ver=$(echo "2.8.0")
wget "https://github.com/libredirect/browser_extension/releases/download/v$ver/libredirect-$ver.crx"
cd
