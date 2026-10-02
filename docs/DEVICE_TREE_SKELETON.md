# Device tree skeleton

**TL;DR:** Copy `device/pc/basic_x86_64_pc`, rename it, then change
only what your device needs.

## Naming

| What | Rule |
|------|------|
| Device tree directory | Add the `mainline` suffix when an Android port based on a downstream kernel can exist for the device |
| Product / lunch name | Same: `<device>_mainline`, e.g. `aosp_<device>_mainline` |
| No downstream port possible | No suffix (for example `basic_x86_64_pc`) |

The suffix keeps the tree from clashing with a downstream-kernel tree of
the same device.

## Files

```
device/<vendor>/<device>/
├── Android.bp               # soong_namespace (imports)
├── AndroidProducts.mk       # lunch targets
├── aosp_<device>.mk         # AOSP product
├── lineage_<device>.mk      # LineageOS product
├── BoardConfig.mk           # Board config
├── device.mk                # Product config
├── board-info.txt           # Fastboot requirements
├── lineage.dependencies     # Repos this tree needs
├── configs/                 # fstab, kernel config, init rc
├── overlays/                # Resource overlays
└── README.md                # See DEVICE_README_TEMPLATE.md
```

| File | What goes in | Model |
|------|--------------|-------|
| `AndroidProducts.mk` | `PRODUCT_MAKEFILES` and `COMMON_LUNCH_CHOICES` | `basic_x86_64_pc` |
| `BoardConfig.mk` | Arch, kernel, partitions, cmdline | `basic_x86_64_pc` |
| `device.mk` | Packages, props, overlays, init rc | `basic_x86_64_pc` |
| `lineage.dependencies` | Repos pulled by `breakfast` | any |
| `Android.bp` | `soong_namespace` (add `imports` for repos you depend on) | `basic_x86_64_pc` |

## How makefiles load

The build loads, in this order:

1. Product makefiles (listed in `AndroidProducts.mk`)
2. `BoardConfig.mk`
3. `Android.mk` and makefiles in `build/`

| Statement | When the file is loaded |
|-----------|-------------------------|
| `include <file>` | Immediately, in place. This is true in every makefile |
| `$(call inherit-product, <file>)` | Queued: loaded after the makefile that contains it finishes |

What follows from this:

- A variable set **anywhere** in your `device.mk` is seen by the
  inherited common makefiles, even if it comes after the
  `inherit-product` line.
- It is also seen by `BoardConfig.mk`, because that loads later.
- `include` never waits, so set a variable **before** the `include`
  that reads it.
- An inherited makefile (such as `mainline_common.mk`) loads **after**
  the makefile that inherits it (your `device.mk`). A plain `:=` in the
  inherited file therefore overwrites what your file set earlier, so
  shared files use `?=` for their defaults.
- A variable can be overridden from the environment at build time only
  if no makefile assigns it with `:=`. Defaults written with `?=` yield
  to the environment; a device that sets the variable itself wins.

## Files to write

`BoardConfig.mk`:

1. `USES_DEVICE_<NAME> := true`
2. Your variables that the common board file reads
   (for example `TARGET_INITIAL_BRINGUP`, if not set in `device.mk`)
3. `include device/mainline/common/BoardConfigMainlineCommon.mk`
   (or the board file of your SoC vendor tree, which includes it)
4. Your own settings

`device.mk`:

1. `DEVICE_PATH := ...`
2. `$(call inherit-product, device/mainline/common/mainline_common.mk)`
3. Your own settings, including overrides of `TARGET_*` options and
   `TARGET_INITIAL_BRINGUP`

A device can also `include device/mainline/common/optional/options.mk`
itself, to get the option defaults earlier. See the top-level
`README.md`.

## Minimal `BoardConfig.mk` checklist

