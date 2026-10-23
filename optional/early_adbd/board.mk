#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

ifeq ($(TARGET_ENABLE_EARLY_ADBD),true)

MAINLINE_COMMON_ANDROIDBOOT_PARAMS += androidboot.apex.early_adbd=true

endif # TARGET_ENABLE_EARLY_ADBD
