# usb

Customization on top of[archuseriso](https://github.com/laurent85v/archuseriso)
for a persistent live USB arch system.

On the host (arch) system run:

```shell
sudo aui-mkiso -p ansible,base-devel xfce
```

Insert the USB drive and note the disk number (and make sure that it isn't
mounted) then run:

```shell
sudo aui-mkinstall --encrypt --f2fs --username mario \
  ./out/aui-xfce-* /dev/sdX
```
