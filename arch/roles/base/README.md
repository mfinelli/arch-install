# base

Install and configure packages that we always need as well as setup
`pacman` and `makepkg` and sets up a proper mirrorlist.

Should always be suitable to run "pre-reboot".

## bootsplash

Extracts just the Arch logo from the official artwork website:
https://sources.archlinux.org/other/artwork/, specifically the
`archlinux-logo-white-90dpi.png` version.

## systemd-resolved

Sets up `systemd-resolved` to use [cloudflare](https://1.1.1.1) with
DNS-over-TLS.

- https://wiki.archlinux.org/title/Systemd-resolved#DNS_over_TLS

## extra disks

This mostly follows the guide in the `rpi` role but slightly expanded.

1. Partition the disk using `fdisk`:

   ```shell
   sudo fdisk -n /dev/sda
   ```

   - Create a new partition table: `g`
   - Create a new partition: `n`; accept all of the defaults (partition number
     1, first sector, and last sector) to let a single partition consume the
     entire disk
   - The default filesystem type "Linux filesystem" is okay
   - Enter "expert mode": `x`
   - Change the partition name: `n`; this corresponds to the `label` key in
     `base_attached_storage` variable
   - Return to the main menu: `r`
   - Print the partition table: `p`; inspect that everything looks good
   - Write the new partition table and exit: `w`

2. Encrypt the disk

   ```shell
   sudo cryptsetup --type luks2 --cipher aes-xts-plain64 --key-size 512 \
     --hash sha512 --pbkdf argon2id --iter-time 5000 --sector-size 4096 \
     --integrity hmac-sha256 --use-random --verify-passphrase \
     luksFormat /dev/disk/by-partlabel/DATADISK
   ```

3. Open the new LUKS container

   ```shell
   sudo cryptsetup luksOpen /dev/disk/by-partlabel/DATADISK tmpmnt
   ```

4. Make new filesystem

   ```shell
   sudo mkfs.btrfs /dev/mapper/tmpmnt
   ```

5. Generate a new keyfile to automatically unlock the disk on boot

   ```shell
   sudo dd if=/dev/random of=/root/datadiskkey bs=1024 count=4
   sudo chmod 0400 /root/datadiskkey
   ```

6. Add the keyfile to the LUKS header

   ```shell
   sudo cryptsetup luksAddKey /dev/disk/by-partlabel/DATADISK /root/datadiskkey
   ```

7. Run ansible again to setup the `crypttab` and `fstab`
