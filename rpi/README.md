# raspberry pi

Automation for raspberry pi machines, usually used for running a home
network VPN.

## manual steps

1. Provision the
   [Raspberry PI Operating System](https://www.raspberrypi.com/software/)
   onto the desired microSD card and boot the Pi.

2. After booting, follow the normal setup steps using the graphical
   interface.

3. Update the hostname so that the role picker works as expected

   ```shell
   sudo raspi-config
   ```

   System Options > Hostname

4. Reboot

5. Log back in with the default `pi` user (the default password if not
   changed during the setup step is "raspberry").

6. If you want to enable full disk encryption follow the steps in the
   [readme](https://github.com/mfinelli/arch-install/blob/master/rpi/roles/fde/README.md)
   for the `fde` role.

   Make sure to edit which hostnames are enabled in `fde.bash` and `run.bash`.

7. Open a terminal and run:

   ```shell
   bash -c "$(curl -LfSs https://mfgo.link/rpi)"
   ```

7. If you have installed the case fan you can adjust it so that it only turns
   on if it reaches a certain temperature (default 80 degrees Celsius):

   ```shell
   sudo raspi-config
   ```

   Performance Options > Fan > Enable Fan Temperature Control > (Fan is
   connected to GPIO control `14`) > At what temperature should the fan turn
   on: `70`

   **N.B.** you should update which hosts have the case fan in
   `roles/main/vars/main.yml`.
