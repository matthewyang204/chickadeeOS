#!/bin/sh
# Copyright 2024 (c) Nathanne Isip
# chickadeeOS (https://github.com/nthnn/chickadeeOS)

qemu-system-x86_64 \
    -m 512M \
    -vga std \
    -cdrom chickadee_os.iso
