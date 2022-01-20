# fde

Enables full-disk encryption.

## guides

- https://robpol86.com/raspberry_pi_luks.html
- https://rr-developer.github.io/LUKS-on-Raspberry-Pi/
- https://blog.fidelramos.net/software/unlock-luks-usb-drive

## steps

1. Run the initial setup via ansible:

   ```shell
   bash -c "$(curl -LfSs https://mfgo.link/rpi-fde)"
   ```

2. Reboot, wait for boot failure and the initramfs shell

3. Ensure that the proper cryptsetup modules have been loaded:

   ```shell
   cryptsetup benchmark -c xchacha20,aes-adiantum-plain64
   ```

4. Check the main root filesystem and then shrink it for copy:

   ```shell
   e2fsck -f /dev/mmcblk0p2
   resize2fs -fM -p /dev/mmcblk0p2
   ```

   Take note of the number of blocks displayed in the output (`XXXXX`):

   ```
   Resizing the filesystem on /dev/mmcblk0p2 to XXXXX (4k) blocks.
   ```

   Finally, note a checksum of the reduced filesystem for sanity check at each
   step:

   ```shell
   time dd bs=4k count=XXXXX if=/dev/mmcblk0p2 | sha1sum
   ```

5. Insert the temporary USB drive and check it's device (probably `/dev/sda`):

   ```shell
   fdisk -l /dev/sda
   ```

6. Copy the old filesystem to the USB device (overwriting any existing data)
   and then ensure the previously computed checksum matches:

   ```shell
   time dd bs=4k count=XXXXX if=/dev/mmcblk0p2 of=/dev/sda
   time dd bs=4k count=XXXXX if=/dev/sda | sha1sum
   ```

7. Encrypt and then open the root filesystem

   ```shell
   cryptsetup --type luks2 --cipher xchacha20,aes-adiantum-plain64 \
     --hash sha256 --iter-time 5000 --key-size 256 --pbkdf argon2i \
     luksFormat /dev/mmcblk0p2
   ```

   ```shell
   cryptsetup luksOpen /dev/mmcblk0p2 crypt
   ```

8. Copy back the saved filesystem and verify its checksum:

   ```shell
   time dd bs=4k count=XXXXX if=/dev/sda of=/dev/mapper/crypt
   time dd bs=4k count=XXXXX if=/dev/mapper/crypt | sha1sum
   ```

9. Run a filesystem check and then expand the filesystem:

   ```shell
   e2fsck -f /dev/mapper/crypt
   resize2fs -f /dev/mapper/crypt
   ```

10. Remove the USB drive and then reboot

11. After the reboot from the initramfs shell mount the luks volume to
    continue booting

    ```shell
    cryptsetup luksOpen /dev/mmcblk0p2 crypt
    exit
    ```

12. Rebuild the initramfs one more time for the password prompt to appear at
    boot time:

    ```shell
    sudo CRYPTSETUP=y mkinitramfs -o /tmp/initramfs.gz
    sudo cp /tmp/initramfs.gz /boot/initramfs.gz
    ```

13. Reboot and continue with the rest of the installation.

## keyfiles

If you want to setup the device to boot with a keyfile via USB key on boot
you can additionally follow these instructions.

1. If you're going to reuse the USB drive that you used to temporarily store
   the root filesystem during encryption you'll need to reformat it. It can
   easily be done with `gparted`, by selecting the device (probably `/dev/sda`),
   formatting it as "cleared", creating a new partition table (Device -> Create
   Partition Table -> `msdos` type), and then creating a new `fat32` partition.
   Give the filesystem a label (e.g., `CRYPTKEY`) so that we can use it in the
   `crypttab` later.

   You may also want to wipe the data from the drive before using it, which
   can be accomplished like so:

   1. First note the optimal sector size and the total number of sectors
      (assuming `/dev/sda`):

      ```shell
      sudo fdisk -l /dev/sda
      ```

   2. Wipe the disk using a simple `dd` command using the data from above
      (e.g., sector size 512 bytes and 30629376 sectors):

      ```shell
      sudo dd bs=512 count=30629376 if=/dev/urandom of=/dev/sda status=progress
      ```

2. Ensure that the drive is plugged in and mounted.

3. Create the keyfile, we initially create it in `/root` so that we have a
   backup in case we need to create a new USB drive we can just use the normal
   luks password to decrypt and then copy the keyfile to a new device.

   ```shell
   sudo dd if=/dev/random of=/root/cryptkey bs=1024 count=4
   sudo chmod 0400 /root/cryptkey
   sudo cp /root/cryptkey /media/pi/CRYPTKEY/key
   ```

4. Add the new keyfile to the luks header:

   ```shell
   sudo cryptsetup luksAddKey /dev/mmcblk0p2 /root/cryptkey
   ```

5. Re-run the FDE setup script so that the `crypttab` template detects the new
   keyfile and makes the necessary changes.

   ```shell
   bash -c "$(curl -LfSs https://mfgo.link/rpi-fde)"
   ```

6. Update the initramfs one more time so that the `passdev` script gets
   included.

   ```shell
   sudo CRYPTSETUP=y mkinitramfs -o /tmp/initramfs.gz
   sudo cp /tmp/initramfs.gz /boot/initramfs.gz
   ```

7. Reboot

## todo

- Boot time is artificially delayed because "there is a start job running for
  `/dev/disk/by-label/CRYPTKEY:/key:20` which waits 90 seconds before aborting
  and continuing the boot process.

- When a keyfile is configured if it fails to mount or load it does not prompt
  for a password, but instead loops failure several times and then drops into
  the initramfs shell where you need to manually `cryptsetup luksopen
  /dev/mmcblk0p2 crypt` and then `exit` to successfully continue to boot.
