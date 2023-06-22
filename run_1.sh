#!/usr/bin/env bash

set -e

# Find the name of the folder the scripts are in
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Run scripts
bash $SCRIPT_DIR/0_startup.sh || exit 0
bash $SCRIPT_DIR/1_pacstrap.sh || exit 0
arch-chroot /mnt /bin/bash -c "./setup/2_after_pacstrap.sh" || exit 0
