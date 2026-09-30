#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

ifeq ($(TARGET_CAMERA_PROVIDER_HAL),mainline)

# The mainline camera HAL serves external (USB) cameras as well; a second
# provider would compete for the same /dev/video* nodes.
ifneq ($(TARGET_EXTERNAL_CAMERA_PROVIDER_HAL),)
$(error TARGET_CAMERA_PROVIDER_HAL=mainline handles external cameras itself, unset TARGET_EXTERNAL_CAMERA_PROVIDER_HAL and TARGET_SUPPORTS_EXTERNAL_CAMERAS)
endif

PRODUCT_PACKAGES += \
    com.android.hardware.camera.provider.mainline

# Front / rear and infrared information on USB cameras.
TARGET_CAMERA_PROVIDER_HAL_MAINLINE_HWDB ?= true
ifeq ($(TARGET_CAMERA_PROVIDER_HAL_MAINLINE_HWDB),true)
PRODUCT_PACKAGES += \
    70-cameras.hwdb
endif

endif # TARGET_CAMERA_PROVIDER_HAL
