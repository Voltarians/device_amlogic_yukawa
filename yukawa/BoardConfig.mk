include device/amlogic/yukawa/BoardConfigCommon.mk

TARGET_BOOTLOADER_BOARD_NAME := $(TARGET_DEV_BOARD)
TARGET_BOARD_INFO_FILE := device/amlogic/yukawa/board-info/board-info-$(TARGET_DEV_BOARD).txt

BOARD_USERDATAIMAGE_PARTITION_SIZE := 10730078208

# Promethean VIM3 physical super geometry
ifeq ($(TARGET_PRODUCT),snapp_car_vim3)
BOARD_SUPER_PARTITION_SIZE := 3221225472
BOARD_DB_DYNAMIC_PARTITIONS_SIZE := 3217031168
endif

