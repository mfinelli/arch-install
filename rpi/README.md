# raspberry pi

Automation for raspberry pi machines, usually used for running a home
network VPN.

## manual steps

1. Provision the
   [Raspberry PI Operating System](https://www.raspberrypi.com/software/)
   onto the desired microSD card and boot the Pi.

2. After booting, follow the normal setup steps using the graphical
   interface. (Skip applying updates when asked)

3. Reboot

4. Apply any available updates:

   ```shell
   sudo apt update
   sudo apt upgrade
   sudo apt autoremove --purge
   ```

5. Update the hostname so that the role picker works as expected

   ```shell
   sudo raspi-config
   ```

   System Options > Hostname

6. Reboot

7. Log back in with the default `pi` user (the default password if not
   changed during the setup step is "raspberry").

8. If you want to enable full disk encryption follow the steps in the
   [readme](https://github.com/mfinelli/arch-install/blob/master/rpi/roles/fde/README.md)
   for the `fde` role.

   Make sure to edit which hostnames are enabled in `run.bash`.

9. Open a terminal and run:

   ```shell
   bash -c "$(curl -LfSs https://mfgo.link/rpi)"
   ```

10. If you have installed the case fan you can adjust it so that it only turns
    on if it reaches a certain temperature (default 80 degrees Celsius):

    ```shell
    sudo raspi-config
    ```

    Performance Options > Fan > Enable Fan Temperature Control > (Fan is
    connected to GPIO control `14`) > At what temperature should the fan turn
    on: `70`

    **N.B.** you should update which hosts have the case fan in
    `roles/main/vars/main.yml`.