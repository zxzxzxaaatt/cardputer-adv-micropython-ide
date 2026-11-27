# 硬件与引脚

板子：M5Stack Cardputer ADV（ESP32-S3，16 MB Flash，无 PSRAM）。

| 功能 | 外设 / 引脚 | 代码位置 |
|---|---|---|
| 屏幕 | ST7789，SPI2，sck=36，mosi=35，80 MHz | `dev._Init()` |
| 屏幕尺寸 | 240×135 | `UI.py` 里的 `W/H` |
| 键盘 | I2C 键盘控制器，SoftI2C scl=9 sda=8，400 kHz | `Keyboard.py` / `dev._Init()` |
| 电池电压 | ADC10 | `dev.batt_uv()` |
| SD 卡 | `SDCard(slot=3, cs=12, mosi=14, sck=40, miso=39)`，mount 到 `/sd` | `dev._Init()` |
| 开机键 | GPIO0 输入 | `shell._Init()` 里的 `_p0` |
| 背光 | PWM 占空档位 `dev._bld`，当前档 `dev._bl` | `shell.on_bright()` |

`mpconfigboard.cmake` 刻意移除了 `sdkconfig.spiram_quad`，因为 Octal-SPIRAM 和屏幕用的 GPIO33-37 冲突。

SD 卡不插也能开机，状态 / 日志 / 词频会静默降级为内存态（重启丢）。
