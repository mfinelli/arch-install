#!/bin/bash -e

if [[ $# -ne 0 ]]; then
  echo >&2 "usage: $(basename "$0")"
  exit 1
fi

if lspci | grep VGA | grep -qi amd; then
  gcard=amd
elif lspci | grep VGA | grep -qi intel; then
  gcard=intel
else
  gcard=none
fi

# promp for sudo password right away
sudo echo -n

ansible-playbook \
  --extra-vars gcard=$gcard \
  --extra-vars multilib=true \
  arch.yml

exit 0
