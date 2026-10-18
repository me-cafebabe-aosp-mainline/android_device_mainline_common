#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

ifeq ($(TARGET_ENABLE_SELOGGER),true)

BOARD_VENDOR_SEPOLICY_DIRS += \
    tools/selogger/sepolicy/vendor

endif # TARGET_ENABLE_SELOGGER
