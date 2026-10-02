# Common Android device tree for devices with mainline-style kernel

## Introduction

This series of device tree supports these types of kernels:

- Android Common Kernel (ACK): https://android.googlesource.com/kernel/common (`android-mainline` branch or any recent LTS branches)
- Pristine mainline kernel: https://github.com/torvalds/linux (or its forks that follows the same standards)

The core principles of this device tree are:

- Cover every common usecases
- Not to force behavior changes on the users when not necessary
- Support wide range of hardware

This device tree is **always** intended to maintain support
for being used within pristine AOSP source tree,
regardless of where this device tree is currently hosted at.

This device tree automatically includes `device/mainline/common-ext`
device tree if present. It is external and is not dependency by default.

The origin of this device tree is [here](https://github.com/me-cafebabe-aosp-mainline).

## Documentation

Bringing up your own device? Start with [docs/README.md](docs/README.md).

## Structure

```
.
├── Android.bp
├── apex # APEX modules, should not contain program source code
├── audio # Audio configuration files
├── BoardConfigMainlineCommon.mk # Board configuration makefile
├── build # Build rules
├── components
├── docs # Bringup guide for device tree authors
├── init # Files used by Android init program
│   ├── Android.bp
│   ├── init.mainline.rc
│   ├── init.recovery.mainline.rc
│   ├── ueventd.rc
│   └── zram.rc
├── libraries
├── lineage.dependencies # List of dependencies
├── mainline_common.mk # Product configuration makefile
├── optional # Root of optional modules
│   ├── options.mk # Default options for optional modules
│   ├── README.md # List of the available global optional options
│   ├── _template.mk # Template for makefiles in subdirs
│   └── <subdirs> # Optional modules
├── overlays # Root of overlays
│   ├── overlay # Common overlays
│   ├── overlay-go # Android Go specific overlays
│   ├── overlay-lineage # LineageOS specific overlays
│   └── rro # Root of RRO overlays
├── properties
├── README.md
├── seccomp_policy
└── sepolicy
```

## Integration

Add this on top of device-specific board makefile, such as `BoardConfig.mk`:

```
# Inherit from mainline/common
include device/mainline/common/BoardConfigMainlineCommon.mk
```

Add this on top of device-specific product makefile, such as `device.mk`:

```
# Inherit from mainline/common
$(call inherit-product, device/mainline/common/mainline_common.mk)
```

If the device should get the default options of the optional components
on its own product makefiles, add this to it, before where the override
of the default options begin:

```
# Include default options from mainline/common
include device/mainline/common/optional/options.mk
```

If the device is in initial bringup stage, it's recommended to add this,
before any inclusion of `mainline/common` begins:

```
# Remove this as soon as initial bringup is complete.
TARGET_INITIAL_BRINGUP := true
```

If the device should use common boot parameters, include these. For example:
```
BOARD_BOOTCONFIG += $(MAINLINE_COMMON_ANDROIDBOOT_PARAMS)
BOARD_KERNEL_CMDLINE += $(MAINLINE_COMMON_KERNEL_PARAMS)
```
