# main

This role installs other software available in the main repositories that we
want to install.

## attached storage

This role also writes out entries into the `fstab` and `crypttab` for any
attached storage (For now we're assuming that all attached storage is a
LUKS-encrypted, single partition device, with an `ext4` filesystem inside).

### preparing the device

In the following steps we assume the new device is located at `/dev/sdc` while
we prepare it.

1. Unmount the device if necessary (if it was auto-mounted when attached)

   ```shell
   sudo umount /dev/sdc1
   ```

2. Partition the disk using `fdisk`

   ```shell
   sudo fdisk /dev/sdc
   ```

   - Create a new partition table: `g`
   - Create a new partition: `n`; accept all of the defaults (partition number
     1, first sector, and last sector) to let a single partition consume the
     entire disk
   - The default filesystem type "Linux filesystem" is okay
   - Enter "expert mode": `x`
   - Change the partition name `n`; this corresponds to the `label` key in
     the `main_attached_storage` variable
   - Return to the main menu: `r`
   - Print the partition table: `p`; inspect that everything looks good
   - Write the new partition table and exit: `w`

3. Encrypt the disk

   ```shell
   sudo cryptsetup --type luks2 --ciper xchacha20,aes-adiantum-plain64 \
     --hash sha256 --iter-time 5000 --key-size 256 --pbkdf argon2id \
     luksFormat /dev/sdc1
   ```

4. Open the new LUKS container

   ```shell
   sudo cryptsetup luksOpen /dev/sdc1 tmpusb
   ```

5. Create the new filesystem

   ```shell
   sudo mkfs.ext4 -v /dev/mapper/tmpusb
   ```

6. Done, close the container and then attach it to the main Pi (if preparation
   was done on a different computer)

   ```shell
   sudo cryptsetup luksClose tmpusb
   ```
