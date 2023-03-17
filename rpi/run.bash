#!/bin/bash -e

if [[ $# -ne 0 ]]; then
  echo >&2 "usage: $(basename "$0")"
  exit 1
fi

hn="$(cat /etc/hostname)"
if [[ $hn == testpi || $hn == parkpi || $hn == raipi ]]; then
  fde=true
else
  fde=false
fi

ansible-playbook --inventory ../localhost \
  --extra-vars fde=$fde --extra-vars whoami="$(whoami)" \
  --extra-vars whoami_home="$HOME" rpi.yml

exit 0
