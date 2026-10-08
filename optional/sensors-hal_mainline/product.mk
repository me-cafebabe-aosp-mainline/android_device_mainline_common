#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

ifeq ($(TARGET_SENSORS_HAL),mainline)

PRODUCT_PACKAGES += \
    com.android.hardware.sensors.mainline

TARGET_SENSORS_HAL_MAINLINE_VIRTUAL_BACKEND ?= false
ifeq ($(TARGET_SENSORS_HAL_MAINLINE_VIRTUAL_BACKEND),true)
$(call soong_config_set_bool,sensors_hal_mainline,include_virtual_backend,true)
PRODUCT_PACKAGES += \
    framework_compatibility_matrix.mainline.sensors.xml
endif # TARGET_SENSORS_HAL_MAINLINE_VIRTUAL_BACKEND

endif # TARGET_SENSORS_HAL
