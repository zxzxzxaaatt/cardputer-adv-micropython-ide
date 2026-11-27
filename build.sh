#!/bin/bash
# =============================================================================
# Cardputer ADV —— MicroPython IDE 固件构建脚本
# =============================================================================
set -o pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
MPY_DIR="$ROOT/micropython"
USER_MODULES="$ROOT/usermods/allmods/micropython.cmake"

if [ -z "$IDF_PATH" ]; then
  for c in "$HOME/esp/esp-idf" "/opt/esp/idf" "$HOME/esp-idf"; do
    [ -f "$c/tools/idf.py" ] && export IDF_PATH="$c" && break
  done
fi
if [ -z "$IDF_PATH" ] || [ ! -f "$IDF_PATH/tools/idf.py" ]; then
  echo "错误：找不到 ESP-IDF。请先安装 ESP-IDF v5.4.2 并设置 IDF_PATH。"
  exit 1
fi

export IDF_TOOLS_PATH="${IDF_TOOLS_PATH:-$HOME/.espressif}"

if [ -f "$IDF_PATH/export.sh" ]; then
  . "$IDF_PATH/export.sh" >/dev/null 2>&1 || true
fi

for bindir in "$IDF_TOOLS_PATH"/tools/xtensa-esp-elf/*/bin; do
  [ -x "$bindir/xtensa-esp32s3-elf-gcc" ] && export PATH="$bindir:$PATH" && break
done

if [ -z "$IDF_PYTHON_ENV_PATH" ]; then
  for d in "$IDF_TOOLS_PATH"/python_env/idf*_env; do
    [ -x "$d/bin/python" ] && export IDF_PYTHON_ENV_PATH="$d" && break
  done
fi
PY="${IDF_PYTHON_ENV_PATH:+$IDF_PYTHON_ENV_PATH/bin/}python"
command -v "$PY" >/dev/null 2>&1 || PY=python3

echo "IDF_PATH     = $IDF_PATH"
echo "MicroPython  = $MPY_DIR"
echo "USER_C_MODULES = $USER_MODULES"
echo "BOARD        = M5STACK_CARDPUTER_ADV (中文版)"

cd "$MPY_DIR/ports/esp32" || exit 1
"$PY" "$IDF_PATH/tools/idf.py" \
  -D MICROPY_BOARD=M5STACK_CARDPUTER_ADV \
  -D MICROPY_ROM_TEXT_COMPRESSION=OFF \
  -D USER_C_MODULES="$USER_MODULES" \
  build
