# Cardputer ADV · MicroPython IDE Firmware

A Chinese-first graphical IDE for the **M5Stack Cardputer ADV** (ESP32-S3), running on **MicroPython 1.29**. Editor, syntax checking, pinyin IME with frequency learning, SD-card logging and full session restore — built as a single flashable app.

> Current release: **v5** (2026-11-26)

## Features

- **Editor** — syntax highlighting, line numbers, completion, per-line error underlines
- **Syntax checking (9 classes)** — missing colon / comma / space, undefined name, bracket & quote mismatch, mixed indentation, full-width punctuation, `=` inside conditions, suspicious keyword spelling
- **File-wide checks** — unclosed brackets, odd triple-quote count, block keyword followed by an un-indented line
- **CJK** — 8716-glyph 16×16 font (GB2312 + General Standard Chinese Characters), so any character the IME can produce is renderable
- **Pinyin IME** — syllable and phrase candidates, tab/esc/backspace/enter handling; characters typed ≥ 3 times move to the front of their syllable candidates
- **Layout** — side panel on/off (zen vs full-split), terminal half/full screen, 8 themes, brightness levels
- **Persistence** — everything lives under `/sd/M5ADV_IDE_9F3C7A2B/` (state, daily logs, IME frequency), restored at boot before the first key press, including cursor line/column

## Firmware (v5)

| File | Offset | Size | SHA256 |
|---|---|---|---|
| `CardputerADV_v5_app_0x10000.bin` | `0x10000` | 2,037,168 B | `f531872dff43670f58e47898fc80517af9f4b2e87589effe1fc51e04b1ea8e99` |
| `bootloader_0x0.bin` | `0x0` | 19,072 B | `a5c3b7df0ef1338b8bc4d00d248263083e3a3f0d42dc88ae769a0e960dbee643` |
| `partition-table_0x8000.bin` | `0x8000` | 3,072 B | `1ec0da11b8644aff5e71bbfdc23c9e1fe896b895b850956123766a653c350d7b` |

Download: firmware bundle <https://aka.doubaocdn.com/s/QSzN8PesG5> · app only <https://aka.doubaocdn.com/s/qrl39c9GCu>

> Binaries (~2 MB) are not committed: GitHub's content API accepts text only. `firmware/` holds the flash scripts and checksums; see the bottom section to push the file tree and binaries with git.

### Flash

```bash
esptool.py --chip esp32s3 -p /dev/ttyACM0 -b 460800 --before default_reset --after hard_reset \
  write_flash --flash_mode dio --flash_freq 80m --flash_size 16MB \
  0x0 bootloader_0x0.bin 0x8000 partition-table_0x8000.bin 0x10000 CardputerADV_v5_app_0x10000.bin
```

App-only updates need just `0x10000`; the internal vfs is preserved.

## Build

Requirements: MicroPython 1.29 tree in `micropython/`, ESP-IDF v5.4.2, `usermods/allmods/micropython.cmake`.

```bash
./scripts/sync_modules.sh      # application/python_cn -> micropython/ports/esp32/modules
IDF_PATH=/path/to/esp-idf ./build.sh
```

Output: `micropython/ports/esp32/build/micropython.bin`.

`MICROPY_ROM_TEXT_COMPRESSION` **must** be `OFF`; if CMake ends up passing a quoted value, `MP_COMPRESSED_ROM_TEXT` becomes undefined and the qstr step stalls. Details in [docs/build.md](docs/build.md).

## Partition layout

```
nvs       0x009000   16 KB
phy_init  0x00f000    4 KB
factory   0x010000    3 MB   <- app 1.94 MB
vfs       0x310000  12.9 MB
```

## Docs

- [docs/build.md](docs/build.md) — build details and known pitfalls
- [docs/hardware.md](docs/hardware.md) — pins, display, SD, backlight
- [docs/grammar-check.md](docs/grammar-check.md) — the 9 error classes
- [docs/sd-state.md](docs/sd-state.md) — state keys, log format, IME frequency file
- [CHANGELOG.md](CHANGELOG.md) — v4 / v5 history

## Known limitations

- Triple-quote balance is textual; `"""` inside a comment may raise a false positive
- File-wide checks are capped at 400 lines
- IME frequency tracks single characters only
- Log files rotate by day, no size cap

## Pushing the full tree and binaries

```bash
git clone https://github.com/zxzxzxaaatt/cardputer-adv-micropython-ide.git
cd cardputer-adv-micropython-ide
cp -r /path/to/CardputerADV_MP3_Source_fixed/{application,build.sh} .
cp -r /path/to/CardputerADV_MP3_Source_fixed/micropython/ports/esp32/boards/M5STACK_CARDPUTER_ADV board
cp /path/to/fw_v5/*.bin firmware/
git add -A && git commit -m "add full source tree and v5 firmware" && git push
```

## License

MIT — see [LICENSE](LICENSE).
