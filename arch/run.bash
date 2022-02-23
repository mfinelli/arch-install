#!/bin/bash -e

if [[ $# -gt 1 ]]; then
  echo >&2 "usage: $(basename "$0") [setup]"
  exit 1
fi

if [[ $# -eq 1 ]] && [[ $1 != setup ]]; then
  echo >&2 "error: unrecognized playbook $1"
  exit 1
fi

FINELLICTL_CONFIG=/etc/finelli/arch-install.yml

# https://stackoverflow.com/a/14367368
array_contains() {
  local haystack="$1[@]"
  local needle="$2"
  local found=1

  for element in "${!haystack}"; do
    if [[ $element == "$needle" ]]; then
      found=0
      break
    fi
  done

  return $found
}

PERSONAL_MACHINES=(stig)
SERVER_MACHINES=(cdev.finelli.dev)
WORK_MACHINES=(easy)
MEDIA_MACHINES=()

if lspci | grep VGA | grep -qi amd; then
  gcard=amd
elif lspci | grep VGA | grep -qi intel; then
  gcard=intel
else
  gcard=none
fi

hn="$(cat /etc/hostname)"
if array_contains PERSONAL_MACHINES "$hn"; then
  mtype=personal
elif array_contains SERVER_MACHINES "$hn"; then
  mtype=server
elif array_contains WORK_MACHINES "$hn"; then
  mtype=work
else
  mtype=media
fi

if [[ -f /etc/finelli/arch-install.yml ]]; then
  if command -v yq > /dev/null 2>&1; then
    syslang="$(yq eval '.language' $FINELLICTL_CONFIG)"
    wirelessregdom="$(yq eval '.wireless-regdom' $FINELLICTL_CONFIG)"
    timezone="$(yq eval '.timezone' $FINELLICTL_CONFIG)"
  fi
fi

if [[ -z $syslang ]]; then
  syslang=en_US
fi

if [[ -z $wirelessregdom ]]; then
  wirelessregdom=US
fi

if [[ -z $timezone ]]; then
  timezone=UTC
fi

# this shouldn't ever be run as root, but just in case prompt the user for the
# sudo rule to create
if [[ $(id -u) -eq 0 ]]; then
  read -rp "What username should we give passwordless-sudo? " sudouser
else
  sudouser="$(whoami)"
fi


# prompt for sudo password right away
sudo echo -n

ansible-galaxy install -r requirements.yml

if [[ $1 == setup ]]; then
  mmode=setup

  # run once first just to setup custom facts
  ansible-playbook \
    --extra-vars gcard=$gcard \
    --extra-vars multilib=true \
    --extra-vars mmode=$mmode \
    --extra-vars mtype=$mtype \
    --extra-vars wireless_regdom=$wirelessregdom \
    --extra-vars timezone=$timezone \
    --extra-vars system_lang=$syslang \
    --extra-vers sudouser=$sudouser \
    arch.yml --tags init

  # now we can run the main setup
  ansible-playbook \
    --extra-vars gcard=$gcard \
    --extra-vars multilib=true \
    --extra-vars mmode=$mmode \
    --extra-vars mtype=$mtype \
    --extra-vars wireless_regdom=$wirelessregdom \
    --extra-vars timezone=$timezone \
    --extra-vars system_lang=$syslang \
    --extra-vers sudouser=$sudouser \
    arch.yml --tags setup
else
  ansible-playbook \
    --extra-vars gcard=$gcard \
    --extra-vars multilib=true \
    --extra-vars mmode=post \
    --extra-vars mtype=$mtype \
    --extra-vars wireless_regdom=$wirelessregdom \
    --extra-vars timezone=$timezone \
    --extra-vars system_lang=$syslang \
    --extra-vers sudouser=$sudouser \
    arch.yml
fi

exit 0
