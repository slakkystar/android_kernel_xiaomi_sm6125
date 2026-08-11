#!/bin/bash
set -e

# Parsing command line arguments
HIDE_WARNINGS=false

while getopts "w" opt; do
  case ${opt} in
    w )
      HIDE_WARNINGS=true
      ;;
    \? )
      echo "Using: $0 [-w]"
      exit 1
      ;;
  esac
done

# If the -w flag is passed, we disable warnings via KCFLAGS
if [ "$HIDE_WARNINGS" = true ]; then
    export KCFLAGS="-w"
fi

# some paths
KERNELDIR=$(pwd)
CLANG_DIR=$HOME/toolchains/clang-r383902b1
DEFCONFIG="vendor/ginkgo-perf_defconfig"
TARGETS="Image.gz-dtb dtbo.img dtb"

# clang install
if [ ! -d "$CLANG_DIR" ]; then
    echo "Clang not found! Downloading..."
    git clone --depth=1 -b clang-r383902b1 https://github.com/slakkystar/clang-r416183b.git $CLANG_DIR
    cd $KERNELDIR
fi

# some exports
export PATH=$CLANG_DIR/bin:$PATH
export ARCH=arm64
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-gnu-
export KBUILD_BUILD_USER=builder
export KBUILD_BUILD_HOST=pangu-build-component-system
export KBUILD_BUILD_VERSION=1
export LLVM_IAS=1
export CROSS_COMPILE_ARM32=arm-linux-androideabi-
export LLVM=1

# make .config
make O=out \
  CC=clang \
  LD=ld.lld \
  AR=llvm-ar \
  NM=llvm-nm \
  OBJCOPY=llvm-objcopy \
  OBJDUMP=llvm-objdump \
  STRIP=llvm-strip \
  $DEFCONFIG

# kernel build
make -j$(nproc --all) O=out \
    CC=clang \
    LD=ld.lld \
    AR=llvm-ar \
    NM=llvm-nm \
    OBJCOPY=llvm-objcopy \
    OBJDUMP=llvm-objdump \
    STRIP=llvm-strip \
    READELF=llvm-readelf \
    CLANG_TRIPLE=aarch64-linux-gnu- \
    $TARGETS

if [ -f "out/arch/arm64/boot/Image.gz-dtb" ]; then
    echo "Done! Image in out/arch/arm64/boot/"
else
    echo "Build error! Check the compilation logs."
fi