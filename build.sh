#!/bin/bash

# --- НАСТРОЙКИ АВТОРА ---
USER="Vjfgff"
HOST="Redwood-Lab"
COMPILER_PATH="$HOME/compiler/clang/bin"

export PATH="$COMPILER_PATH:$PATH"
export KBUILD_BUILD_USER="$USER"
export KBUILD_BUILD_HOST="$HOST"

# Цвета
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Проверка наличия конфига
if [ ! -f "out/.config" ]; then
    echo -e "\033[0;31mОШИБКА: Файл out/.config не найден! Сначала создай его.\033[0m"
    exit 1
fi

echo -e "${YELLOW}Выбери режим сборки:${NC}"
echo "1) Normal (SukiSU Only)"
echo "2) KPM (SukiSU + KPM/APatch Support)"
read -p "Твой выбор: " CHOICE

echo -e "${GREEN}--- 1. Переключаем флаги в конфиге ---${NC}"
if [ "$CHOICE" == "2" ]; then
    echo "Включаем KPM..."
    ./scripts/config --file out/.config \
        -e CONFIG_KPM \
        -e CONFIG_DEBUG_KERNEL \
        -e CONFIG_KALLSYMS \
        -e CONFIG_KALLSYMS_ALL \
        -d CONFIG_STRICT_KERNEL_RWX \
        -d CONFIG_STRICT_MODULE_RWX
else
    echo "Выключаем KPM..."
    ./scripts/config --file out/.config \
        -d CONFIG_KPM \
        -d CONFIG_KALLSYMS_ALL \
        -e CONFIG_STRICT_KERNEL_RWX \
        -e CONFIG_STRICT_MODULE_RWX
fi

echo -e "${GREEN}--- 2. Синхронизируем зависимости ---${NC}"
make O=out ARCH=arm64 LLVM=1 LLVM_IAS=1 olddefconfig

echo -e "${GREEN}--- 3. Фиксим код (iterate + Kbuild) ---${NC}"
# Фикс iterate_shared для 5.4
sed -i 's/\.iterate =/.iterate_shared =/g' drivers/kernelsu/file_wrapper.c 2>/dev/null
sed -i 's/f_op->iterate ?/f_op->iterate_shared ?/g' drivers/kernelsu/file_wrapper.c 2>/dev/null
sed -i 's/f_op->iterate(/f_op->iterate_shared(/g' drivers/kernelsu/file_wrapper.c 2>/dev/null

# Затыкаем проверку версии ReSukiSU
#sed -i 's/$(error You should integrate/$(warning Ignored: You should integrate/' drivers/kernelsu/Kbuild 2>/dev/null

echo -e "${GREEN}--- 4. ЗАПУСК БИЛДА ---${NC}"
make -j$(nproc --all) O=out ARCH=arm64 \
    CC=clang LLVM=1 LLVM_IAS=1 HOSTLD=ld.lld \
    CROSS_COMPILE=aarch64-linux-gnu- \
    CROSS_COMPILE_COMPAT=arm-linux-gnueabi- \
    KCFLAGS="-Wno-implicit-function-declaration -Wno-int-conversion -Wno-incompatible-pointer-types" \
    Image dtbs

if [ -f "out/arch/arm64/boot/Image" ]; then
    echo -e "${GREEN}ГОТОВО! Забирай Image из папки out/arch/arm64/boot/${NC}"
else
    echo -e "\033[0;31mОШИБКА СБОРКИ\033[0m"
fi
