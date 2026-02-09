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

./scripts/config --file out/.config \
  -e CONFIG_NO_HZ \
  -e CONFIG_NO_HZ_IDLE \
  -e CONFIG_HIGH_RES_TIMERS \
  -e CONFIG_CPU_IDLE \
  -e CONFIG_CPU_IDLE_GOV_MENU \
  -e CONFIG_PM \
  -e CONFIG_PM_SLEEP \
  -e CONFIG_SUSPEND \
  -e CONFIG_PM_WAKELOCKS \
  -e CONFIG_WQ_POWER_EFFICIENT_DEFAULT \
  -e CONFIG_HZ_300 \
  -d CONFIG_HZ_1000 \
  -e CONFIG_TCP_CONGESTION_BBR \
  -e CONFIG_DEFAULT_BBR \
  -e CONFIG_IOSCHED_KYBER \
  -e CONFIG_IOSCHED_SSG \
  -e CONFIG_ZRAM_LZ4_COMPRESS \
  -e CONFIG_RCU_LAZY \
  -e CONFIG_CC_OPTIMIZE_FOR_SIZE \
  -e CONFIG_KSU \
  -e CONFIG_KSU_MANUAL_HOOK


make O=out ARCH=arm64 LLVM=1 LLVM_IAS=1 olddefconfig

make O=out ARCH=arm64 LLVM=1 LLVM_IAS=1 -j$(nproc) Image dtbs
