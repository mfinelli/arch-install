# base

Baseline configuration for every system:

- Configure `systemd-resolved` to use DNS-over-TLS
- Configure the `sources.list` to use HTTPS-enabled sources
- Add the [Fast Track](https://fasttrack.debian.net) repository
- Enable a simple, stateful firewall to block incoming connections
- Install baseline packages
