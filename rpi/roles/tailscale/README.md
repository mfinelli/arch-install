# tailscale

Installs and configures tailscale as an exit node.

The installation steps are reverse engineered from the installation
script: https://tailscale.com/install.sh

Once tailscale is installed you will need to manually enable the exist node
status with `sudo tailscale up --advertise-exit-node` and then allow the
exit node from the tailscale console and ensure that there is no key expiry.