| Area | Variables |
|------|-----------|
| Arch | `TARGET_ARCH`, `TARGET_CPU_ABI`, `TARGET_ARCH_VARIANT` |
| Boot | `BOARD_KERNEL_CMDLINE`, `BOARD_BOOT_HEADER_VERSION`, and `BOARD_BOOTCONFIG` only if the header version supports it (see [Boot](BOOT_AND_PARTITIONS.md)) |
| Kernel | `TARGET_KERNEL_SOURCE`, `TARGET_KERNEL_CONFIG`; `TARGET_KERNEL_CONFIG_EXT` for the Android fragments when not using `gki_defconfig` (see [Kernel](KERNEL.md)) |
| Partitions | `BOARD_*IMAGE_FILE_SYSTEM_TYPE`, `BOARD_USES_METADATA_PARTITION` (see [Boot](BOOT_AND_PARTITIONS.md)) |
| A/B | `AB_OTA_UPDATER` |
| Platform | `TARGET_BOARD_PLATFORM` |
| Recovery | `TARGET_RECOVERY_FSTAB` |

## Minimal `device.mk` checklist

| Area | What |
|------|------|
| Heap | One `*-dalvik-heap.mk` from `frameworks/native/build/` |
| Storage | `emulated_storage.mk`, **only** if the kernel and the device configuration support it. Pristine mainline kernels generally do not |
| Images | Usually nothing. Setting `BOARD_BOOTIMAGE_PARTITION_SIZE` or `BOARD_RECOVERYIMAGE_PARTITION_SIZE` makes the build create that image, and the ramdisk is built by default. Set `PRODUCT_BUILD_*_IMAGE` only to override (see `build/make/core/board_config.mk`) |
| Init | `init.<device>.rc`, `init.recovery.<device>.rc`, fstab |
| Levels | `TARGET_FOLLOWS_LATEST_SHIPPING_API_LEVEL := true`, `TARGET_FOLLOWS_LATEST_VINTF_TARGET_LEVEL := true`. If the device needs more relaxed requirements (for example HIDL HALs, which newer target-levels forbid), leave these unset and use a lower `PRODUCT_SHIPPING_API_LEVEL` and a manifest with a lower target-level |
| Namespaces | `PRODUCT_SOONG_NAMESPACES += $(DEVICE_PATH)` |
| Kernel requirements | `PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false` for kernels that do not completely match Android's expectations in `kernel/configs/` (the build defaults it to `true` from shipping API level 29, and then checks the kernel against them) |
| Pristine kernel | `use_memfd.rc`, and the `kernel/mainline/configs` Soong namespace for that module only (see [Kernel patches](KERNEL_PATCHES.md)) |

## Device identity and display

Set in `device.mk` and `BoardConfig.mk` of the device.

| Variable | Meaning |
|----------|---------|
| `TARGET_SCREEN_WIDTH`, `TARGET_SCREEN_HEIGHT` | Size used for the boot animation |
| `TARGET_SCREEN_DENSITY` | Screen density in dpi (`BoardConfig.mk`) |
| `PRODUCT_AAPT_PREF_CONFIG` | Preferred density bucket for resources, such as `xxhdpi` |
| `TARGET_BOOTANIMATION_HALF_RES` | Use the half-resolution boot animation on large screens |
| `TARGET_OTA_ASSERT_DEVICE` | Device names an OTA package accepts, comma separated |
| `board-info.txt` | Requirements checked by fastboot flashing |

## Hardware-driven switches

Set these when they apply; the common tree reacts to them.

| Variable | Set to | Effect |
|----------|--------|--------|
| `TARGET_HAS_BATTERY` | `false` | Health HAL becomes `cuttlefish` |
| `TARGET_HAS_VIBRATOR` | `false` | No vibrator HAL |
| `TARGET_SUPPORTS_SUSPEND` | `false` | Power HAL without suspend |
| `TARGET_USES_FRAMEBUFFER_DISPLAY` | `true` | Use framebuffer instead of DRM |
| `PRODUCT_IS_GO` | `true` | Android Go bits |

Optional HAL selection is described in
[Choosing optional modules](CHOOSING_OPTIONAL_MODULES.md).

## Add the repos

List repos your tree needs in `lineage.dependencies` and in your
local manifest. Devices on a SoC vendor tree usually also need kernel
and vendor repos; see that tree's docs.

## Check

- [ ] `breakfast <device>` works
- [ ] No `$(warning ...)` you do not understand
- [ ] `m` builds `kernel`, `ramdisk`, system and vendor images

Next: [Kernel](KERNEL.md)
