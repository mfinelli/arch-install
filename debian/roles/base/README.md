# base

Baseline configuration for every system:

- Configure `systemd-resolved` to use DNS-over-TLS
- Configure the `sources.list` to use HTTPS-enabled sources
- Add the [Fast Track](https://fasttrack.debian.net) repository
- Adds my custom debian repository (hosted on the [openSUSE Open Build
  Service](https://build.opensuse.org/project/show/home:mfinelli:main))
- Enable a simple, stateful firewall to block incoming connections
- Install baseline packages

## zfs

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
   sudo dd if=/dev/random of=/root/tank.key bs=1024 count=4
   chmod 0400 /root/tank.key
   ```

4. Create the pool:

   ```sh
   sudo zpool create \
     -o ashift=12 \
     -O encryption=aes-256-gcm \
     -O keyformat=raw \
     -O keylocation=file:///root/zfs-keys/tank.key \
     -O compression=zstd \
     -O atime=off \
     -O autotrim=on \ # only for SSD
     -O acltype=posixacl \
     -O xattr=sa \
     -o autoexpand=on \
     tank mirror /dev/disk/by-id/usb-DISK1... /dev/disk/by-id/usb-DISK2...
   ```

5. Create dataset for a given service (the mountpoint is optional and otherwise
   mounts at `/tank/myservice`; custom mountpoint options must be passed to
   child datasets as well):

   ```sh
   zfs create -o mountpoint=/mnt/tank/myservice tank/myservice
   ```

6. Create any child datasets:
   ```sh
   zfs create tank/myservice/data
   ```
