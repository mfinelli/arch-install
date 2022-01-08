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

6. Open a terminal and run:

   ```shell
   bash -c "$(curl -LfSs https://mfgo.link/rpi)"
   ```
