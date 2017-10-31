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

# encrypt the main partition: AES256 (e.g. /dev/sda2)
cryptsetup --cipher aes-xts-plain64 --key-size 512 --hash sha512 \
  --iter-time 5000 --use-random --verify-passphrase luksFormat ${INSTALL_DISK}2

# get some much needed info
read -p "How many swap G? "
SWAPG="$REPLY"
read -p "How many root G? "
ROOTG="$REPLY"

# do the LVM boogie
cryptsetup luksOpen /dev/sda2 lvm
pvcreate /dev/mapper/lvm
vgcreate crypt /dev/mapper/lvm
lvcreate -L ${SWAPG}G crypt -n swap
lvcreate -L ${ROOTG}G crypt -n root
lvcreate -l 100%FREE crypt -n home

# make some filesystems
mkfs.vfat -F32 ${INSTALL_DISK}1
mkfs.btrfs /dev/mapper/crypt-root
mkfs.btrfs /dev/mapper/crypt-home
mkswap /dev/mapper/crypt-swap

# get everything ready
swapon /dev/crypt/swap
mount -o compress=lzo /dev/crypt/root /mnt
mkdir /mnt/{boot,home}
mount ${INSTALL_DISK}1 /mnt/boot
mount  -o compress=lzo /dev/crypt/home /mnt/home

# do the needful
pacstrap -i /mnt base base-devel
