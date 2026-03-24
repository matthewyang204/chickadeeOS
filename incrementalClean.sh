#!/usr/bin/env bash

printf "Deleting just enough to start a rebuild..."
rm -rf \
    boot-files \
    iso \
    chickadee_os.iso
echo "done"
