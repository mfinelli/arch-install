#!/usr/bin/env bash

set -e

if [[ $# -ne 0 ]]; then
  echo >&2 "usage: $(basename "$0")"
  exit 1
fi

hn="$(cat /etc/hostname)"
if [[ $hn == atlas ]] || [[ $hn == iris ]]; then
  mtype=server
else
  mtype=personal
fi

sudo echo -n
ansible-playbook --inventory ../localhost \
  --extra-vars mtype=$mtype \
  --extra-vars whoami="$(whoami)" \
  debian.yml

exit 0
