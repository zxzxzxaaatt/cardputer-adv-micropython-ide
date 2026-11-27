# Cardputer ADV · MicroPython IDE 固件

M5Stack Cardputer ADV（ESP32-S3）上的一套中文图形 IDE，跑在 MicroPython 上：编辑器、语法检查、拼音输入法、SD 卡日志与断电记忆，编译产物是一个可直接烧录的单 app 固件。

> 当前发布版本 **v5**（2026-11-26）

## 功能

### 编辑与代码
- 语法高亮：按行对关键字 / 字符串 / 注释着色，纯中文行按整行渲染，不会花屏
- 自动补全：变量、成员、常用库成员（`_CompleteAtLine`）
- 语法检查 9 类：缺少冒号、缺少逗号、缺少空格、未声明变量、括号引号不匹配、缩进混用、全角标点、条件里用了 `=`、关键字拼写可疑
- 全文级检查：括号未闭合、三引号未闭合、`:` 后未缩进（空 def / 空 if / 空 for）
- 问题面板：分类计数、逐条跳转，打开文件即整篇检查一次，左下角常驻“问题 N”

### 中文
- 16×16 点阵字库 **8716 字**（GB2312 全集 + 《通用规范汉字表》补充），输入法能打出来的字都有字形
- 拼音输入法：音节 / 词组候选，Tab 滚候选、Esc 取消、退格删拼音、回车上屏
- 词频学习：同一个字上屏满 3 次即排到该音节候选第一位（像手机输入法）

### 布局与面板
- 侧栏开关（开=全分隔模式，关=禅模式）、终端半屏 / 全屏
- 命令面板：8 套主题、亮度档位、REPL、模拟终端、WLAN、休眠 / 深睡

### 持久化（全部在 SD 卡上，不占根目录）
```
/sd/M5ADV_IDE_9F3C7A2B/
├── logs/ide_YYYYMMDD.log     # 启动 / 打开 / 保存 / 主题 / 亮度 / 布局
├── state.txt                # 上次文件、主题、亮度、布局、终端模式、光标行:列
└── imefreq.txt              # 输入法词频
```
开机第一件事就是建目录写日志、读 `state.txt`，**不等按键**直接回到上次的界面（含光标位置、问题面板展开状态）。

## 固件（v5）

| 文件 | 烧录地址 | 大小 | SHA256 |
|---|---|---|---|
| `CardputerADV_v5_app_0x10000.bin` | `0x10000` | 2,037,168 B | `f531872dff43670f58e47898fc80517af9f4b2e87589effe1fc51e04b1ea8e99` |
| `bootloader_0x0.bin` | `0x0` | 19,072 B | `a5c3b7df0ef1338b8bc4d00d248263083e3a3f0d42dc88ae769a0e960dbee643` |
| `partition-table_0x8000.bin` | `0x8000` | 3,072 B | `1ec0da11b8644aff5e71bbfdc23c9e1fe896b895b850956123766a653c350d7b` |

下载：
- v5 固件包（含烧录脚本）：<https://aka.doubaocdn.com/s/QSzN8PesG5>
- v5 app 单独文件：<https://aka.doubaocdn.com/s/qrl39c9GCu>

> GitHub 的内容接口只接受文本，2 MB 级二进制没法经 API 写进仓库，所以二进制放在上面的直链，`firmware/` 目录里是烧录脚本和校验值。想把二进制也纳入仓库，用文末的 `git push` 流程即可。

### 烧录
```bash
./firmware/flash.sh /dev/ttyACM0      # Windows: firmware\flash.bat COM3
```
或手动：
```bash
esptool.py --chip esp32s3 -p COMn -b 460800 --before default_reset --after hard_reset \
  write_flash --flash_mode dio --flash_freq 80m --flash_size 16MB \
  0x0 bootloader_0x0.bin 0x8000 partition-table_0x8000.bin 0x10000 CardputerADV_v5_app_0x10000.bin
```
只更新应用时，烧 `0x10000` 一个文件就够，内部 vfs 里的文件不会被清。

## 编译

- MicroPython 1.29 源码树（ESP32 端口）
- ESP-IDF v5.4.2，`idf.py` 在 PATH 里
- 板级目录 `micropython/ports/esp32/boards/M5STACK_CARDPUTER_ADV`（见 `board/`）
- 用户 C 模块：`usermods/allmods/micropython.cmake`（`st7789_mpy`、`nekoedit` 等）

```bash
IDF_PATH=/path/to/esp-idf ./build.sh
```
`build.sh` 实际执行：
```bash
idf.py -D MICROPY_BOARD=M5STACK_CARDPUTER_ADV \
       -D MICROPY_ROM_TEXT_COMPRESSION=OFF \
       -D USER_C_MODULES=<root>/usermods/allmods/micropython.cmake build
```
产物：`micropython/ports/esp32/build/micropython.bin`（烧 `0x10000`）。

> 注意：`MICROPY_ROM_TEXT_COMPRESSION` 必须是 `OFF`。CMake 里如果被写成带引号的字符串，会让 `MP_COMPRESSED_ROM_TEXT` 未定义，`qstr.i.last` 预处理阶段直接卡死。

应用层 Python 都放在 `application/python_cn/`，构建前同步到 `micropython/ports/esp32/modules/`（`manifest.py` 里 freeze 的是这个目录）。

## 分区布局
```
nvs       0x009000   16 KB
phy_init  0x00f000    4 KB
factory   0x010000    3 MB    <- app 1.94 MB
vfs       0x310000  12.9 MB
```

## 已知限制
- 三引号闭合按文本奇偶判断，`"""` 写在注释里可能误报一条
- 全文检查上限 400 行
- 词频只记单字，不记词组
- 日志按天一个文件，没有轮转

## 把完整源码与二进制推上来

本仓库目前只放了文档、烧录脚本和校验值（受 GitHub 文本接口限制）。要在本地补全整棵树：

```bash
git clone https://github.com/zxzxzxaaatt/cardputer-adv-micropython-ide.git
cd cardputer-adv-micropython-ide
cp -r /path/to/CardputerADV_MP3_Source_fixed/{application,micropython/ports/esp32/boards/M5STACK_CARDPUTER_ADV,build.sh} .
cp /path/to/fw_v5/*.bin firmware/
git add -A && git commit -m "add full source tree and v5 firmware" && git push
```

## 许可证
MIT，见 [LICENSE](LICENSE)。
