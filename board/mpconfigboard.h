#ifndef MICROPY_HW_BOARD_NAME
#define MICROPY_HW_BOARD_NAME               "M5Stack Cardputer ADV (MicroPython Shell CN)"
#endif
#define MICROPY_HW_MCU_NAME                 "ESP32S3"

// 开机不打印 REPL 横幅（屏幕和串口都保持干净，直接进 Shell）
#define MICROPY_SHELL_SILENT_BOOT           (1)

// REPL on UART0 as well as the on-screen terminal (os.dupterm).
#define MICROPY_HW_ENABLE_UART_REPL         (1)

#define MICROPY_HW_I2C0_SCL                 (9)
#define MICROPY_HW_I2C0_SDA                 (8)

// The shell does not use Bluetooth; leaving it out keeps the app image small.
#define MICROPY_PY_BLUETOOTH                (0)

// 不用 btree（省体积，也不依赖 berkeley-db 子模块）
#define MICROPY_PY_BTREE                    (0)
