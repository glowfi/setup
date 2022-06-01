#!/bin/bash

### Create a partition and Format a drive to ntfs

DISK="$1"
NAME="$2"

if [[ "$DISK" && "$NAME" ]]; then

	sudo sgdisk -Z ${DISK}
	sudo sgdisk -a 2048 -o ${DISK}

	(
		echo n
		echo
		echo
		echo
		echo 0700
		echo w
		echo Y
	) | sudo gdisk ${DISK}

	sudo mkntfs -Q -v -F -L "${NAME}" "${DISK}1"

else
	echo "Provide the Disk partition and a Disk Label name!"

fi
