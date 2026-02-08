#!/bin/bash

set -e

USER="Begitdj"
HOST="GithubAction"
COMPILER_PATH="$HOME/compiler/clang/bin"

export PATH="$COMPILER_PATH:$PATH"
export KBUILD_BUILD_USER="$USER"
export KBUILD_BUILD_HOST="$HOST"

rm -rf out
mkdir -p out

make O=out ARCH=arm64 LLVM=1 LLVM_IAS=1 vendor/xiaomi-qgki_defconfig vendor/redwood.config

# 3. Настройка KSU
./scripts/config --file out/.config \
    -e CONFIG_KSU \
    -e CONFIG_KSU_MANUAL_HOOK


make O=out ARCH=arm64 LLVM=1 LLVM_IAS=1 olddefconfig

make O=out ARCH=arm64 LLVM=1 LLVM_IAS=1 -j$(nproc) Image dtbs
