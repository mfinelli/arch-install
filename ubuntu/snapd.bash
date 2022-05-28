#!/usr/bin/env bash

set -e

# purges snapd from the system
# see: https://haydenjames.io/remove-snap-ubuntu-22-04-lts/
# usage: ./snapd.bash

if [[ $# -ne 0 ]]; then
  echo >&2 "usage: $(basename "$0")"
  exit 1
fi

if ! command -v snap > /dev/null 2>&1; then
  echo >&2 "error: it appears that snap has already been removed"
  exit 1
fi

# step 1: remove other snaps
sudo snap remove $(snap list | tail -n +2 | awk '{print $1}' |
  grep -vE '^bare|core|snapd' | tr '\n' ' ')

# step 2: remove core snaps
sudo snap remove snapd-desktop-integration
sudo snap remove $(snap list | tail -n +2 | awk '{print $1}' | grep ^core)
sudo snap remove bare
sudo snap remove snapd

# step 3: uninstall snapd
sudo apt autoremove --purge snapd

# step 4: additional cleanup
rm -rf ~/snap

exit 0
