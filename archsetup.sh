#!/usr/bin/env bash

# Read Username
USERNAME=$(sed -n '6p' <"$CONFIG_FILE")

# Find the name of the folder the scripts are in
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Run scripts
bash $SCRIPT_DIR/0_startup.sh || exit 0
bash $SCRIPT_DIR/1_pacstrap.sh || exit 0
arch-chroot /mnt /bin/bash -c "./setup/2_after_pacstrap.sh" || exit 0
arch-chroot /mnt /usr/bin/runuser -u $USERNAME -- /home/$USERNAME/setup/3_packages.sh || exit 0
