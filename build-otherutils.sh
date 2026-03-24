#!/usr/bin/env bash

if [ ! -d "nano" ]; then
    if [ ! -f "nano-8.7.1.tar.xz" ]; then
        wget https://nano-editor.org/dist/v8/nano-8.7.1.tar.xz
    fi
    tar -xvf nano-8.7.1.tar.xz
    mv nano-8.7.1 nano
fi
cd nano
CFLAGS=-static LDFLAGS=-static ./configure --prefix=$(pwd)/../boot-files/initramfs/usr --enable-static --disable-shared --disable-libmagic --enable-utf8
make -j $(nproc) CFLAGS=-static LDFLAGS=-static 
make install
cd ..
