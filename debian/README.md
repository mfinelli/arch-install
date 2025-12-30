# debian

Automation for debian installations. Using the `netinst` ISO, select:

### gaming (desktop)

- Disabled root account (leave root password blank when prompted)
- Guided; use entire disk and setup encrypted LVM (all files in one partition)
  - Before confirming the choices you can change the filesystem types to
    `btrfs` and enable the `relatime`, `compress`, `ssd` options. (Obviously,
    `ssd` only if it's relevant).
- Don't participate in the package survey
- Debian desktop environment: GNOME
- no web server, no SSH server
- standard system utilities
- Install the GRUB bootloader to the primary drive

### server

- Disabled root account (leave root password blank when prompted)
- Guided; use entire disk and setup encrypted LVM (all files in one partition)
- Don't participate in the package survey
- no desktop environment, no web server
- SSH server, standard system utilities
- Install the GRUB bootloader to the primary drive

## post-install instructions

```shell
sudo apt update && sudo apt upgrade
```

```shell
sudo apt install curl
```

Before proceeding with the next step, if you switched the filesystems to
`btrfs`, then you may want to change the compression algorithm to `zstd`:

```shell
sudo apt install vim
```

Then edit the `/etc/fstab` and change the `compress` option to
`compress=zstd:3`. Then reboot. (Note: this won't affect existing files which
will remain compressed with the older algorithm -- only newly created, and
updates to existing files will use the new compression.)

```shell
bash -c "$(curl -fsSL https://mfgo.link/debian)"
```

**N.B.** there is not a dedicated role for [Discord](https://discord.com) at
this time because they do not provide an apt repository, just single `.deb`
packages, so updates need to be performed manually in `debian.yml` directly.

## todo

- consider `clamav`
- test drive: https://github.com/albertlauncher/albert
- `gdm-settings` will be available with the trixie release
- https://dosbox-staging.github.io/
- https://github.com/visualboyadvance-m/visualboyadvance-m
