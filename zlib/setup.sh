#!/bin/bash

export CAFFEINE=~/projects/caffeine
export VCPKG=~/projects/vcpkg
export INSTALL=~/fydp/install

export VCPKG_OVERLAY_TRIPLETS="$CAFFEINE/scripts/vcpkg"
export VCPKG_ROOT="$VCPKG"
export LLVM_CC_NAME=clang-12
export LLVM_CXX_NAME=clang++-12

rm -rf build
mkdir -p build
cd build
CC=gclang CXX=gclang++ cmake .. \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
  "-DCMAKE_INSTALL_PREFIX=$INSTALL" \
  "-DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake" \
  -DVCPKG_TARGET_TRIPLET=x64-linux-gllvm
