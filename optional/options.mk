#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

ifneq ($(MAINLINE_COMMON_OPTIONS_MK_INCLUDED),true)
MAINLINE_COMMON_OPTIONS_MK_INCLUDED := true

##### Availability information #####

ifdef LINEAGE_BUILD
SUPPORTS_INLINE_KERNEL_BUILDING := true
endif # LINEAGE_BUILD

ifeq ($(MAINLINE_COMMON_PREFER_EXT_MODULES),true)
ifeq ($(wildcard device/mainline/common-ext/optional/options.mk),)
$(warning Target device prefers using modules from mainline/common-ext repository, however it is not available. Features may not work as intended.)
else
MAINLINE_COMMON_USE_EXT_MODULES := true
endif
endif

##### Combinations #####

TARGET_INITIAL_BRINGUP ?= false
ifeq ($(TARGET_INITIAL_BRINGUP),true)
$(warning TARGET_INITIAL_BRINGUP is set. Please unset it when possible.)
TARGET_CONSOLE_AS_ROOT ?= true
TARGET_ENABLE_EARLY_ADBD ?= true
TARGET_ENABLE_FBKEYBOARD ?= true
TARGET_GRAPHICS ?= swiftshader
TARGET_HEALTH_HAL ?= cuttlefish
TARGET_SUPPORTS_SUSPEND ?= false
endif

TARGET_USES_FRAMEBUFFER_DISPLAY ?= false
ifeq ($(TARGET_USES_FRAMEBUFFER_DISPLAY),true)
TARGET_GRAPHICS ?= swiftshader
# Note: FB Graphics HALs selection will use the flag TARGET_USES_FRAMEBUFFER_DISPLAY instead
TARGET_GRAPHICS_ALLOCATOR_HAL := none
TARGET_GRAPHICS_COMPOSER_HAL := none
endif

##### Components #####

# A/B
ifeq ($(AB_OTA_UPDATER),true)
TARGET_USES_MAINLINE_COMMON_AB_DEFS ?= true
endif

# Audio
TARGET_AUDIO_HAL ?= mainline

ifneq ($(filter mainline,$(TARGET_AUDIO_HAL)),)
TARGET_AUDIO_EFFECT_HAL ?= legacy
TARGET_AUDIO_POLICY ?= none
else ifneq ($(filter default-aidl ranchu,$(TARGET_AUDIO_HAL)),)
TARGET_AUDIO_EFFECT_HAL := none
TARGET_AUDIO_POLICY ?= cuttlefish
else
TARGET_AUDIO_EFFECT_HAL ?= none
TARGET_AUDIO_POLICY ?= common-handheld-7.0
TARGET_PROVIDES_AUDIO_POLICY_VOLUMES ?= false
TARGET_PROVIDES_BLUETOOTH_AUDIO_POLICY ?= false
endif

# Bluetooth
TARGET_BLUETOOTH_HAL ?= default-aidl

# Camera
TARGET_CAMERA_PROVIDER_HAL ?= mainline

# Graphics
TARGET_GRAPHICS ?= mesa

ifeq ($(TARGET_GRAPHICS),mesa)
TARGET_GRAPHICS_EGL ?= mesa
TARGET_GRAPHICS_VULKAN ?= mesa
else ifeq ($(TARGET_GRAPHICS),swiftshader)
TARGET_GRAPHICS_EGL ?= angle
TARGET_GRAPHICS_VULKAN ?= swiftshader
endif

# Graphics HALs
TARGET_MEMTRACK_HAL ?= default-aidl

ifeq ($(TARGET_GRAPHICS),mesa)
TARGET_GRAPHICS_ALLOCATOR_HAL ?= gralloc_gbm_mesa
else
TARGET_GRAPHICS_ALLOCATOR_HAL ?= minigbm-upstream
endif

ifeq ($(TARGET_INITIAL_BRINGUP),true)
TARGET_GRAPHICS_COMPOSER_HAL ?= drmfb-composer
else
TARGET_GRAPHICS_COMPOSER_HAL ?= drm_hwcomposer
endif

# Health
ifeq ($(TARGET_HAS_BATTERY),false)
TARGET_HEALTH_HAL ?= cuttlefish
else
TARGET_HEALTH_HAL ?= default-aidl
endif

# IR
ifeq ($(TARGET_HAS_IR),true)
TARGET_IR_HAL ?= lineage
endif

# Light
TARGET_LIGHT_HAL ?= lineage

# Power
TARGET_POWER_HAL ?= default-aidl
TARGET_SUPPORTS_SUSPEND ?= true

# Security
ifneq ($(TARGET_SUPPORTS_HARDWARE_BACKED_SECURITY),true)
TARGET_GATEKEEPER_HAL ?= software-aidl
TARGET_SECURITY_KEYMINT_HAL ?= default
endif

# Sensors
TARGET_SENSORS_HAL ?= mainline

# USB
ifneq ($(TARGET_SUPPORTS_USB_ACCESSORY_MODE),false)
TARGET_USB_GADGET_HAL ?= mainline
TARGET_USB_HAL ?= lineage-basic
TARGET_USB_INIT_SCRIPT ?= mainline
endif

# Vibrator
ifneq ($(TARGET_HAS_VIBRATOR),false)
TARGET_VIBRATOR_HAL ?= mainline
endif

# Wi-Fi
TARGET_HOSTAPD_AND_WPA_SUPPLICANT_FORM ?= apex-aosp

##### Inherits #####

# Inherit from mainline/common-ext
-include device/mainline/common-ext/optional/options.mk

endif # !MAINLINE_COMMON_OPTIONS_MK_INCLUDED
