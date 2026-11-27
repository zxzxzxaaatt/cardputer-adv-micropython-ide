# 编译指南

## 依赖

| 项 | 版本 / 位置 |
|---|---|
| MicroPython | 1.29 源码树（ESP32 端口），放到 `micropython/` |
| ESP-IDF | v5.4.2，`IDF_PATH` 指向它 |
| 工具链 | `~/.espressif/tools/xtensa-esp-elf/esp-14.2.0_*/bin` |
| 用户 C 模块 | `usermods/allmods/micropython.cmake`（`st7789_mpy`、`nekoedit`、`berkeley-db` 等） |

## 目录结构（相对仓库根）

```
application/python_cn/            应用层 Python（约 23 个模块）
micropython/                      MicroPython 1.29 源码
micropython/ports/esp32/boards/M5STACK_CARDPUTER_ADV/   板级配置（board/ 目录）
micropython/ports/esp32/modules/  真正被 freeze 的目录（构建前需同步）
usermods/allmods/                 用户 C 模块
build.sh
```

## 同步应用层

`manifest.py` freeze 的是 `micropython/ports/esp32/modules`，**不是** `application/python_cn`，直接改后者不会进固件：

```bash
./scripts/sync_modules.sh
```

## 编译

```bash
IDF_PATH=/path/to/esp-idf ./build.sh
```

等价手打：

```bash
cd micropython/ports/esp32
idf.py -D MICROPY_BOARD=M5STACK_CARDPUTER_ADV \
       -D MICROPY_ROM_TEXT_COMPRESSION=OFF \
       -D USER_C_MODULES=<root>/usermods/allmods/micropython.cmake build
```

产物：`micropython/ports/esp32/build/micropython.bin`（烧 `0x10000`）、`bootloader/bootloader.bin`、`partition_table/partition-table.bin`。

## 踩过的坑

1. **ROM_TEXT_COMPRESSION 必须是 OFF**。如果 CMake 收到带引号的字符串（例如 `"(1)"`），编译命令行会变成 `-DMICROPY_ROM_TEXT_COMPRESSION="(1)"`，`#if MICROPY_ROM_TEXT_COMPRESSION` 求值为真，`MP_COMPRESSED_ROM_TEXT` 就需要 `genhdr/compressed.data.h`，qstr 预处理阶段直接报错或卡死。改完 CMake 后建议删 `build/` 重配。
2. **qstr 阶段很吃文件系统性能**。`qstr.i.last` 要把全部源文件过一遍预处理器；在 FUSE / 网络盘上单文件能拖到十几秒，265 个文件足以卡十几分钟。放本地磁盘编译即可。
3. **冻结模块没更新**。改了 `application/python_cn` 却忘同步到 `modules/`，固件里还是旧代码。
4. **app 大小**。factory 分区 3 MB，当前 app 约 1.94 MB，剩约 1 MB；再加字库要留意。
