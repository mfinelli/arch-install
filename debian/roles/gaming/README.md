# gaming

Installs packages for gaming on linux.

## steam

We prefer the upstream release to what is packaged in the debian/ubuntu
repositories: https://repo.steampowered.com/steam/.

Actions for enabling the `i386` architecture are taken from here:
https://github.com/jdauphant/ansible-role-packaging/blob/master/tasks/Debian.yml

## wine

We install directly from upstream to always have the latest updates (on the
stable channel): https://wiki.winehq.org/Debian
