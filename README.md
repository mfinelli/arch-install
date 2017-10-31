# Arch Install

I have several machines that I need to install Arch Linux, this should automate
package installation.

## Files

* `bootstrap`: Use this to pacstrap the new system
* `prepare`: Do initial setup in the chroot and install boot packages
* `pre-reboot`: This installs and configures package before rebooting
* `post-reboot`: This installs and configures packages after the first reboot

## Bootstrap

### Step 1: Ensure we're booted in UEFI mode

```shell
efivar -l
```

### Step 2: Establish an internet connection

Get the device names:

```shell
iw dev
```

Connect to a network:

```shell
wifi-menu wlp1s0
```

Ensure the internet is working:

```shell
ping -c 5 google.com
```

### Step 3: Sync the time to the internet

```shell
timedatectl set-ntp true
```

### Step 4: Download the bootstrap script

```shell
wget https://raw.githubusercontent.com/mfinelli/arch-install/master/bootstrap
```

Make sure it's executable:

```shell
chmod +x bootstrap
```

### Step 5: Bootstrap!

Run the script and answer when prompted:

```shell
./bootstrap
```

### Step 6: Chroot and prepare

```shell
arch-chroot /mnt /bin/bash
```
