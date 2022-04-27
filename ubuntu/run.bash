#!/usr/bin/env bash

set -e

hn="$(cat /etc/hostname)"
if [[ $hn == zen ]]; then
  mtype=media
elif [[ $hn == stig ]]; then
  mtype=gaming
elif [[ $hn == odev ]]; then
  mtype=server
else
  echo >&2 "error: unkown machine type"
  exit 1
fi

sudo echo -n
ansible-playbook --inventory ../localhost --extra-vars mtype=$mtype ubuntu.yml

exit 0
