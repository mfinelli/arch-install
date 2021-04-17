# debian

Automation for my debian installation running in a
[Virtual Box VM](https://www.virtualbox.org).

# manual steps

1. Install debian using the installer GUI
([download](https://www.debian.org/distrib/netinst#smallcd)). Set the hostname
to `debian`.

2. After installation and reboot insert the Guest Additions CD and install
them. You need to make sure that you can run scripts from CDs by making sure
the cdrom is mounted with `exec`. Entry from `/etc/fstab`:

```
/dev/sr0        /media/cdrom0   udf,iso9660 user,exec,noauto     0       0
```

3. Enable the bi-directional shared clipboard: Devices > Shared Clipboard.

4. Download and run the installer:

```shell
su -c 'apt-get install -y curl'
curl -LfSs https://mfgo.link/debian > go
chmod +x go
./go
rm go
```

5. Add a USB filter to the VM to pass-through the Yubikey: Settings > USB
Then click the little plus while the Yubikey is plugged into the host machine
to add a filter. Then reboot.

6. Install [dotfiles](https://github.com/mfinelli/dotfiles):

```shell
curl -Ls https://mfgo.link/dotfiles | bash
```

7. Change your shell to `zsh`:

```shell
chsh -s /bin/zsh
```
