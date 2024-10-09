#!/usr/bin/env bash

### Source Helper
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/helper.sh"

######## Brave ########

sudo rm -rf /etc/brave/
rm -rf $HOME/.config/BraveSoftware/
install "brave-bin" "yay"
# yay -S --noconfirm brave-bin
type=$(echo "brave")
typeFolder=$(echo "Brave-Browser")
secProfileName=$(echo "Tmp")

### Policies
sudo mkdir -p /etc/brave/policies/managed/
sudo touch /etc/brave/policies/managed/brave-policy.json
cat $HOME/setup/configs/brave/policy.json | sudo tee -a /etc/brave/policies/managed/brave-policy.json >/dev/null

### Create Default Profile

sudo -u "$USER" "$type" --headless=new &
mkdir -p "/home/$USER/.config/BraveSoftware/$typeFolder/Default"
sleep 3
pkill -u "$USER" "$type"
rm -rf "$HOME/.config/BraveSoftware/$typeFolder/SingletonLock"

### Create Secondary Profile
sudo -u "$USER" "$type" --headless=new --profile-directory="$secProfileName" &
mkdir -p "/home/$USER/.config/BraveSoftware/$typeFolder/$secProfileName"
sleep 3
pkill -u "$USER" "$type"
rm -rf "$HOME/.config/BraveSoftware/$typeFolder/SingletonLock"

### Copy Settings
sleep 3
touch "$HOME/.config/BraveSoftware/$typeFolder/Default/Preferences"
cat $HOME/setup/configs/brave/settings.json >"$HOME/.config/BraveSoftware/$typeFolder/Default/Preferences"

sleep 3
touch "$HOME/.config/BraveSoftware/$typeFolder/$secProfileName/Preferences"
cat $HOME/setup/configs/brave/settings.json >"$HOME/.config/BraveSoftware/$typeFolder/$secProfileName/Preferences"

######## Librewolf ########

sudo rm -rf /usr/lib/librewolf/
rm -rf $HOME/.librewolf/
install "librewolf-bin" "yay"
# yay -S --noconfirm librewolf-bin
secProfileName=$(echo "Tmp")

###### Start Librewolf ######

sudo -u "$USER" librewolf --headless &
sleep 6
pkill -u "$USER" librewolf

### Copy a script to start librewolf without volume auto adjust
mkdir -p $HOME/.local/bin/
cp -r $HOME/setup/scripts/system/libw $HOME/.local/bin/
chmod +x $HOME/.local/bin/libw

### Add Extensions

extensions=("https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi" "https://addons.mozilla.org/firefox/downloads/latest/decentraleyes/latest.xpi")

for i in "${extensions[@]}"; do
	c=$(cat /usr/lib/librewolf/distribution/policies.json | grep -n "Install" | head -1 | awk -F":" '{print $1}' | xargs)
	sudo sed -i "${c} a \"${i}\"," /usr/lib/librewolf/distribution/policies.json
done

###### Arkenfox Profile 1 [clear hist on exit] ######

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
echo 'user_pref("privacy.resistFingerprinting", true); // [FF41+]' >>user.js
echo "user_pref('privacy.resistFingerprinting.letterboxing', true); // [HIDDEN PREF]" >>user.js

cd
