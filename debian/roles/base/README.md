# base

Baseline configuration for every system:

- Configure `systemd-resolved` to use DNS-over-TLS
- Configure the `sources.list` to use HTTPS-enabled sources
- Add the [Fast Track](https://fasttrack.debian.net) repository
- Adds my custom debian repository (hosted on the [openSUSE Open Build
  Service](https://build.opensuse.org/project/show/home:mfinelli:main))
- Enable a simple, stateful firewall to block incoming connections
- Install baseline packages
