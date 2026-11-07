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

## arc cache

The ARC cache is unlimited by default (the OpenZFS default). To cap it on a
specific host add an entry to `zfs_arc_max` in `vars/main.yml`:

```yaml
zfs_arc_max:
  calliope: 2G
```

The limit applies when the `zfs` module loads, so it takes effect after a
reboot. To apply it without rebooting (this only works if the module is not
currently in use):

```sh
sudo modprobe -r zfs && sudo modprobe zfs
```

## replication

Hosts that take part in a TrueNAS replication task get a local `zfsrepl` account
(name configurable via `zfs_replication_user`) with ZFS permissions delegated
through `zfs allow`, so neither side needs root over SSH.

Add the host to `zfs_replication` in `vars/main.yml` with the datasets the
account should manage and the direction of the task:

```yaml
zfs_replication:
  kleio:
    datasets:
      - tank/backup
    direction: both
```

| direction | delegation (see `zfs_replication_roles`) | use when                     |
| --------- | ---------------------------------------- | ---------------------------- |
| `push`    | receive, create, destroy, rollback, ...  | TrueNAS replicates **to** us |
| `pull`    | send, snapshot, hold, destroy, ...       | we are the **source**        |
| `both`    | the union of the two                     | this host is on both ends    |

Permissions are applied to each dataset in the list (recursively into its
descendants); datasets that do not exist yet are skipped so the first run does
not fail. `mount` cannot actually be delegated on Linux -- `create`, `destroy`,
`receive` and `snapshot` all require it -- so it is listed for completeness but
has no effect.

## snapshots

Hosts listed in `zfs_sanoid` (in `vars/main.yml`) get
[sanoid](https://github.com/jimsalterjrs/sanoid) installed, configured, and run
from its packaged `sanoid.timer` every 15 minutes. The policy is the standard
one in `defaults/main.yml`:

```yaml
zfs_sanoid_retention:
  daily: 14
  weekly: 4
  monthly: 3
```

Snapshots are named `autosnap_<date>_<time>_<type>`, for example
`autosnap_2026-11-07_23:59:00_daily`. Give the TrueNAS pull task one naming
schema per type:

```text
autosnap_%Y-%m-%d_%H:%M:%S_daily
autosnap_%Y-%m-%d_%H:%M:%S_weekly
autosnap_%Y-%m-%d_%H:%M:%S_monthly
```

### choosing datasets

`zfs_sanoid` is an **explicit include list**: only the datasets named there are
ever snapshotted or pruned, and datasets that do not exist yet are skipped. List
as many datasets as you need:

```yaml
zfs_sanoid:
  kleio:
    - tank/data
    - tank/backup
```

Every entry becomes its own `[dataset]` section in `sanoid.conf`, and each one
recursively snapshots its whole subtree. Entries must therefore be **siblings**.

Sanoid only ever considers snapshots whose name starts with `autosnap` when
snapshotting or pruning anything, so snapshots a TrueNAS push creates on this
host are invisible to it -- provided the push task's naming schema does not
itself start with `autosnap`.

### recursion

`zfs_sanoid_recursive` defaults to `zfs`, which makes sanoid run
`zfs snapshot -r` and produce **one atomic snapshot across the dataset and all
of its children**. Keep this: a TrueNAS pull task of a recursive set requires a
common snapshot name in the parent and every child, and per-dataset snapshots
never satisfy that because children get slightly different timestamps.

The consequence is that every descendant of a listed dataset is snapshotted,
`skip_children` does not apply to `recursive = zfs`, so **any dataset that
TrueNAS pushes into must live outside the listed subtrees** (or be listed
without its parent).

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

2. Get the sector size (though most external SSDs report 512 and we're going to
   use `ashift` `12` (4K block size) unless reported as _larger_ (8K block size
   in which case use `13`):

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
initial ansible run (which creates and enables but does not start the unlock and
scrub jobs) add the unlock key (e.g., `/root/tank.key`) and then run:

```sh
sudo zpool import # see what's available
sudo zpool import tank # `sudo zpool import -f tank` if necessary
```
