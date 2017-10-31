#!/bin/bash

lsblk
read -p "Which disk to install? "
INSTALL_DISK="$REPLY"

# https://superuser.com/a/984637
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | gdisk $INSTALL_DISK
  o # create a new, empty GPT partition table with protected MBR
  Y # confirm above
  n # create new partition (efi boot partition)
    # default (partition number 1)
    # default (start at beginning of disk)
  512M # 512M efi boot partition
  ef00 # (EFI system type)
  n # create new partition (luks container)
    # default (partition number 2)
    # default (start immediately after preceding partition)
    # default (extend partition to end of disk)
  8e00 # (Linux LVM)
  p # print the in-memory partition table
  w # write the partition table
  Y # confirm and we're done
EOF

# let's check one more time that the disks are partitioned as expected
gdisk -l $INSTALL_DISK
