#!/bin/sh
# Copyright 2024 (c) Nathanne Isip
# NateOS (https://github.com/nthnn/NateOS)

qemu-system-x86_64 \
    -m 512M \
    -vga std \
    -cdrom chickadee_os.iso
