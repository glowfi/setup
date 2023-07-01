#!/bin/bash

### Create a partition and Format a drive to ntfs

DISK="$1"
NAME="$2"

usage() {
    cat <<EOF
    -p   | --pname         Provide the partition name
    -l   | --label         Provide the partition label name
    -h   | --help          Prints help

    ## Creating a Microsoft Basic data partition and Format to NTFS
    formatDisk.sh -p "/dev/sda" -l "MyDrive"

EOF
}

while [[ $# > 0 ]]; do
    case "$1" in

        -p | --pname)
            DISK="$2"
            shift
            ;;

        -l | --label)
            NAME="$2"
            shift
            ;;

        --help | *)
            usage
            exit 1
            ;;
    esac
    shift
done

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
    echo "Provide a Disk partition and a Disk Label name!"

fi
