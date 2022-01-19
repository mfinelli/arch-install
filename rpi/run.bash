#!/bin/bash -e

if [[ $# -ne 0 ]]; then
  echo >&2 "usage: $(basename "$0")"
  exit 1
fi

hn="$(cat /etc/hostname)"
if [[ $hn == raspberrypi || $hn == parkpi ]]; then
  fde=true
else
  fde=false
fi

ansible-galaxy install -r requirements.yml
ansible-playbook --extra-vars fde=$fde rpi.yml
ansible-playbook user.yml

exit 0
