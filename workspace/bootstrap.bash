#!/bin/bash -e

if [[ $(id -u) -eq 0 ]]; then
  echo >&2 "must not run as root!"
  exit 1
fi

if [[ ! -f workspace.yml ]]; then
  echo >&2 "unable to find workspace playbook"
  exit 1
fi


# prompt for password right away
sudo echo -n

sudo yum install python{,-pip}
sudo pip install ansible=="$ansver"

sudo ansible-playbook --extra-vars whoami="$(whoami)" ./workspace.yml

exit 0
