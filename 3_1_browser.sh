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

### Download Libredirect

cd $HOME/Downloads
wget "https://0x0.st/H9lR.1.json" -O "libredirect-settings.json"
ver=$(echo "2.7.1")
wget "https://github.com/libredirect/browser_extension/releases/download/v$ver/libredirect-$ver.crx"
cd
# https://paulgo.io/preferences?preferences=eJx1V0mv4zYM_jXNxZigG1D0kFOBXltgpmeDlhibY0n0aInj9-tLeYnl5_cOMSJSFPePkoKILXvCcGvRoQdzMeDaBC3e0H357-vFsAKTFxdIkRXbwWDEW8vcGryQlZ314Pk53b75hBeLsWN9-_efr98uAe4YELzqbj9fYocWb4Gy_MVjSCaGml3tcKwjNIu0ZqqFx-aB_sYgyyv79rJI1SFOYokG318Uuoi-BkOts_J_EQf9AKdQ16vWv8EEvPxI6KeaXB0pivxCJHcnR1EOVZ6NWdVTgMaIPLqWnMTkzxbaug6sCExlURP89Otf4ByEKiugB9b1nQyGTB76ypL37Eua2F3JtwqRfbnZgWKnoa4p5qWPpOR_jmZmNxSbpHqMK7-Jmtp2F1dKfYmPun6QRs4EHtBJzAIWh4hjIXi8iwOKUOKy0Eb9IIl5veZbiBMO5VIlbwhLikZ8k2jXNgVS8_pB4KJYXajTuq00zlEldqGUR9FKuq5ZisDLeqSeNEQ46BB_86_lj6nVoqhUuPNGhHz0rmEJvIVBBOSbbbD8nYacwn1XlCRPB09_eRYK7oZU70uCR6wC3-MIHitNHpWkdVqTdPfkeoIyj3IwpbAHTtaRed3fSjlCsy4Ua2zQtxtvbq9qyW-R55U-GJhyWYW9JEqOZUnxQWxgrcsMdtB4yJ9VH1nd7HEhB4UwOflLnMLHtO3I7xQ63s_oJXYQCgMNiUo_VTnYgT5g8L2Snmil_8ssG3Lt41AphpsQ8erD1jxvZvKkClMEhEAN4NYNdrSNKU9wg11ZbgLYLcldBJLVITWSeljreO-ezBcuF8YPIG62FLZOFdGrtMe6-jFKm5SaZ0IlmCdH5O-LdKruhXwqgAXZcrVU-fMqPbCQ47gRAloRJ1UF1bEBX3oRcuMOGbcLwyL3E0eWFPY5bpt7MVsjZ0A6bC6oqxdxpJgR-T1YJhekJENXeDZBx4cmnwnHoDzIIhduj9RMpYiMpCc47elQGRlXGuY-vCf-SBzxPTEMqOY2-YS8RyyTM7pSnN7vfvD0LpIjmyUdQ3cEOFLxjd0Rbn777Y_nHm2dNLq9hQK-ObDlfsEwxP5QyvDIUd8JPjVTi3ZrjgHRx9RgEcs5NaKiz3NgxKZg-SSdUu4d-Uk9OynpKkyO3WSxtA97f8zbQjoV80I-F_P34TqM7jgYrEyQ0iEBhweeCNeTjoV80rGQD0ZKo-zoETh5hV2KO_KWyoa-vba8tfRF8OFwQcjNWAlEpWeVbX-N8yc9ygJqpFYV2GGHqLx7nUaFZ4J179fnYM7Ug0Mz5eS5zHEv-g8lq1luFb7q0jZ3ME6WnXhQ5PWuPedx_RotFHeBZc6UZ66T52TnSj9YutI-QKVuPXdWYtDaSQDO2pSvE3M3HnFl2ZEC-s94AtPxM14-WUbxmf32ZZ1Gu_eWnspw0sV4AZnzuI3ObWjkC03AeBoYIcqtIcolZLuJDDq3475p6AR43Yuby6LI4ry-zqp3CwbycnFvoDBTBo_NgsW507AVpFinKZ68DTgQLBOl7EpOUq1Hl2VmqJ4Fau6Gx63KQ5-a5GLaOikN6HNGXp1lSMv9yC-R3gydOL0DpBfldb8EMlKWef4eZkBPh2Ka0Xpu33eonAXnHG4VbQW3rNzUqujBBSOxK2-j7LWjviDE6K9UwFITf98u3_sbYTBJMCDccvye13V17aTqBLRRnjEy95Z5e9jAUC-vnNHL8-PElnjVqkPVnzgyEmuplB6n8IKhT2zI83ZZnE4xgq9xRe-SvlaBBFwtT8JJHlFG7rcf7DR3eU3d-Wy7h4wutbwfxD-by-Ui9wppgdv_NrBwEw==&save=1

######## Librewolf ########

rm -rf $HOME/.librewolf/

###### Start Librewolf ######

sudo -u "$USER" librewolf --headless &
sleep 6
pkill -u "$USER" librewolf

### Copy a script to start librewolf without volume auto adjust
mkdir -p $HOME/.local/bin/
cp -r $HOME/setup/scripts/libw $HOME/.local/bin/
chmod +x $HOME/.local/bin/libw

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
