#!/usr/bin/env bash

if [ ! -d "nano"]; then
    if [ ! -f "nano-8.7.1.tar.xz" ]; then
        wget https://nano-editor.org/dist/v8/nano-8.7.1.tar.xz
    fi
    tar -xvf nano-8.7.1.tar.xz
    mv nano-8.7.1 nano
fi
cd nano
./configure --prefix=../boot-files/initramfs/usr --enable-static --disable-shared --disable-libmagic --enable-utf8
make -j $(nproc)
make install
cd ..
