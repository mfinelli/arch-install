# base

Install and configure packages that we always need as well as setup
`pacman` and `makepkg` and sets up a proper mirrorlist.

Should always be suitable to run "pre-reboot".

## bootsplash

Extracts just the Arch logo from the official artwork website:
https://sources.archlinux.org/other/artwork/, specifically the
`archlinux-logo-white-90dpi.png` version.

## systemd-resolved

Sets up `systemd-resolved` to use [cloudflare](https://1.1.1.1) with
DNS-over-TLS.

- https://wiki.archlinux.org/title/Systemd-resolved#DNS_over_TLS
