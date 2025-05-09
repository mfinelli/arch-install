# arch-install

Originally created to automate installing [Arch Linux](https://archlinux.org),
this repository now contains installation configuration for many systems:
[Debian](https://www.debian.org), [Ubuntu](https://ubuntu.com),
[macOS](https://www.apple.com/macos/), and
[Raspberry Pi OS](https://www.raspberrypi.com/software/) (as well, of course,
as the original Arch Linux). Installations are mostly managed using
[Ansible](https://www.ansible.com), using bash scripts for steps where that is
not feasible or reasonable.

Refer to the README in the specific operating system directories for specific
instructions for a given system.

## preparing USB installation medium

Other options available in the Arch wiki, but I find the following the simplest
option (as root):

```shell
dd bs=4M if=/path/to.iso of=/dev/sda conv=fsync oflag=direct status=progress
```
