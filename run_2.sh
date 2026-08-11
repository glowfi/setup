#!/bin/bash

# Script Directory
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Source Logo
source "${SCRIPT_DIR}/helpers/logo.sh"

# Get confirmation
clear
logo
echo "Welcome to the post-install script !"
echo "Type p to proceed or e to exit"
read keyPressed

if [[ "${keyPressed}" != "p" ]]; then
	echo "Exited!"
	exit 1
fi

# Cache password
sudo sed -i '71 a Defaults        timestamp_timeout=30000' /etc/sudoers

# Run scripts
bash $SCRIPT_DIR/3_packages.sh || exit 0
fish $SCRIPT_DIR/4_development.fish || exit 0
bash $SCRIPT_DIR/5_browser.sh || exit 0
bash $SCRIPT_DIR/6_kde.sh || exit 0
bash $SCRIPT_DIR/7_perf_optimization_hardening.sh || exit 0

# Remove Cached passowrd
sudo sed -i '72d' /etc/sudoers
