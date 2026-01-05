# server

Configure SSH and sudo.

## disk encryption

This role also installs the tools necessary to automatically decrypt the root
LUKS volume on boot. (The system must have a TPM2 for this to work, obviously.)

Following this guide: https://rainygarden.net/articles/LUKS_and_Clevis.html
reboot, and then run these steps after running the initial `arch-install`/`go`:

```shell
lsblk # get the crypt device
sudo clevis luks bind -d /dev/device tpm2 \
  '{"pcr_bank":"sha256","pcr_ids":"1,7"}'
sudo clevis luks list -d /dev/device
sudo update-initramfs -k all -u
```

Verify that the original passphrase is still present:

```shell
sudo cryptsetup luksDump /dev/device
```

## networking

The default Debian install uses classic ifupdown for networking. Following the
information found in https://manski.net/articles/linux/network-config we switch
to `systemd-networkd` and `iwd`. Some of the steps taken from the linked
script: https://github.com/skrysm/systemd-networkd-init.

### details

We re-configure the Wi-Fi connection using `iwctl` one-time only -- that is if
we still have the original `/etc/network/interfaces` from the original install
then we read the SSID and password from it and configure `iwd`. Otherwise we
assume that we've already done that and skip those steps.
