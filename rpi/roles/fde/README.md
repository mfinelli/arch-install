# fde

Enables full-disk encryption.

## guides

- https://robpol86.com/raspberry_pi_luks.html
- https://rr-developer.github.io/LUKS-on-Raspberry-Pi/
- https://blog.fidelramos.net/software/unlock-luks-usb-drive

## steps

1. After running the initial ansible setup reboot, wait for the boot failure,
   and to be dropped into the initramfs shell.

2. Ensure that the proper cryptsetup modules have been loaded:

   ```shell
   cryptsetup benchmark -c xchacha20,aes-adiantum-plain64
   ```

3. Check the main root filesystem and then shrink it for copy:

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

4. Insert the temporary USB drive and check it's device (probably `/dev/sda`):

   ```shell
   fdisk -l /dev/sda
   ```

5. Copy the old filesystem to the USB device (overwriting any existing data)
   and then ensure the previously computed checksum matches:

   ```shell
   time dd bs=4k count=XXXXX if=/dev/mmcblk0p2 of=/dev/sda
   time dd bs=4k count=XXXXX if=/dev/sda | sha1sum
   ```

6. Encrypt and then open the root filesystem

   ```shell
   cryptsetup --type luks2 --cipher xchacha20,aes-adiantum-plain64 \
     --hash sha256 --iter-time 5000 --key-size 256 --pbkdf argon2id \
     luksFormat /dev/mmcblk0p2
   ```

   ```shell
   cryptsetup luksOpen /dev/mmcblk0p2 crypt
   ```

7. Copy back the saved filesystem and verify its checksum:

   ```shell
   time dd bs=4k count=XXXXX if=/dev/sda of=/dev/mapper/crypt
   time dd bs=4k count=XXXXX if=/dev/mapper/crypt | sha1sum
   ```

8. Run a filesystem check and then expand the filesystem:

   ```shell
   e2fsck -f /dev/mapper/crypt
   resize2fs -f /dev/mapper/crypt
   ```

9. Remove the USB drive and then reboot

10. After the reboot from the initramfs shell mount the luks volume to
    continue booting

    ```shell
    cryptsetup luksOpen /dev/mmcblk0p2 crypt
    exit
    ```

11. Rebuild the initramfs one more time for the password prompt to appear at
    boot time:

    ```shell
    sudo CRYPTSETUP=y mkinitramfs -o /tmp/initramfs.gz
    sudo mv /tmp/initramfs.gz /boot/initramfs.gz
    ```

12. Reboot and continue with the rest of the installation.

## keyfiles

If you want to setup the device to boot with a keyfile via USB key on boot
you can additionally follow these instructions.

1. If you're going to reuse the USB drive that you used to temporarily store
   the root filesystem during encryption you'll need to reformat it. It can
   easily be done with `fdisk`, Be sure to give the filesystem a label
   `CRYPTKEY` so that the `crypttab` works correctly.

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

   3. Partition the disk with `fdisk`:

      ```shell
      sudo fdisk /dev/sda
      ```

   4. Delete any existing partitions (if you didn't overwrite the disk
      earlier) and then create a new partition (`n` and then `p` for primary)
      and let it take the entire disk (defaults for start and stop sectors).
      Print the partition table with `p` and if everything looks good then
      write the partition table and quit with `w`.

   5. Create a new FAT32 filesystem

      ```shell
      sudo mkfs.vfat -F32 -n CRYPTKEY /dev/sda1
      ```

   6. Mount the new filesystem:

      ```shell
      sudo mkdir -p /media/root/usb
      sudo mount /dev/sda1 /media/root/usb
      ```

2. Create the keyfile, we initially create it in `/root` so that we have a
   backup in case we need to create a new USB drive we can just use the normal
   luks password to decrypt and then copy the keyfile to a new device.

   ```shell
   sudo dd if=/dev/random of=/root/cryptkey bs=1024 count=4
   sudo chmod 0400 /root/cryptkey
   sudo cp /root/cryptkey /media/pi/CRYPTKEY/key
   ```

3. Add the new keyfile to the luks header:

   ```shell
   sudo cryptsetup luksAddKey /dev/mmcblk0p2 /root/cryptkey
   ```

4. Re-run the FDE setup script so that the `crypttab` template detects the new
   keyfile and makes the necessary changes.

   ```shell
   bash -c "$(curl -LfSs https://mfgo.link/rpi)"
   ```

5. Update the initramfs one more time so that the `passdev` script gets
   included.

   ```shell
   sudo CRYPTSETUP=y mkinitramfs -o /tmp/initramfs.gz
   sudo mv /tmp/initramfs.gz /boot/initramfs.gz
   ```

6. Reboot

7. Remove the temporary mount directory that we created

   ```shell
   sudo rm -rf /media/root
   ```

## todo

- Boot time is artificially delayed because "there is a start job running for
  `/dev/disk/by-label/CRYPTKEY:/key:20` which waits 90 seconds before aborting
  and continuing the boot process.

- When a keyfile is configured if it fails to mount or load it does not prompt
  for a password, but instead loops failure several times and then drops into
  the initramfs shell where you need to manually `cryptsetup luksopen
  /dev/mmcblk0p2 crypt` and then `exit` to successfully continue to boot.
