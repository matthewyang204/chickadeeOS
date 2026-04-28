#!/bin/sh
# Copyright 2024 (c) Nathanne Isip
# chickadeeOS (https://github.com/matthewyang204/chickadeeOS)

qemu-system-x86_64 \
    -m 768M \
    -vga std \
    -cdrom chickadee_os.iso
