# Cardputer ADV · MicroPython IDE 固件

M5Stack Cardputer ADV（ESP32-S3）上的一套中文图形 IDE，跑在 MicroPython 1.29 上：编辑器、语法检查、拼音输入法词频学习、SD 卡日志与断电还原，产物是一个可直接烧录的单 app 固件。

> 当前版本 **v5**（2026-11-26）· [English](README_EN.md)

## 功能

### 编辑与代码
- 语法高亮：按行对关键字 / 字符串 / 注释着色，纯中文行整行渲染
- 自动补全：变量、成员、常用库成员
- 语法检查 9 类：缺少冒号、缺少逗号、缺少空格、未声明变量、括号引号不匹配、缩进混用、全角标点、条件里用了 `=`、关键字拼写可疑
- 全文级检查：括号未闭合、三引号未闭合、`:` 后未缩进（空 def / 空 if / 空 for）
- 问题面板：分类计数 + 逐条跳转；打开文件即整篇检查，左下角常驻“问题 N”

### 中文
- 16×16 点阵字库 **8716 字**（GB2312 全集 + 《通用规范汉字表》补充）
- 拼音输入法：音节 / 词组候选，Tab 滚候选、Esc 取消、退格删拼音、回车上屏
- 词频学习：同一字上屏满 3 次即排到该音节候选第一位

### 布局与面板
- 侧栏开关（开=全分隔，关=禅模式）、终端半屏 / 全屏
- 命令面板：8 套主题、亮度、REPL、模拟终端、WLAN、休眠 / 深睡

### 持久化（不占 SD 根目录）
```
/sd/M5ADV_IDE_9F3C7A2B/
├── logs/ide_YYYYMMDD.log     # boot / open / save / theme / bright / layout
├── state.txt                # 文件、主题、亮度、布局、终端、光标 pos=行,列
└── imefreq.txt              # 输入法词频
```
开机第一件事建目录写日志、读 `state.txt`，**不等按键**回到上次界面（含光标位置与问题面板状态）。

## 固件（v5）

| 文件 | 烧录地址 | 大小 | SHA256 |
|---|---|---|---|
| `CardputerADV_v5_app_0x10000.bin` | `0x10000` | 2,037,168 B | `f531872d…bee643` |
| `bootloader_0x0.bin` | `0x0` | 19,072 B | `a5c3b7df…dbee643` |
| `partition-table_0x8000.bin` | `0x8000` | 3,072 B | `1ec0da11…350d7b` |

下载：固件包 <https://aka.doubaocdn.com/s/QSzN8PesG5> · 单个 app <https://aka.doubaocdn.com/s/qrl39c9GCu>

> 二进制未入库：GitHub 内容接口只接受文本。`firmware/` 里有烧录脚本与校验值，完整推送方式见文末。

### 烧录
```bash
./firmware/flash.sh /dev/ttyACM0      # Windows: firmware\flash.bat COM3
```
只更新应用时烧 `0x10000` 一个文件，内部 vfs 不会被清。

## 编译

```bash
./scripts/sync_modules.sh                 # application/python_cn -> ports/esp32/modules
IDF_PATH=/path/to/esp-idf ./build.sh
```

需要 MicroPython 1.29 源码树、ESP-IDF v5.4.2、`usermods/allmods/micropython.cmake`。
`MICROPY_ROM_TEXT_COMPRESSION` 必须是 `OFF`，否则 qstr 预处理会卡死，详见 [docs/build.md](docs/build.md)。

## 分区布局
```
nvs       0x009000   16 KB
phy_init  0x00f000    4 KB
factory   0x010000    3 MB    <- app 1.94 MB
vfs       0x310000  12.9 MB
```

## 仓库结构

```
README.md / README_EN.md
CHANGELOG.md
build.sh
board/          板级配置（board.json / manifest.py / mpconfigboard.* / partitions.csv / sdkconfig.board）
docs/           编译、硬件、语法检查、SD 状态
firmware/       烧录脚本与 SHA256SUMS
scripts/        sync_modules.sh
src/            adv_store.py（SD 状态 / 日志 / 词频模块）
```

其余模块（`ide.py`、`Editor.py`、`ime.py`、`shell.py`、`Text.py`、`UI.py`、`dev.py`、`cjkfont.py`、`pydata.py` 等）在固件包与源码包中分发，推送方式见文末。

## 已知限制
- 三引号闭合按文本奇偶判断，`"""` 写在注释里可能误报
- 全文检查上限 400 行
- 词频只记单字
- 日志按天一个文件，无轮转

## 把完整源码与二进制推上来

```bash
git clone https://github.com/zxzxzxaaatt/cardputer-adv-micropython-ide.git
cd cardputer-adv-micropython-ide
cp -r /path/to/CardputerADV_MP3_Source_fixed/{application,build.sh} .
cp -r /path/to/CardputerADV_MP3_Source_fixed/micropython/ports/esp32/boards/M5STACK_CARDPUTER_ADV board
cp /path/to/fw_v5/*.bin firmware/
git add -A && git commit -m "add full source tree and v5 firmware" && git push
```

`.gitignore` 已排除 `build/`、`micropython/`、`usermods/`、`*.orig`。

## 许可证
MIT，见 [LICENSE](LICENSE)。
