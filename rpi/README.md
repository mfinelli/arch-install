# raspberry pi

Automation for raspberry pi machines, usually used for running a home
network VPN.

## manual steps

1. Provision the
   [Raspberry PI Operating System](https://www.raspberrypi.com/software/)
   onto the desired microSD card and boot the Pi.
   - Select Raspberry Pi OS Lite (64-bit)
   - Set the Wi-Fi network, password, and country
   - Set the timezone and keyboard layout

2. After booting, follow the normal setup steps. Create a user `mario` when
   prompted with a desired password.

3. Let the initial, internal bootstrap process finish and then login with the
   new user.

4. If desired, change the default sources to https before doing anything else:

   ```shell
   sudo sed -i 's|http://|https://|g' /etc/apt/sources.list.d/*.sources
   ```

5. Apply any available updates:

   ```shell
   sudo apt update
   sudo apt upgrade
   sudo apt autoremove --purge
   ```

6. Update the hostname so that the role picker works as expected

   ```shell
   sudo raspi-config
   ```

   System Options > Hostname

7. Reboot

8. Open a terminal and run:

   ```shell
   bash -c "$(curl -LfSs https://mfgo.link/rpi)"
   ```

9. If you want to enable full disk encryption ensure the hostname is enabled
   in `run.bash`. Reboot then follow the instructions in the
   [readme](https://github.com/mfinelli/arch-install/blob/master/rpi/roles/fde/README.md)
   for the `fde` role.

10. If you have installed the case fan you can adjust it so that it only turns
    on if it reaches a certain temperature (default 80 degrees Celsius). This
    is not necessary if you add the host to the `fan_enabled_hosts` variable in
    the `main` role:

    ```shell
    sudo raspi-config
    ```

    Performance Options > Fan > Enable Fan Temperature Control > (Fan is
    connected to GPIO control `14`) > At what temperature should the fan turn
    on: `70`

    **N.B.** you should update which hosts have the case fan in
    `roles/main/vars/main.yml`.

11. Install [dotfiles](https://github.com/mfinelli/dotfiles) (which should be
    done after connecting via SSH as the dotfiles repository uses the forwarded
    keys to setup SSH)
