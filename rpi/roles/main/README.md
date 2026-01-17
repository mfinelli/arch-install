# main

This role installs other software available in the main repositories that we
want to install.

## networking

Replaces the `netplan`/`NetworkManager` configuration in favor of a
`systemd-networkd` setup. See https://manski.net/articles/linux/network-config
for more information and rationale as well as the script found here:
https://github.com/skrysm/systemd-networkd-init which inspired some of the
tasks in `network.yml`.

### details

Like in the Debian configuration we run this setup one-time only -- that is on
the first run of this script we pull the Wi-Fi credentials out of the netplan
configuration that Raspberry Pi OS writes and then reconfigure Wi-Fi to use
`iwd`. On subsequent runs we skip these steps.

## attached storage

This role also writes out entries into the `fstab` and `crypttab` for any
attached storage (For now we're assuming that all attached storage is a
LUKS-encrypted, single partition device, with an `ext4` filesystem inside).

This role only changes the `fstab` and `crypttab` for the attached storage
devices if both the device is attached and the keyfile for it exists. If
ansible runs while either of those two criteria are not true then the entry
will be _removed_ from the `*tab` files even if it was previously present.
This also means that it is safe to run ansible with this role and the usual
storage configured even if the devices are not present (e.g., during initial
provisioning of the Pi itself).

### preparing the device

In the following steps we assume the new device is located at `/dev/sdc` while
we prepare it.

1. Unmount the device if necessary (if it was auto-mounted when attached)

   ```shell
   sudo umount /dev/sdc1
   ```

2. Partition the disk using `fdisk`

   ```shell
   sudo fdisk -n /dev/sdc
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

### before running ansible again

Once the device has been attached before running ansible again to add the
correct entries to the `fstab` and `crypttab` it's necessary to generate a new
keyfile for the device.

1. If necessary, update the current passphrase (if you used a simple one
   during the preparation step above)

   ```shell
   sudo cryptsetup luksChangeKey /dev/disk/by-partlabel/[LABEL]
   ```

2. Create the new keyfile

   ```shell
   sudo dd if=/dev/random of=/root/[KEYFILE] bs=1024 count=4
   sudo chmod 0400 /root/[KEYFILE]
   ```

3. Add the keyfile to the LUKS header

   ```shell
   sudo cryptsetup luksAddKey /dev/disk/by-partlabel/[LABEL] /root/[KEYFILE]
   ```

Now you can run ansible again to update the `fstab` and `crypttab` as
necessary.

#### mount point ownership

If you've set a custom owner/group for the mount point then you'll need to run
ansible again to set them correctly after ensuring that the requested user and
group actually exist -- otherwise root will own the mount point.
