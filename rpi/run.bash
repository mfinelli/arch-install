#!/bin/bash -e

if [[ $# -ne 0 ]]; then
  echo >&2 "usage: $(basename "$0")"
  exit 1
fi

ansible-galaxy install -r requirements.yml
ansible-playbook rpi.yml
ansible-playbook user.yml

exit 0
