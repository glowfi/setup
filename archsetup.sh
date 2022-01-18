#!/usr/bin/env bash

# Find the name of the folder the scripts are in
setfont ter-v22b
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Run scripts
bash $SCRIPT_DIR/0_startup.sh
bash $SCRIPT_DIR/1_pacstrap.sh
arch-chroot /mnt "chmod +x setup/2_after_pacstrap.sh;/setup/2_after_pacstrap.sh"
# arch-chroot /mnt /usr/bin/runuser -u $USERNAME -- /home/$USERNAME/ArchTitus/2-user.sh
# arch-chroot /mnt /root/ArchTitus/3-post-setup.sh
