# main

This role installs other software available in the main repositories that we
want to install.

## attached storage

If necessary, unmount first

sudo umount /dev/sdc1

Partition the disk

sudo fdisk /dev/sdc

Create a new partition table: `g`
Create a new partition: `n`, accept all defaults (partition number 1, first sector, last sector [consume the entire disk]
Default filesystem type "Linux filesystem" is ok
Enter expert mode with `x`
Change a partition name: `n` and give it a name that we'll reference in vars.yaml
Return to the main menu: `r`
Print the partition table: `p` to inspect everything is OK
Write the new partition table and exit: `w`

Encrypt the disk:
sudo cryptsetup --type luks2 --ciper xchacha20,aes-adiantum-plain64 --hash sha256 --iter-time 5000 --key-size 256 --pbkdf argon2id luksFormat /dev/sdc1

Open the luks container:
sudo cryptsetup luksOpen /dev/sdc1 tmpusb

Create a new filesystem:
sudo mkfs.ext4 -v /dev/mapper/tmpusb

Done, close the luks container
sudo cryptsetup luksClose tmpusb
