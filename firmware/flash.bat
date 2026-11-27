@echo off
rem Windows：flash.bat COM3
set PORT=%1
if "%PORT%"=="" set PORT=COM3
esptool.py --chip esp32s3 -p %PORT% -b 460800 --before default_reset --after hard_reset ^
  write_flash --flash_mode dio --flash_freq 80m --flash_size 16MB ^
  0x0 bootloader_0x0.bin ^
  0x8000 partition-table_0x8000.bin ^
  0x10000 CardputerADV_v5_app_0x10000.bin
pause
