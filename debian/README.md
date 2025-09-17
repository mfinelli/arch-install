# debian

Automation for debian gaming installation. Using the `netinst` ISO, select:

- Disabled root account (leave root password blank when prompted)
- Guided; use entire disk and setup encrypted LVM (all files in one partition)
- Don't participate in the package survey
- Debian desktop environment: GNOME
- no web server, no SSH server
- standard system utilities
- Install the GRUB bootloader to the primary drive

## post-install instructions

```shell
sudo apt update && sudo apt upgrade
```

```shell
sudo apt install curl
```

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
