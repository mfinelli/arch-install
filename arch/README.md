# arch

Automation for Arch Linux installations.

## manual steps

1. Download the install [image](https://www.archlinux.org/download/) and
[prepare](https://wiki.archlinux.org/index.php/USB_flash_installation_medium)
a USB flash drive.

2. After booting into the live image connect to the internet:

```
TODO
```

3. Prepare the installation disk by overwriting it with random data:

```shell
dd if=/dev/urandom of=/dev/sdX bs=4096
```

4. Install the baseline Arch Linux installation:

```shell
bash -c "$(curl -fsSL https://mfgo.link/arch-pacstrap)"
```

5. `chroot` into the new system and bootstrap it (install required packages
and bootloader):

```shell
arch-chroot /mnt /bin/bash
```

```shell
bash -c "$(curl -fsSL https://mfgo.link/arch-bootstrap)"
```

6. Set `root` password, create user and add sudo rule:

```shell
passwd
```

```shell
useradd -m -s /bin/bash mario
passwd mario
echo "mario ALL=(ALL:ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/mario
chmod 0440 /etc/sudoers.d/mario
```

7. Switch user and run ansible

```shell
su mario -
cd
curl -Ls https://mfgo.link/arch-install | bash
```
