#!/bin/bash -e

if [[ $# -ne 0 ]]; then
  echo >&2 "usage: $(basename "$0")"
  exit 1
fi

hn="$(cat /etc/hostname)"
# declare -a fde_enabled_hosts=(homepi parkpi raipi testpi)
declare -a fde_enabled_hosts=(homepi raipi testpi tvpi workpi)
declare -a tailscale_exit_nodes=(parkpi raipi)

declare -A wregdom_hosts
wregdom_hosts[homepi]=IT
wregdom_hosts[parkpi]=US
wregdom_hosts[raipi]=IT
wregdom_hosts[testpi]=US
wregdom_hosts[tvpi]=IT
wregdom_hosts[workpi]=IT

# https://unix.stackexchange.com/a/177589
declare -A fde_enabled_host
for host in "${fde_enabled_hosts[@]}"; do fde_enabled_host[$host]=1; done
declare -A tailscale_exit_node
for host in "${tailscale_exit_nodes[@]}"; do tailscale_exit_node[$host]=1; done

if [[ -n ${fde_enabled_host[$hn]} ]]; then
  fde=true
else
  fde=false
fi

if [[ -n ${tailscale_exit_node[$hn]} ]]; then
  tailscale_exit_node=true
else
  tailscale_exit_node=false
fi

ansible-playbook --inventory ../localhost \
  --extra-vars fde=$fde \
  --extra-vars tailscale_exit_node=$tailscale_exit_node \
  --extra-vars whoami="$(whoami)" \
  --extra-vars wregdom_country="${wregdom_hosts[$hn]}" \
  rpi.yml

exit 0
