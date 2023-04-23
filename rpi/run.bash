#!/bin/bash -e

if [[ $# -ne 0 ]]; then
  echo >&2 "usage: $(basename "$0")"
  exit 1
fi

declare -a fde_enabled_hosts=(homepi parkpi raipi testpi)

# https://unix.stackexchange.com/a/177589
declare -A fde_enabled_host
for host in "${fde_enabled_hosts[@]}"; do fde_enabled_host[$host]=1; done

if [[ -n ${fde_enabled_host[$(cat /etc/hostname)]} ]]; then
  fde=true
else
  fde=false
fi

ansible-playbook --inventory ../localhost --extra-vars fde=$fde \
  --extra-vars whoami="$(whoami)" rpi.yml

exit 0
