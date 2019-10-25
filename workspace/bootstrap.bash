#!/bin/bash -e

if [[ $(id -u) -eq 0 ]]; then
  echo >&2 "must not run as root!"
  exit 1
fi

if [[ ! -f workspace.yml ]]; then
  echo >&2 "unable to find workspace playbook"
  exit 1
fi

ansver="$(grep my_ansible_version: workspace.yml | awk -F:\  '{print $2}')"

if [[ -z $ansver ]]; then
  echo >&2 "unable to get ansible version from playbook"
  exit 1
fi

# prompt for password right away
sudo echo -n

sudo yum update
sudo yum install python{,-pip}
sudo pip install ansible=="$ansver"

ansiblebin="$(sudo which ansible-playbook)"

$ansiblebin \
  --extra-vars whoami="$(whoami)" \
  --extra-vars whoami_group="$(id -ng)" \
  --extra-vars homedir="$(whoami | awk -F\\ '{print $2}')" \
  ./workspace.yml

exit 0
