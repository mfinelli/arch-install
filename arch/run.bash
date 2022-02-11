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

hn="$(hostnamectl --static)"
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
    wirelessregdom="$(yq eval '.wireless-regdom' $FINELLICTL_CONFIG)"
    timezone="$(yq eval '.timezone' $FINELLICTL_CONFIG)"
  fi
fi

if [[ -z $wirelessregdom ]]; then
  read -rp "What's the wireless regdom? (US) " wirelessregdom

  if [[ -z $wirelessregdom ]]; then
    wirelessregdom=US
  fi
fi

if [[ -z $timezone ]]; then
  if command -v tzselect > /dev/null 2>&1; then
    echo "Current timezone: $(timedatectl show -p Timezone)"
    timezone="$(tzselect)"
  else
    # we could also attempt a normal `read`
    timezone=America/New_York
  fi
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
    arch.yml --tags init

  # now we can run the main setup
  ansible-playbook \
    --extra-vars gcard=$gcard \
    --extra-vars multilib=true \
    --extra-vars mmode=$mmode \
    --extra-vars mtype=$mtype \
    --extra-vars wireless_regdom=$wirelessregdom \
    --extra-vars timezone=$timezone \
    arch.yml --tags setup
else
  ansible-playbook \
    --extra-vars gcard=$gcard \
    --extra-vars multilib=true \
    --extra-vars mmode=post \
    --extra-vars mtype=$mtype \
    --extra-vars wireless_regdom=$wirelessregdom \
    --extra-vars timezone=$timezone \
    arch.yml
fi

exit 0
