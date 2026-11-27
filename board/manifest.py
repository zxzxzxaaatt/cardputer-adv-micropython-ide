# Freeze the MicroPython Shell application modules (including the CJK
# font / text renderer and the pinyin IME).
freeze("$(PORT_DIR)/modules")
include("$(MPY_DIR)/extmod/asyncio")
