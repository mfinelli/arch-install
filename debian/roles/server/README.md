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
