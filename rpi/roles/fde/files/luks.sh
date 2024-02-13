#!/bin/sh -e

# Ansible managed

# Copy resize2fs, fdisk, and other kernel modules into initramfs image.
# https://github.com/Robpol86/robpol86.com/blob/master/docs/_static/resize2fs.sh
# Save as (chmod +x): /etc/initramfs-tools/hooks/resize2fs

PREREQS=""
case $1 in
  prereqs)
    echo "${PREREQS}"
    exit 0
    ;;
esac

# shellcheck source=/dev/null
. /usr/share/initramfs-tools/hook-functions

copy_exec /sbin/e2fsck /sbin
copy_exec /sbin/resize2fs /sbin
copy_exec /sbin/fdisk /sbin
