#!/bin/bash -e

if [[ $(id -u) -ne 0 ]]; then
  echo >&2 "must run as root!"
  exit 1
fi

yum install python{,-pip}
pip install ansible==2.8.6

exit 0
