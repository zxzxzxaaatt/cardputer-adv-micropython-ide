#!/bin/bash
# 把应用层 Python 同步到构建真正 freeze 的目录，再交给 build.sh。
# 用法：./scripts/sync_modules.sh && ./build.sh
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/application/python_cn"
DST="$ROOT/micropython/ports/esp32/modules"

[ -d "$SRC" ] || { echo "缺少 $SRC"; exit 1; }
[ -d "$DST" ] || { echo "缺少 $DST（先 clone micropython 1.29 到 $ROOT/micropython）"; exit 1; }

for f in "$SRC"/*.py; do
  case "$f" in
    *.orig) continue ;;
  esac
  cp -f "$f" "$DST/"
  echo "sync $(basename "$f")"
done
