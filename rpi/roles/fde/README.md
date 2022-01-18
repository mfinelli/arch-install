# fde

Enables full-disk encryption.

## guides

- https://robpol86.com/raspberry_pi_luks.html
- https://rr-developer.github.io/LUKS-on-Raspberry-Pi/

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
    sudo mkinitramfs -o /tmp/initramfs.gz
    sudo cp /tmp/initramfs.gz /boot/initramfs.gz
    ```

13. Reboot and continue with the rest of the installation.
