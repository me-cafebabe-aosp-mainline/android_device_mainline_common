#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

ifeq ($(TARGET_USB_INIT_SCRIPT),mainline)

PRODUCT_PACKAGES += \
    init.mainline.usb.rc \
    init.recovery.mainline.usb.rc

PRODUCT_VENDOR_PROPERTIES += vendor.usb.configfs?=$(if $(TARGET_USB_GADGET_HAL),2,1)

endif # TARGET_USB_INIT_SCRIPT
