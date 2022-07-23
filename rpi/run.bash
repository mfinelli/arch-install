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

ansible-galaxy install -r ../requirements.yml
ansible-playbook --inventory ../localhost --extra-vars fde=$fde rpi.yml

exit 0
