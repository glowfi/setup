#!/usr/bin/env bash

# Find the name of the folder the scripts are in
setfont ter-v22b
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
CONFIG_FILE=$SCRIPT_DIR/setup.conf

# Read Username
USERNAME=$(sed -n '6p' <"$CONFIG_FILE")

# Run scripts
bash $SCRIPT_DIR/0_startup.sh
bash $SCRIPT_DIR/1_pacstrap.sh
arch-chroot /mnt -c "/setup/2_after_pacstrap.sh"
arch-chroot /mnt /usr/bin/runuser -u $USERNAME -- /setup/3_packages.sh
