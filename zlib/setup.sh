#!/bin/bash

set -euo pipefail

export CAFFEINE=~/caffeine
export VCPKG=~/vcpkg
export INSTALL=~/install

export VCPKG_OVERLAY_TRIPLETS="$INSTALL/share/vcpkg"
export VCPKG_ROOT="$VCPKG"
export LLVM_CC_NAME=clang-13
export LLVM_CXX_NAME=clang++-13

rm -rf build
mkdir -p build
cd build
CC=gclang CXX=gclang++ cmake .. -GNinja \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
  "-DCMAKE_INSTALL_PREFIX=$INSTALL" \
  "-DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake" \
  -DVCPKG_TARGET_TRIPLET=x64-linux-gllvm
