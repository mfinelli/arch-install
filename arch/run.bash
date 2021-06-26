#!/bin/bash -e

if [[ $# -gt 1 ]]; then
  echo >&2 "usage: $(basename "$0") [setup]"
  exit 1
fi

if [[ $# -eq 1 ]] && [[ $1 != setup ]]; then
  echo >&2 "error: unrecognized playbook $1"
  exit 1
fi

if [[ $1 == setup ]]; then
  playbook=setup.yml
  mmode=setup
else
  playbook=arch.yml
  mmode=post
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
  --extra-vars mmode=$mmode \
  --extra-vars mtype=personal \
  $playbook

exit 0
