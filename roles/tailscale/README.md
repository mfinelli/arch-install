# tailscale

Installs the [Tailscale](https://tailscale.com) VPN client.

If an oauth secrets is defined in `/root/tailscale-oauth-secret.txt` it will
automatically authenticate the host to the tailnet.

## exit node

If the host is defined in the `tailscale_exit_node_hosts` the role additionally
configures the host as an Tailscale exit node for the tailnet.

## notes

- https://tailscale.com/download/linux/debian-bookworm
- https://tailscale.com/download/linux/ubuntu-2204

## ufw

- https://tailscale.com/kb/1077/secure-server-ubuntu-18-04/
- https://tailscale.com/kb/1082/firewall-ports/
