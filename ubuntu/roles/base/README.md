# base

The baseline role that we use for every Ubuntu installation. Other than
installing packages that we always want installed It does a few interesting
things:

## supermario PPA

Sets up the [supermario PPA](https://github.com/mfinelli/ppa). Normally, we
would use the `ansible.builtin.apt_repository` module to do this, however
with Ubuntu 22.04 the default URL scheme for PPA repositories is HTTPS, and
the ansible module still writes out HTTP URLs and doesn't recognize a PPA
repository added using the command line (like we do during bootstrap in the
`go` script). We therefore assume manual ownership of the PPA sources list
file and manage it using `ansible.builtin.template`.

## https repositories

This role also installs `apt-transport-https` and switches all of the mirrors
to use HTTPS (using `mirrors.kernel.org`).

## dns over tls

This role updates the `systemd-resolved` configuration to use DNS-over-TLS
with Cloudflare's [1.1.1.1](https://1.1.1.1) service. It also enables DNSSEC
validation.

## disable user chooser

Updates the GDM configuration to require username input to enhance security.
