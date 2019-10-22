#!/bin/bash -e

if [[ $(id -u) -ne 0 ]]; then
  echo >&2 "must run as root!"
  exit 1
fi

yum install python3{,-pip}

exit 0
