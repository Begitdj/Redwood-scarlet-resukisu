#!/bin/bash
echo "--- Обновление ReSukiSU ---"
if [ -d "drivers/kernelsu" ]; then
    rm -rf drivers/kernelsu KernelSU
    curl -LSs "https://raw.githubusercontent.com/ReSukiSU/ReSukiSU/main/kernel/setup.sh" | bash
    echo "Готово. Код обновлен."
else
    echo "Ошибка: папка drivers/kernelsu не найдена!"
fi
