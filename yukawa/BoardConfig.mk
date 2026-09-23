include device/amlogic/yukawa/BoardConfigCommon.mk

TARGET_BOOTLOADER_BOARD_NAME := $(TARGET_DEV_BOARD)
TARGET_BOARD_INFO_FILE := device/amlogic/yukawa/board-info/board-info-$(TARGET_DEV_BOARD).txt

BOARD_USERDATAIMAGE_PARTITION_SIZE := 10730078208

# Promethean VIM3 physical super geometry
ifeq ($(TARGET_PRODUCT),snapp_car_vim3)
BOARD_SUPER_PARTITION_SIZE := 3221225472
BOARD_DB_DYNAMIC_PARTITIONS_SIZE := 3217031168
endif



# Promethean VIM3 Wi-Fi capability profile
#
# The BCM4359-backed radio/driver advertises STA, AP and P2P interface modes.
# Expose each mode to Android's Wi-Fi HAL while conservatively limiting the
# radio to one active Wi-Fi interface at a time until the exact driver
# concurrency table is validated on the production kernel/firmware.
ifeq ($(TARGET_VIM3), true)
WIFI_HAL_INTERFACE_COMBINATIONS := {{{STA, AP, P2P}, 1}}
endif
