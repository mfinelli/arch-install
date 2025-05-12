# arch

Automation for Arch Linux installations.

## installation instructions

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

   ```shell
   ip link # get device name
   iwctl # start interactive prompt
   ```

   Presuming our device is called `wlan0`:

   ```
   [iwd]# device list
   [iwd]# station wlan0 scan
   [iwd]# station wlan0 get-networks
   [iwd]# station wlan0 connect SSID(network name)
   ```

   Confirm connectivity:

   ```shell
   ping -c 3 archlinux.org
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

8. Set `root` password and create normal user:

   ```shell
   passwd
   ```

   ```shell
   useradd -m -s /bin/bash mario
   chfn mario
   passwd mario
   usermod -a -G sudo mario
   usermod -a -G wheel mario
   ```

9. The `KEYMAP` variable must be set in `/etc/vconsole.conf` for the
   `sd-vconsole` mkinitcpio hook. Use what you set in step 2:

   ```shell
   echo KEYMAP=it > /etc/vconsole.conf
   ```

   Or, if you use the default (us) keymap:

   ```shell
   echo KEYMAP=us > /etc/vconsole.conf
   ```

10. Switch user and run ansible

    ```shell
    su mario -
    cd
    bash -c "$(curl -fsSL https://mfgo.link/arch-setup)"
    ```

11. Reboot

    ```shell
    exit
    exit
    umount -R /mnt
    swapoff /dev/crypt/swap
    systemctl reboot
    ```

12. If necessary, make the keymap change permanent

    ```shell
    sudo loadkeys it
    sudo localectl set-keymap --no-convert it
    ```

13. Reconnect to the internet. In a virtual machine you should already be
    connected. Otherwise connect using the `nmcli`:

    ```shell
    nmcli dev status
    nmcli radio wifi
    nmcli dev wifi list
    sudo nmcli --ask dev wifi connect SSID(network name)
    ```

14. Set any `finellictl` configurations

    ```shell
    finellictl language en_US # default
    finellictl timezone America/New_York # default: UTC
    finellictl wregdom US # default
    ```

15. Run the post-first reboot portion of the setup

    ```shell
    bash -c "$(curl -fsSL https://mfgo.link/arch-install)"
    ```

16. Reboot

    ```shell
    sudo systemctl reboot
    ```

17. Install [dotfiles](https://github.com/mfinelli/dotfiles)

18. Set default shell to zsh

    ```shell
    chsh -s /bin/zsh
    ```

19. Disable the root account

    ```shell
    sudo passwd -l root
    ```
