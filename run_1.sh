#!/usr/bin/env bash
set -euo pipefail

# Setup
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "${SCRIPT_DIR}/helpers/config_loader.sh"

# Run scripts
bash $SCRIPT_DIR/0_configure.sh || exit 0
bash $SCRIPT_DIR/1_pacstrap.sh || exit 0

load_config "${SCRIPT_DIR}/setup.conf"
require_config DISTRO_TYPE

# Chroot
if [[ "$DISTRO_TYPE" = "artix" ]]; then
	cp -r "$SCRIPT_DIR" /mnt/
	artix-chroot /mnt /bin/bash -c "./setup/2_after_pacstrap.sh" || exit 0
else
	cp -r "$SCRIPT_DIR" /mnt/
	arch-chroot /mnt /bin/bash -c "./setup/2_after_pacstrap.sh" || exit 0
fi
