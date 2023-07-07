#!/usr/bin/env bash

######## Brave ########

sudo rm -rf /etc/brave/
rm -rf $HOME/.config/BraveSoftware/

### Policies
sudo mkdir -p /etc/brave/policies/managed/
sudo touch /etc/brave/policies/managed/brace.json
cat $HOME/setup/configs/brave/policy.json | sudo tee -a /etc/brave/policies/managed/brace.json >/dev/null


### Start Brave

brave &
sleep 6
killall brave


### Settings (Default Profile)
brave --profile-directory=Tmp &
sleep 3
killall brave
sleep 6
cat $HOME/setup/configs/brave/settings.json > $HOME/.config/BraveSoftware/Brave-Browser/Default/Preferences
sleep 6
cat $HOME/setup/configs/brave/settings.json > "$HOME/.config/BraveSoftware/Brave-Browser/Tmp/Preferences"



######## Firefox ########

rm -rf $HOME/.mozilla
sudo rm -rf /usr/lib/firefox/distribution

### Policies

sudo mkdir -p /usr/lib/firefox/distribution/
sudo touch /usr/lib/firefox/distribution/policies.json
echo '
{
	"policies": {
		"CaptivePortal": false,
		"DisableFirefoxAccounts": true,
		"DisableFirefoxStudies": true,
		"DisablePocket": true,
		"DisableTelemetry": true,
		"Extensions": {
			"Install": [
				"https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi",
				"https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi"
				]
		},
            "FirefoxHome": {
			"Search": true,
			"TopSites": false,
			"SponsoredTopSites": false,
			"Highlights": false,
			"Pocket": false,
			"SponsoredPocket": false,
			"Snippets": false,
			"Locked": false
		},
		"NetworkPrediction": false,
		"OverrideFirstRunPage": "about:home",
		"UserMessaging": {
			"WhatsNew": false,
			"ExtensionRecommendations": false,
			"FeatureRecommendations": false,
			"SkipOnboarding": false
		},
		"NoDefaultBookmarks":true
	}
}'| sudo tee -a /usr/lib/firefox/distribution/policies.json >/dev/null

###### Start Firefox ######

firefox &
sleep 6
killall firefox

###### Arkenfox Profile ######

# Get Default-release Location
findLocation=$(find ~/.mozilla/firefox/ | grep -E "default-release" | head -1)

# Go to default-release profile
cd "$findLocation"

# User CSS
mkdir chrome
cd chrome
cd ..

# Get Arkenfox user.js
wget https://raw.githubusercontent.com/arkenfox/user.js/master/user.js -O user.js

# Settings
echo -e "\n" >> user.js
echo "// ****** OVERRIDES ******" >> user.js
echo "" >> user.js
echo 'user_pref("keyword.enabled", true);' >> user.js
echo "user_pref('toolkit.legacyUserProfileCustomizations.stylesheets', true);" >> user.js
echo 'user_pref("general.smoothScroll",                                       true);'>> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12);'  >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.enabled",                    true);'>> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.motionBeginSpringConstant",  600);' >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.regularSpringConstant",      650);' >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaMS",         25);'  >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaRatio",      2.0);' >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.slowdownSpringConstant",     250);' >> user.js
echo 'user_pref("general.smoothScroll.currentVelocityWeighting",              1.0);' >> user.js
echo 'user_pref("general.smoothScroll.stopDecelerationWeighting",             1.0);' >> user.js
echo 'user_pref("mousewheel.default.delta_multiplier_y",                      300);' >> user.js

cd
