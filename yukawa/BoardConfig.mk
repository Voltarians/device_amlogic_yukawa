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
# Promethean VIM3 live validation (kernel 5.15 / BCM4359 family) reports:
#   AP <= 2, managed <= 2, P2P-client/P2P-GO <= 2, P2P-device <= 1,
#   total interfaces <= 4, channels <= 2.
#
# Expose a deliberately conservative concurrent subset to Android:
# one station + one AP + one P2P interface at the same time. This enables
# normal WLAN connectivity, the Promethean Android Auto SoftAP, and Wi-Fi
# Direct concurrently while staying below the validated kernel limits.
ifeq ($(TARGET_VIM3), true)
WIFI_HAL_INTERFACE_COMBINATIONS := {{{STA}, 1}, {{AP}, 1}, {{P2P}, 1}}
endif
