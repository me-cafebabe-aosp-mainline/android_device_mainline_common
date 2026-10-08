#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

ifeq ($(TARGET_AUDIO_HAL),mainline)

PRODUCT_PACKAGES += \
    com.android.hardware.audio.mainline \
    framework_compatibility_matrix.mainline.audio.xml

TARGET_AUDIO_MAINLINE_UCM_PROFILES ?= all
ifeq ($(TARGET_AUDIO_MAINLINE_UCM_PROFILES),all)
PRODUCT_PACKAGES += alsa-ucm-conf-all
else ifeq ($(TARGET_AUDIO_MAINLINE_UCM_PROFILES),base)
PRODUCT_PACKAGES += alsa-ucm-conf-base
else ifeq ($(TARGET_AUDIO_MAINLINE_UCM_PROFILES),none)
# nothing
else
PRODUCT_PACKAGES += $(foreach c,$(TARGET_AUDIO_MAINLINE_UCM_PROFILES),alsa-ucm-conf-card-$(c))
endif

ifeq ($(TARGET_AUDIO_EFFECT_HAL),)
$(call soong_config_set_bool,mainline_audio,internal_effects,true)
endif # TARGET_AUDIO_EFFECT_HAL

TARGET_AUDIO_HAL_TYPE := aidl

endif # TARGET_AUDIO_HAL
