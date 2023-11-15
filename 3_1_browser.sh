#!/bin/bash

### Source Helper
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/helper.sh"

### Install
install "brave-bin librewolf-bin" "yay"

### Constants
type=$(echo "brave")
typeFolder=$(echo "Brave-Browser")
secProfileName=$(echo "Tmp")

######## Brave ########

sudo rm -rf /etc/brave/
rm -rf $HOME/.config/BraveSoftware/

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

### Copy Bookmarks
cp -r $HOME/setup/configs/brave/Bookmarks "$HOME/.config/BraveSoftware/$typeFolder/Default/"
cp -r $HOME/setup/configs/brave/Bookmarks "$HOME/.config/BraveSoftware/$typeFolder/$secProfileName"

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
echo "user_pref('privacy.clearOnShutdown.cache', false);" >>user.js
echo "user_pref('privacy.clearOnShutdown.downloads', false);" >>user.js
echo "user_pref('privacy.clearOnShutdown.formdata', false);" >>user.js
echo "user_pref('privacy.clearOnShutdown.history', false);" >>user.js
echo "user_pref('privacy.clearOnShutdown.sessions', false);" >>user.js
echo "user_pref('privacy.clearOnShutdown.cookies', false);" >>user.js
echo "user_pref('privacy.clearOnShutdown.offlineApps', false);" >>user.js
echo "user_pref('browser.startup.homepage', '$homeURL');" >>user.js
echo "user_pref('browser.startup.page', 1);" >>user.js
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

###### Arkenfox Profile 2 ######

# Create profile
librewolf -CreateProfile "$secProfileName"

# Get Default-release Location
findLocation=$(find ~/.librewolf/ | grep -E "$secProfileName" | head -1)

# Go to second profile
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

# Restore Bookmarks [Librewolf]
getReq=$(cat /usr/lib/librewolf/distribution/policies.json | grep -n '"NoDefaultBookmarks": true,' | head -1 | xargs)
getLineNumber=$(echo "$getReq" | cut -d":" -f1)
rep=$(echo '"NoDefaultBookmarks": true,
"Bookmarks": [
        {
            "Title": "h2oGPT",
            "URL": "https://gpt.h2o.ai/",
            "Placement": "toolbar"
        },
        {
            "Title": "Sheet",
            "URL": "https://takeuforward.org/strivers-a2z-dsa-course/strivers-a2z-dsa-course-sheet-2/",
            "Placement": "toolbar"
        },
        {
            "Title": "Sheet2",
            "URL": "https://neetcode.io/practice",
            "Favicon": "",
            "Placement": "toolbar"
        }
        ],')

replace_line() {
	local file="$3"
	local line_num="$2"
	local new_line="$1"

	# Check if file exists
	if [[ ! -f "$file" ]]; then
		echo "Error: File '$file' does not exist."
		return 1
	fi

	# Get current line count
	local current_lines=$(sudo wc -l <"$file")

	# Check if line number is within range
	if [[ $line_num -lt 1 || $line_num -gt $current_lines ]]; then
		echo "Error: Line number '$line_num' is out of range."
		return 1
	fi

	# Read file into an array
	local lines=()
	while IFS='' read -r line || [[ -n "$line" ]]; do
		lines+=("$line")
	done <"$file"

	# Replace line at specified index
	lines[${line_num} - 1]="$new_line"

	# Write updated lines back to file
	echo "${lines[@]}" >~/policies.json
	sudo mv ~/policies.json /usr/lib/librewolf/distribution/policies.json
}

replace_line "$rep" "$getLineNumber" "/usr/lib/librewolf/distribution/policies.json"
