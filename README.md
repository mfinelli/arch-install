# Arch Install

I have several machines that I need to install Arch Linux, this should automate
package installation.

## Bootstrap

### Step 1: Ensure we're booted in UEFI mode

```shell
efivar -l
```

### Step 2: Establish an internet connection

Get the device names:

```shell
iw dev
```

Connect to a network:

```shell
wifi-menu wlp1s0
```

Ensure the internet is working

```shell
ping -c 5 google.com
```
