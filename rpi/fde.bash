#!/bin/bash -e

if [[ $# -ne 0 ]]; then
  echo >&2 "usage: $(basename "$0")"
  exit 1
fi

sudo apt install -y ansible git

hn="$(cat /etc/hostname)"
if [[ $hn == raspberrypi || $hn == parkpi ]]; then
  fde=true
else
  fde=false
fi

ansible-playbook --extra-vars fde=$fde rpi.yml --tags fde

exit 0
