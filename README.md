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

### Step 5: Prepare the disk:

If this is the first install the disk needs to be wiped with random data:

```shell
dd if=/dev/urandom of=/dev/sdX bs=4096
```

### Step 6: Bootstrap!

Run the script and answer when prompted:

```shell
./bootstrap
```

### Step 7: Chroot and prepare

```shell
arch-chroot /mnt /bin/bash
```

### Step 8: Get the prepare script

Use a temporary directory:

```shell
cd $(mktemp -d)
```

Download the script

```shell
curl -O https://raw.githubusercontent.com/mfinelli/arch-install/master/prepare
```

Make sure it's executable:

```shell
chmod +x prepare
```

### Step 9: Run the prepare!

Make sure you pass in the device from bootstrap! (e.g. /dev/sda)

```shell
./prepare /dev/sda
```

### Step 10: Now is a good time to set the `root` password

```shell
passwd
```

### Step 11: Download the pre-reboot script

Do the work in a temporary directory (or reuse the existing one):

```shell
cd $(mktemp -d)
```

Download the script:

```shell
curl -O https://raw.githubusercontent.com/mfinelli/arch-install/master/pre-reboot
```

Make sure it's executable:

```shell
chmod +x pre-reboot
```

### Step 12: Run the `pre-reboot` script

```shell
./pre-reboot
```

### Step 13: Create the normal user

```shell
useradd -m -s /bin/bash mario
```

Set the password:

```shell
passwd mario
```

Add the following line to /etc/sudoers after the `root ALL=(ALL) ALL` entry:

```
mario ALL=(ALL) ALL
```

```shell
visudo
```

### Step 14: Prepare to reboot

Exit the chroot

```shell
exit
```

Unmount all the partitions:

```shell
umount -R /mnt; swapoff /dev/crypt/swap
```

Finally, reboot:

```shell
reboot
```

### Step 15: Get the post-reboot script

Do the work in a temporary directory:

```shell
cd $(mktemp -d)
```

```shell
wget https://raw.githubusercontent.com/mfinelli/arch-install/master/post-reboot
```

Make sure it's executable:

```shell
chmod +x post-reboot
```

### Step 16: Run the `post-reboot`!

```shell
./post-reboot
```
