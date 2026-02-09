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
--enable ARCH_SUPPORTS_SHADOW_CALL_STACK \
--enable ARM64_LSE_ATOMICS \
--enable CC_HAS_KASAN_SW_TAGS \
--enable CC_HAVE_SHADOW_CALL_STACK \
--enable CC_HAVE_STACKPROTECTOR_SYSREG \
--enable CC_IS_CLANG \
--enable COMPAT_VDSO \
--enable GENERIC_COMPAT_VDSO \
--enable KSU_MANUAL_HOOK_AUTO_INITRC_HOOK \
--enable KSU_MANUAL_HOOK_AUTO_INPUT_HOOK \
--enable KSU_MANUAL_HOOK_AUTO_SETUID_HOOK \
--enable LD_IS_LLD \
--disable LTO_CLANG \
--set-val MSM_IDLE_STATS_BUCKET_COUNT 10 \
--set-val MSM_IDLE_STATS_BUCKET_SHIFT 2 \
--set-val MSM_IDLE_STATS_FIRST_BUCKET 62500 \
--set-val MSM_SUSPEND_STATS_FIRST_BUCKET 1000000000 \
--enable POLLY_CLANG \
--enable RELR \
--disable SHADOW_CALL_STACK \
--enable STACKPROTECTOR_PER_TASK \
--enable THUMB2_COMPAT_VDSO \
--enable TOOLS_SUPPORT_RELR \
--disable BUG \
--disable CC_OPTIMIZE_FOR_PERFORMANCE_O3 \
--enable CC_OPTIMIZE_FOR_SIZE \
--set-val CLANG_VERSION 180103 \
--disable CPU_FREQ_DEFAULT_GOV_PERFORMANCE \
--enable CPU_FREQ_DEFAULT_GOV_SCHEDUTIL \
--enable CPU_IDLE_GOV_MENU \
--set-val GCC_VERSION 0 \
--disable KALLSYMS \
--set-val KASAN_STACK 0 \
--enable KSU_MANUAL_HOOK \
--enable MQ_IOSCHED_KYBER \
--enable MSM_IDLE_STATS \
--disable PRINTK \
--disable QCOM_KGSL_IOCOHERENCY_DEFAULT \
--disable STACKTRACE \
--undefine BROKEN_GAS_INST \
--undefine CC_IS_GCC \
--undefine DEBUG_BUGVERBOSE \
--undefine DEBUG_SECTION_MISMATCH \
--undefine DYNAMIC_DEBUG \
--undefine DYNAMIC_DEBUG_CORE \
--undefine FORTIFY_SOURCE \
--undefine GENERIC_BUG \
--undefine GENERIC_BUG_RELATIVE_POINTERS \
--undefine KALLSYMS_BASE_RELATIVE \
--undefine LOG_BUF_SHIFT \
--undefine LOG_CPU_MAX_BUF_SHIFT \
--undefine LTO_GCC \
--undefine PLUGIN_HOSTCC \
--undefine PRINTK_CALLER \
--undefine PRINTK_NMI \
--undefine PRINTK_SAFE_LOG_BUF_SHIFT \
--undefine PRINTK_TIME \
--undefine SERIAL_FSL_LINFLEXUART


make O=out ARCH=arm64 LLVM=1 LLVM_IAS=1 olddefconfig

make O=out ARCH=arm64 LLVM=1 LLVM_IAS=1 -j$(nproc) Image dtbs
