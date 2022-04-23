#!/usr/bin/env bash

set -e

hn="$(cat /etc/hostname)"
if [[ $hn == zen ]]; then
  mtype=media
elif [[ $hn == stig ]]; then
  mtype=gaming
else
  echo >&2 "error: unkown machine type"
  exit 1
fi

ansible-playbook --extra-vars mtype=$mtype ubuntu.yml

exit 0
