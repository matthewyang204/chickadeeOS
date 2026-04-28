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

if [ ! -d "micro" ]; then
    if [ ! -f "micro-2.0.15.zip" ]; then
        echo "Downloading micro..."
        wget https://github.com/micro-editor/micro/archive/refs/tags/v2.0.15.zip
    fi
    echo "Extracting micro..."
    unzip v2.0.15.zip
    mv micro-2.0.15 micro
fi
cd micro
echo "Compiling micro..."
CGO_ENABLED=0 go build -o micro -buildvcs=false ./cmd/micro
echo "Staging micro to destroot..."
cp micro ../boot-files/initramfs/usr/bin/
cd ..
