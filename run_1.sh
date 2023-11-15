#!/usr/bin/env bash

set -e

# Find the name of the folder the scripts are in
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
CONFIG_FILE=$SCRIPT_DIR/setup.conf

# Run scripts
bash $SCRIPT_DIR/0_startup.sh || exit 0
bash $SCRIPT_DIR/1_pacstrap.sh || exit 0

# Chroot
_distroType=$(sed '$!d' "$CONFIG_FILE")
if [[ "$_distroType" = "artix" ]]; then
	artix-chroot /mnt /bin/bash -c "./setup/2_after_pacstrap.sh" || exit 0
else
	arch-chroot /mnt /bin/bash -c "./setup/2_after_pacstrap.sh" || exit 0
fi
