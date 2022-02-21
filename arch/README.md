# arch

Automation for Arch Linux installations.

## desktop / media installations

### manual steps

1. Download the install [image](https://www.archlinux.org/download/) and
[prepare](https://wiki.archlinux.org/index.php/USB_flash_installation_medium)
a USB flash drive.

2. If necessary, change the keymap: e.g.,

   ```shell
   loadkeys it
   ```

3. Ensure that we're booted in UEFI mode:

   ```shell
   efivar -l
   ls /sys/firmware/efi/efivars
   ```

4. After booting into the live image connect to the internet:

   ```
   TODO
   ```

5. Prepare the installation disk by overwriting it with random data:

   ```shell
   dd if=/dev/urandom of=/dev/sdX bs=4096
   ```

6. Install the baseline Arch Linux installation:

   ```shell
   bash -c "$(curl -fsSL https://mfgo.link/arch-pacstrap)"
   ```

7. `chroot` into the new system and bootstrap it (install required packages
   and bootloader):

   ```shell
   arch-chroot /mnt /bin/bash
   ```

   ```shell
   bash -c "$(curl -fsSL https://mfgo.link/arch-bootstrap)"
   ```

8. Set `root` password, create user and add sudo rule:

   ```shell
   passwd
   ```

   ```shell
   useradd -m -s /bin/bash mario
   chfn mario
   passwd mario
   echo "mario ALL=(ALL:ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/mario
   chmod 0440 /etc/sudoers.d/mario
   ```

9. Switch user and run ansible

   ```shell
   su mario -
   cd
   bash -c "$(curl -fsSL https://mfgo.link/arch-setup)"
   ```

10. Reboot

    ```shell
    exit
    exit
    umount -R /mnt
    swapoff /dev/crypt/swap
    reboot
    ```

11. If necessary, make the keymap change permanent

    ```shell
    sudo loadkeys it
    sudo localectl set-keymap --no-convert it
    ```

11. Reconnect to the internet. In a virtual machine it is enough to just
    start `NetworkManager.service`. Otherwise:

    ```
    TODO
    ```

12. Run the post-first reboot portion of the setup

    ```shell
    bash -c "$(curl -fsSL https://mfgo.link/arch-install)"
    ```

13. Reboot

    ```shell
    sudo reboot
    ```

14. Install [dotfiles](https://github.com/mfinelli/dotfiles)

15. Set default shell to zsh

    ```shell
    chsh -s /bin/zsh
    ```

## server installations

### manual steps

1. SSH (as root) to the server

   ```shell
   ssh root@cdev.finelli.dev
   ```

2. Create user and sudo rules

   ```shell
   useradd -m -s /bin/bash mario
   echo "mario ALL=(ALL:ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/mario
   chmod 0440 /etc/sudoers.d/mario
   ```

3. Copy root authorized ssh keys to user

   ```shell
   mkdir /home/mario/.ssh
   chmod 0700 /home/mario/.ssh
   cat /root/.ssh/authorized_keys > /home/mario/.ssh/authorized_keys
   chmod 0600 /home/mario/.ssh/authorized_keys
   chown -R mario:mario /home/mario/.ssh
   ```

4. Switch user and do the needful

   ```shell
   su mario -
   cd ~
   bash -c "$(curl -fsSL https://mfgo.link/arch-server)"
   bash -c "$(curl -fsSL https://mfgo.link/arch-setup)"
   bash -c "$(curl -fsSL https://mfgo.link/arch-install)"
   ```

5. Reboot
