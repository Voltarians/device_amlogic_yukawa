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
# Live kernel 5.15 / BCM4359-family validation reports:
#   AP <= 2
#   managed/STA <= 2
#   P2P-client/P2P-GO <= 2
#   P2P-device <= 1
#   IBSS <= 1
#   total interfaces <= 4
#   channels <= 2
#
# Android's HAL models the single P2P-device as one logical P2P iface; that
# device may create the driver-supported P2P client/GO group interfaces.
# IBSS has no Android Wi-Fi HAL concurrency type and remains available only
# through lower-level nl80211/iw use.
#
# These three maximal combinations cover every Android-representable subset
# within the driver's limits:
#   2 STA + 2 AP
#   2 STA + 1 AP + 1 P2P
#   1 STA + 2 AP + 1 P2P
# Any smaller STA/AP/P2P combination is a subset of one of these.
ifeq ($(TARGET_VIM3), true)
WIFI_HAL_INTERFACE_COMBINATIONS := {{{STA}, 2}, {{AP}, 2}}, {{{STA}, 2}, {{AP}, 1}, {{P2P}, 1}}, {{{STA}, 1}, {{AP}, 2}, {{P2P}, 1}}
endif
