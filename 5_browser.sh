#!/bin/bash

# Setup
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "${SCRIPT_DIR}/helpers/pkg_installer.sh"
source "${SCRIPT_DIR}/helpers/header.sh"

######## Brave ########

header "Setting up Brave"

sudo rm -rf /etc/brave/
rm -rf "$HOME/.config/BraveSoftware/"
install "brave-bin" "yay"

secondary_profile_name="Tmp"

### Policies
sudo mkdir -p /etc/brave/policies/managed/
sudo tee /etc/brave/policies/managed/brave-policy.json <"$HOME/.dotfiles/configs/brave/policy.json" >/dev/null

### Create Default Profile
sudo -u "$USER" brave --headless=new &
mkdir -p "$HOME/.config/BraveSoftware/Brave-Browser/Default"
sleep 3
pkill -u "$USER" -f "brave --headless" || true
rm -rf "$HOME/.config/BraveSoftware/Brave-Browser/SingletonLock"

### Create Secondary Profile
sudo -u "$USER" brave --headless=new --profile-directory="$secondary_profile_name" &
mkdir -p "$HOME/.config/BraveSoftware/Brave-Browser/$secondary_profile_name"
sleep 3
pkill -u "$USER" -f "brave --headless" || true
rm -rf "$HOME/.config/BraveSoftware/Brave-Browser/SingletonLock"

### Copy Settings
sleep 3
cat "$HOME/.dotfiles/configs/brave/settings.json" >"$HOME/.config/BraveSoftware/Brave-Browser/Default/Preferences"

sleep 3
cat "$HOME/.dotfiles/configs/brave/settings.json" >"$HOME/.config/BraveSoftware/Brave-Browser/$secondary_profile_name/Preferences"

######## Librewolf ########

header "Setting up LibreWolf"

sudo rm -rf /usr/lib/librewolf/
rm -rf "$HOME/.librewolf/"
install "librewolf-bin" "yay"
secondary_profile_name="Tmp"

###### Start Librewolf ######

sudo -u "$USER" librewolf --headless &
sleep 6
pkill -u "$USER" -f "librewolf --headless" || true

### Copy a script to start librewolf without volume auto adjust
mkdir -p "$HOME/.local/bin/"
cp -r "$HOME/.dotfiles/scripts/libw" "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/libw"

### Add Extensions
extensions=(
	"https://addons.mozilla.org/firefox/downloads/latest/port-authority/latest.xpi"
	"https://addons.mozilla.org/firefox/downloads/latest/decentraleyes/latest.xpi"
	"https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi"
	"https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"
)

uninstall_extensions=(
	"google@search.mozilla.org"
	"bing@search.mozilla.org"
	"amazondotcom@search.mozilla.org"
	"ebay@search.mozilla.org"
	"twitter@search.mozilla.org"
)

policies_file="/usr/lib/librewolf/distribution/policies.json"

ext_json=$(printf '%s\n' "${extensions[@]}" | jq -R . | jq -s .)
uninstall_json=$(printf '%s\n' "${uninstall_extensions[@]}" | jq -R . | jq -s .)

merged=$(sudo jq \
	--argjson exts "$ext_json" \
	--argjson uninstalls "$uninstall_json" \
	'.policies.Extensions.Install = ((.policies.Extensions.Install // []) + $exts | unique)
	 | .policies.Extensions.Uninstall = ((.policies.Extensions.Uninstall // []) + $uninstalls | unique)' \
	"$policies_file")

echo "$merged" | sudo tee "$policies_file" >/dev/null

###### Arkenfox Profile ######

# Get Default-release Location
findLocation=$(find "$HOME/.config/librewolf" | grep -E "default-default" | head -1)

(
	cd "$findLocation"

	mkdir -p chrome
	wget -q https://raw.githubusercontent.com/arkenfox/user.js/master/user.js -O user.js

	# Settings
	cat >>user.js <<-'EOF'

		// ****** OVERRIDES ******

		user_pref("keyword.enabled", true);
		user_pref('toolkit.legacyUserProfileCustomizations.stylesheets', true);
		user_pref("general.smoothScroll",                                       true);
		user_pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12);
		user_pref("general.smoothScroll.msdPhysics.enabled",                    true);
		user_pref("general.smoothScroll.msdPhysics.motionBeginSpringConstant",  600);
		user_pref("general.smoothScroll.msdPhysics.regularSpringConstant",      650);
		user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaMS",         25);
		user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaRatio",      2.0);
		user_pref("general.smoothScroll.msdPhysics.slowdownSpringConstant",     250);
		user_pref("general.smoothScroll.currentVelocityWeighting",              1.0);
		user_pref("general.smoothScroll.stopDecelerationWeighting",             1.0);
		user_pref("mousewheel.default.delta_multiplier_y",                      300);
		user_pref("privacy.resistFingerprinting", true); // [FF41+]
		user_pref('privacy.resistFingerprinting.letterboxing', true); // [HIDDEN PREF]
	EOF
)
