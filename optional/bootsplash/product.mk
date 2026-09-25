#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

ifeq ($(TARGET_ENABLE_BOOTSPLASH),true)
ifeq ($(TARGET_ENABLE_FBKEYBOARD),true)
$(error Bootsplash and fbkeyboard both write the boot display; disable one of them)
endif
PRODUCT_PACKAGES += bootsplash
endif
