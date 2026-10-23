#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

USES_DEVICE_MAINLINE_COMMON := true

# Include the fragments
include $(MAINLINE_COMMON_PATH)/optional/*/board.mk

# Boot parameters
MAINLINE_COMMON_ANDROIDBOOT_PARAMS := \
    androidboot.init_fatal_reboot_target=recovery
MAINLINE_COMMON_KERNEL_PARAMS := \
    binder.devices=binder,hwbinder,vndbinder \
    binder.impl=rust \
    firmware_class.path=/vendor/firmware/ \
    log_buf_len=4M \
    loop.max_part=7 \
    printk.devkmsg=on \
    rw

ifeq ($(TARGET_INITIAL_BRINGUP),true)
MAINLINE_COMMON_ANDROIDBOOT_PARAMS += \
    androidboot.boot_devices=any \
    androidboot.selinux=permissive
MAINLINE_COMMON_KERNEL_PARAMS += \
    audit=0 \
    panic=-1
endif

ifneq ($(MAINLINE_COMMON_DISABLE_COMMON_BOARD_DEFS),true)

# Bootloader
TARGET_NO_BOOTLOADER ?= true

# Filesystem
ifeq ($(TARGET_BOOTS_16K),true)
BOARD_EROFS_BLOCKSIZE := 16384
BOARD_F2FS_BLOCKSIZE := 16384
endif

# Memory allocator
ifeq ($(PRODUCT_IS_GO),true)
MALLOC_SVELTE := true
endif

# Properties
TARGET_SYSTEM_EXT_PROP += $(MAINLINE_COMMON_PATH)/properties/system_ext.prop
TARGET_VENDOR_PROP += $(MAINLINE_COMMON_PATH)/properties/vendor.prop

ifeq ($(PRODUCT_IS_GO),true)
TARGET_PRODUCT_PROP += $(MAINLINE_COMMON_PATH)/properties/product_go.prop
TARGET_VENDOR_PROP += $(MAINLINE_COMMON_PATH)/properties/vendor_go.prop
endif

# RIL
ENABLE_VENDOR_RIL_SERVICE := true

# Security patch level
VENDOR_SECURITY_PATCH = $(PLATFORM_SECURITY_PATCH)

# SELinux
BOARD_VENDOR_SEPOLICY_DIRS += \
    $(MAINLINE_COMMON_PATH)/sepolicy/vendor
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += \
    $(MAINLINE_COMMON_PATH)/sepolicy/private

ifeq ($(LINEAGE_BUILD),)
BOARD_VENDOR_SEPOLICY_DIRS += \
    $(MAINLINE_COMMON_PATH)/sepolicy/vendor/lineage
endif

# Wi-Fi
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
WIFI_HIDL_UNIFIED_SUPPLICANT_SERVICE_RC_ENTRY := true
WPA_SUPPLICANT_VERSION := VER_0_8_X

endif # !MAINLINE_COMMON_DISABLE_COMMON_BOARD_DEFS

# Inherit from mainline/common-ext
-include device/mainline/common-ext/BoardConfigMainlineCommonExt.mk
