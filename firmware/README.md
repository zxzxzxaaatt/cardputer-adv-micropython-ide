# v5 固件：烧录说明

本目录放烧录脚本与校验值。二进制（约 2 MB）因为 GitHub 文本接口限制没有入库，下载：

- 完整固件包（含本目录脚本）：<https://aka.doubaocdn.com/s/QSzN8PesG5>
- 单个 app：<https://aka.doubaocdn.com/s/qrl39c9GCu>

拿到 bin 后放进本目录，然后：

```bash
./flash.sh /dev/ttyACM0      # Windows: flash.bat COM3
```

| 文件 | 地址 | 大小 |
|---|---|---|
| `CardputerADV_v5_app_0x10000.bin` | `0x10000` | 2,037,168 B |
| `bootloader_0x0.bin` | `0x0` | 19,072 B |
| `partition-table_0x8000.bin` | `0x8000` | 3,072 B |

校验：`sha256sum -c SHA256SUMS.txt`。

只更新应用时烧 `0x10000` 即可，内部 vfs 里的文件不会被清。
