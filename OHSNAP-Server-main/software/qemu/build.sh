#!/bin/sh

SRCDIR="$(cd `dirname $0`; pwd)"

# create build directory
mkdir -p "${SRCDIR}"/build
cd "${SRCDIR}"/build

# compile qemu
mkdir -p qemu
cd qemu
if [ ! -f Makefile ]
then
  ${SRCDIR}/external/qemu/configure --target-list=arm-softmmu --meson=${SRCDIR}/external/meson/meson.py
fi
make -j20
cd ..

# create flash memory image
rm -rf flash.img
touch flash.img
truncate -s 32M flash.img
dd if=${SRCDIR}/boot/u-boot-spl.bin of=flash.img conv=notrunc oflag=seek_bytes seek=0K     2>/dev/null
dd if=${SRCDIR}/boot/u-boot-env.bin of=flash.img conv=notrunc oflag=seek_bytes seek=512K   2>/dev/null
dd if=${SRCDIR}/boot/u-boot.bin     of=flash.img conv=notrunc oflag=seek_bytes seek=1024K  2>/dev/null
dd if=${SRCDIR}/boot/980uimage      of=flash.img conv=notrunc oflag=seek_bytes seek=2048K  2>/dev/null

# echo heading
echo ''
echo '+------------------------------------------------------------+'
echo '|                                                            |'
echo '|                OHSNAP QEMU-BASED EMULATOR                  |'
echo '|                                                            |'
echo '+------------------------------------------------------------+'

# run QEMU
qemu/qemu-system-arm -s -M nuc980-soc -m 64M -bios flash.img -serial stdio -monitor none -nographic

