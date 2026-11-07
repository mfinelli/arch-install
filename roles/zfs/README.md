# zfs

Installs and configures [OpenZFS](https://openzfs.github.io/openzfs-docs/) on
Debian-based systems (Debian and Raspberry Pi OS). Hosts are enabled by adding
them to `zfs_pools` in `vars/main.yml`; a host with an empty list only gets
`zfs-dkms`, `zfsutils-linux`, and outgoing mail via `msmtp`.

For every host with at least one pool the role additionally:

- installs and enables `zfs-zed.service`
- installs a `zfs-unlock@.service` template unit and enables an instance per
  pool, which loads the pool's encryption key from `/root/<pool>.key` at boot
- installs and enables a monthly `zfs-scrub@.timer` per pool
- points ZED email at the address from `/root/smtp-addr.txt` (only if that file
  exists)

## email

ZED sends mail through `msmtp`, so the role configures it for every host in
`zfs_pools`. Values are read from root-only files and are optional; the
`msmtprc` is only written when all four exist (an unconfigured host simply gets
the packages):

| file                  | value                        |
| --------------------- | ---------------------------- |
| `/root/smtp-host.txt` | submission host (port `465`) |
| `/root/smtp-user.txt` | username                     |
| `/root/smtp-pass.txt` | password                     |
| `/root/smtp-addr.txt` | domain used for sender       |

## usage

A brief guide to setting up a zfs mirrored pair.

1. Get the disk ids:

   ```sh
   ls -la /dev/disk/by-id/ | grep -iE "ata-|usb-"
   ```

2. Get the sector size (though most external SSDs report 512 and we're going
   to use `ashift` `12` (4K block size) unless reported as _larger_ (8K block
   size in which case use `13`):

   ```sh
   lsblk -o NAME,PHY-SEC,LOG-SEC /dev/sdX
   ```

3. Generate an encryption key and back it up somewhere safe, this is the
   **ONLY** key, there's no backup password option:

   ```sh
   sudo dd if=/dev/urandom of=/root/tank.key bs=32 count=1
   sudo chmod 0400 /root/tank.key
   ```

4. Wipe any existing filesystems:

   ```sh
   sudo wipefs -a /dev/disk/by-id/usb-DISK1...
   sudo wipefs -a /dev/disk/by-id/usb-DISK2...
   ```

5. Create the pool:

   ```sh
   sudo zpool create \
     -o ashift=12 \
     -O encryption=aes-256-gcm \
     -O keyformat=raw \
     -O keylocation=file:///root/tank.key \
     -O compression=zstd \
     -O atime=off \
     -o autotrim=on \ # only for SSD
     -O acltype=posixacl \
     -O xattr=sa \
     -o autoexpand=on \
     tank mirror /dev/disk/by-id/usb-DISK1... /dev/disk/by-id/usb-DISK2...
   ```

6. Create dataset for a given service (the mountpoint is optional and otherwise
   mounts at `/tank/myservice`; custom mountpoint options must be passed to
   child datasets as well):

   ```sh
   sudo zfs create -o mountpoint=/mnt/tank/myservice tank/myservice
   ```

7. Create any child datasets:
   ```sh
   sudo zfs create tank/myservice/data
   ```

### mounting to a new machine

If possible, run `sudo zpool export <name>` (e.g., `tank` for `<name>`) on the
previous host otherwise you may need to pass `-f` when importing to a new host.

After running ansible it's necessary to manually import the pool. After the
initial ansible run (which creates and enables but does not start the unlock
and scrub jobs) add the unlock key (e.g., `/root/tank.key`) and then run:

```sh
sudo zpool import # see what's available
sudo zpool import tank # `sudo zpool import -f tank` if necessary
```
