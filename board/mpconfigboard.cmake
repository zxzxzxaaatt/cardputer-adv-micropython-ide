include(boards/mpconfigboard_esp32s3_common.cmake)

# NOTE: no SPIRAM here on purpose -- the Cardputer ADV LCD uses GPIO33-37,
# which overlap the Octal-SPIRAM pins.
list(REMOVE_ITEM SDKCONFIG_DEFAULTS boards/sdkconfig.spiram_quad)

list(APPEND SDKCONFIG_DEFAULTS
    boards/sdkconfig.240mhz
    boards/sdkconfig.flash_qio_80m
    ${MICROPY_BOARD_DIR}/sdkconfig.board
)

set(MICROPY_FROZEN_MANIFEST ${MICROPY_BOARD_DIR}/manifest.py)
