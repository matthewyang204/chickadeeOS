#!/bin/sh
# Copyright 2024 (c) Nathanne Isip
# Copyright 2026 (c) Matthew Yang (杨家明)
# chickadeeOS (https://github.com/matthewyang204/chickadeeOS)

# Core requirements
apt install -y     \
    bzip2          \
    git            \
    make           \
    gcc            \
    libncurses-dev \
    flex           \
    bison          \
    bc             \
    cpio           \
    libelf-dev     \
    libssl-dev     \
    cargo          \
    musl-tools     \
    xorriso

# Install ncurses
apt install -y \
    libncurses-dev \
    libncurses6 \
    libncursesw6 \
    ncurses-base \
    ncurses-bin \
    ncurses-term

bash ./incrementalClean.sh

if [ ! -d "minos-static" ]; then
    git clone --depth 1 https://github.com/minos-org/minos-static.git
fi

# if ! command -v rustup &> /dev/null; then
    # curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    # source $HOME/.cargo/env
# fi

if ! rustup target list | grep -q "x86_64-unknown-linux-musl (installed)"; then
    rustup target add x86_64-unknown-linux-musl
fi

mkdir -p boot-files iso iso/boot iso/boot/grub

if [ ! -d "linux" ]; then
    if [ ! -f "linux-6.19.9.tar.xz" ]; then
        wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.19.9.tar.xz
    fi
    tar -xvf linux-6.19.9.tar.xz
    mv linux-6.19.9 linux
fi

cd linux
if [ ! -f "arch/x86/boot/bzImage" ]; then
   make defconfig
   make -j $(nproc)
fi
cp arch/x86/boot/bzImage ../iso/boot
cd ..

if [ ! -d "busybox" ]; then
    if [ ! -f "busybox-1.37.0.tar.bz2" ]; then
        wget https://busybox.net/downloads/busybox-1.37.0.tar.bz2
    fi
    tar -xvf busybox-1.37.0.tar.bz2
    mv busybox-1.37.0 busybox
fi

cd busybox
make defconfig
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
sed -i 's/CONFIG_TC=y/CONFIG_TC=n/' .config
make -j $(nproc)
mkdir -p ../boot-files/initramfs
make CONFIG_PREFIX=../boot-files/initramfs install
cd ..

if [ ! -d "broot" ]; then
    git clone --depth 1 https://github.com/Canop/broot.git
fi

cd broot
cargo build --target=x86_64-unknown-linux-musl --release
cp ./target/x86_64-unknown-linux-musl/release/broot ../boot-files/initramfs/bin
cd ..

if [ ! -d "loc" ]; then
    git clone --depth 1 https://github.com/cgag/loc.git
fi

cd loc
cargo build --target=x86_64-unknown-linux-musl --release
cp ./target/x86_64-unknown-linux-musl/release/loc ../boot-files/initramfs/bin/
cd ..

if [ ! -d "bottom" ]; then
    git clone --depth 1 https://github.com/ClementTsang/bottom.git
fi

cd bottom
cargo build --target=x86_64-unknown-linux-musl --release
cp ./target/x86_64-unknown-linux-musl/release/btm ../boot-files/initramfs/bin/
cd ..

if [ ! -d "hex" ]; then
    git clone --depth 1 https://github.com/sitkevij/hex.git
fi

cd hex
cargo build --target=x86_64-unknown-linux-musl --release
cp ./target/x86_64-unknown-linux-musl/release/hx ../boot-files/initramfs/bin/
cd ..

if [ ! -d "curl" ]; then
    ./minos-static/static-get -c
    ./minos-static/static-get -v -x curl
fi
chmod +x curl/bin/curl
cp -r curl/* boot-files/initramfs

if [ ! -d "gcc-4.6.1-2" ]; then
    ./minos-static/static-get -c
    ./minos-static/static-get -v -x gcc
fi
cp -r gcc-4.6.1-2/* boot-files/initramfs

if [ ! -d "python3.2-static-raw.githubusercontent.com" ]; then
    ./minos-static/static-get -c
    ./minos-static/static-get -v -x python3.2
fi
cp python3.2-static-raw.githubusercontent.com/python3.2-static boot-files/initramfs/bin/python3
chmod +x boot-files/initramfs/bin/python3

if [ ! -d "opt-nodejs-0.8.18-1" ]; then
    ./minos-static/static-get -c
    ./minos-static/static-get -v -x opt-nodejs-0.8.18-1
fi
cp -r opt-nodejs-0.8.18-1/* boot-files/initramfs/
chmod +x boot-files/initramfs/opt/nodejs/bin/*

if [ ! -d "openssl-1.0.1t-1" ]; then
    ./minos-static/static-get -c
    ./minos-static/static-get -v -x openssl-1.0.1t-1
fi
chmod +x openssl-1.0.1t-1/usr/bin/openssl
cp -r openssl-1.0.1t-1/* boot-files/initramfs/

cp internals/netconf boot-files/initramfs/bin/netconf
chmod +x boot-files/initramfs/bin/netconf
cd boot-files/initramfs

wget -O bin/pfetch https://raw.githubusercontent.com/dylanaraps/pfetch/master/pfetch
chmod +x bin/pfetch

# Build other utilities that are useful
cd ../..
sh ./build-otherutils.sh
cd -

mkdir -p etc dev man proc sys tmp
mkdir -p etc/init.d
mkdir -p usr/share/terminfo/l

cp -r ../../internals/etc/* etc/
cp -r ../../internals/sbin/* sbin/
tic ../../internals/linux.ti -o usr/share/terminfo/l/linux
ln -s etc/init.d/rcS init
chmod +x etc/init.d/rcS init
chmod +x sbin/*

rm linuxrc
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../../iso/boot/initramfs.cpio.gz
cd ../..
cp internals/grub.cfg iso/boot/grub
cp -r iso/boot boot-files/initramfs/
rm iso/boot/initramfs.cpio.gz
cd boot-files/initramfs && find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../../iso/boot/initramfs.cpio.gz && cd ../../
grub-mkrescue -o chickadee_os.iso iso/

echo "Bootable live ISO image created successfully as chickadee_os.iso"
