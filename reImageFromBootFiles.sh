#!/usr/bin/env bash

printf "Deleting old image..."
rm -rf chickadee_os.iso
echo "done"

cd boot-files/initramfs && find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../../iso/boot/initramfs.cpio.gz && cd ../../
grub-mkrescue -o chickadee_os.iso iso/

echo "Bootable live ISO image recreated successfully as chickadee_os.iso"
