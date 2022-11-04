#!/usr/bin/env bash

set -e

hn="$(cat /etc/hostname)"
if [[ $hn == zen ]]; then
  mtype=media
elif [[ $hn == bowser || $hn == wario ]]; then
  mtype=gaming
elif [[ $hn == odev || $hn == ubuilder ]]; then
  mtype=server
else
  echo >&2 "error: unkown machine type"
  exit 1
fi

# on first run we probably have snap installed
if command -v snap > /dev/null 2>&1; then
  ./snapd.bash
fi

if ! ansible-galaxy install -r ../requirements.yml; then
  ansible-galaxy install -f -r ../requirements.yml
fi

sudo echo -n
ansible-playbook --inventory ../localhost --extra-vars mtype=$mtype ubuntu.yml

exit 0
