# Boot and partitions

**TL;DR:** Decide how the bootloader starts the kernel, which
partitions exist, then write one fstab. Do not skip `/metadata`.

## 1. How is the kernel started?

| Bootloader | Boot image? | Example |
|------------|-------------|---------|
| GRUB (PC, UEFI/BIOS) | No: kernel + ramdisk files | `basic_x86_64_pc` |
| U-Boot or a vendor bootloader | Depends on the bootloader | Your SoC vendor tree's docs |

Whether a boot image is used, and its header version, depends on what
the **bootloader** supports. For example, if GRUB loads the boot image,
GRUB's support decides the specification. The same logic applies to any
other bootloader.

Which bootloader you need is decided by the kernel port of the device.
A stock bootloader may boot mainline; some devices need a replacement.
Follow the existing Linux port. Vendor bootloader chains are described
in the docs of the matching `<SoC vendor>-common` tree or the device
README.

If the bootloader takes a boot image, set `BOARD_BOOTIMAGE_PARTITION_SIZE`
(this makes the build create it; `PRODUCT_BUILD_BOOT_IMAGE` is rarely
needed) and `BOARD_BOOT_HEADER_VERSION`. When the bootloader loads plain kernel and ramdisk files, no boot image is needed.

## 2. Boot parameters

| Where | Use when |
|-------|----------|
| `BOARD_BOOTCONFIG` | Only if the boot image header version supports it. Bootconfig travels in the vendor boot image, which needs header version 4 |
| `BOARD_KERNEL_CMDLINE` | Everything else, including **all** `androidboot.*` parameters when the header version does not support bootconfig |

When bootconfig is available, start from the common variables:

```
BOARD_BOOTCONFIG += $(MAINLINE_COMMON_ANDROIDBOOT_PARAMS)
BOARD_KERNEL_CMDLINE += $(MAINLINE_COMMON_KERNEL_PARAMS)
```

Otherwise put both into the command line (`basic_x86_64_pc` does):

```
BOARD_KERNEL_CMDLINE += $(MAINLINE_COMMON_ANDROIDBOOT_PARAMS)
BOARD_KERNEL_CMDLINE += $(MAINLINE_COMMON_KERNEL_PARAMS)
```

| Parameter | Meaning |
|-----------|---------|
| `androidboot.boot_devices=<path>` | Device that holds the boot partitions. `any` accepts every device (bringup only) |
| `androidboot.hardware=<name>` | Picks `fstab.<name>` and `init.<name>.rc` |
| `androidboot.partition_map=<dev>,<name>;...` | Name block devices that have no partition names. Escape `;` as `\;` in GRUB |
| `androidboot.selinux=permissive` | Bringup only |
| `androidboot.verifiedbootstate=orange` | Tell Android the bootloader is unlocked |
| `androidboot.mode` | Boot mode (see `generic/docs/boot-parameters.md`) |

`androidboot.partition_map` is read by init's `DeviceHandler`
(`system/core/init/devices.cpp`).

## 3. Partition layout

| Layout | Use when | Example |
|--------|----------|---------|
| Plain partitions | Few partitions, PC | `basic_x86_64_pc` |
| Dynamic partitions (`super`) | Phone-like | Your SoC vendor tree's reference device |

| Partition | Needed? | Note |
|-----------|---------|------|
| `system` | Yes | |
| `vendor` | Yes | |
| `userdata` | Yes | |
| `metadata` | **Yes** | Mounted like any fstab entry, but `aconfigd` uses it and many system components rely on `aconfigd` |
| `vendor_dlkm` / `system_dlkm` | Optional | Set `BOARD_USES_*IMAGE` for a standalone one. Without it, the content goes into an existing partition |
| `product`, `system_ext`, `odm` | Optional | |
| `boot`, `recovery` | If the bootloader uses images | Check partition size limits |

Set `BOARD_USES_METADATA_PARTITION := true`. Set per-partition
`BOARD_<P>IMAGE_FILE_SYSTEM_TYPE`, and a reserved size.

### Dynamic partitions

| Variable | Meaning |
|----------|---------|
| `PRODUCT_USE_DYNAMIC_PARTITIONS := true` | Build a `super` partition |
| `BOARD_SUPER_PARTITION_SIZE` | Size of `super` |
| `BOARD_SUPER_PARTITION_BLOCK_DEVICES`, `BOARD_SUPER_PARTITION_<DEV>_DEVICE_SIZE`, `BOARD_SUPER_PARTITION_METADATA_DEVICE` | If `super` is spread over several block devices |
| `BOARD_SUPER_PARTITION_GROUPS` | Name of the update group(s) |
| `BOARD_<GROUP>_PARTITION_LIST` | Which partitions are in the group (`system vendor product ...`) |
| `BOARD_<GROUP>_SIZE` | Size of the group, at most `super` minus the metadata overhead |

For a complete example, see `BoardConfig.mk` of a phone-class reference
device in your SoC vendor tree.

A/B: see `AB_OTA_UPDATER` and `TARGET_USES_MAINLINE_COMMON_AB_DEFS`
in `optional/README.md`. Boot control HALs differ per bootloader.

## 4. First stage init: AOSP or generic_init

**TL;DR:** keep AOSP's first stage init unless the partitions cannot be
described in advance. Then use `generic_init`.

AOSP first stage init reads a fixed fstab: the block devices and their
names are known when you build. `generic_init` replaces it, discovers
the block devices as they appear and builds the fstab at boot (see
`vendor/mainline/services/generic_init/docs/README.md`).

| Situation | First stage |
|-----------|-------------|
| Dedicated partitions with known names and one fstab: `basic_x86_64_pc`, a typical phone layout | AOSP init (the default) |
| Neither the hardware nor the disk content is known at build time: one image for many machines, installed on any disk or booted from an ISO | `generic_init` (`device/mainline/generic`) |
| The partition table can not or should not change, so the Android files are a directory of images on an existing partition (for example next to another OS) | `generic_init` (`device/samsung/ss8916`) |
| An unusual partition layout, or files that must be generated during boot, such as firmware | `generic_init` (`device/apple/snowcastle`) |
| The system as image files, with overlays or a `tmpfs` userdata | `generic_init` |

Things to know before choosing it:

- It is a fork of AOSP init, so the ramdisk carries more: modules and
  firmware for the storage, a ueventd config and the addon fstabs. Do
  not pick it only to get its debugging aids.
- It needs `rdinit=/system/bin/generic_init` and the `androidboot.*`
  parameters that say where Android lives, like `androidboot.mount_system`
  and `androidboot.android_dir`. They go in the command line (or the
  bootconfig) like the parameters above.
- What to add to the device tree is in
  `vendor/mainline/services/generic_init/docs/BUILDING.md`. The rest of
  `vendor/mainline/services/generic_init/docs/` explains how it works.
- Entries it does not generate, such as extra partitions and firmware,
  still come from the fstab or an addon fstab (see the next section).

## 5. fstab

init looks for `fstab.<androidboot.hardware>` in `/odm/etc/`,
`/vendor/etc/`, and the first-stage ramdisk
(`system/fs/fs_mgr/libfstab/fstab.cpp`).

Template (from `basic_x86_64_pc`):

```
/dev/block/by-name/metadata /metadata ext4 <opts> check,formattable,first_stage_mount,metadata_csum
/dev/block/by-name/system   /system   ext4 noatime,ro first_stage_mount
/dev/block/by-name/vendor   /vendor   ext4 noatime,ro first_stage_mount
/dev/block/by-name/userdata /data     f2fs <opts> latemount,check,quota,formattable
```

| Flag | Meaning |
|------|---------|
| `first_stage_mount` | Mounted by first-stage init, before the rest boots |
| `latemount` | Mounted by `mount_all --late` |
| `formattable` | May be formatted if mount fails |

Install the fstab twice if first-stage init needs it: normal and
`.ramdisk` variant (see `fstab.basic_x86_64_pc.ramdisk`).
Recovery uses `TARGET_RECOVERY_FSTAB`.

## 6. Firmware

| What | How |
|------|-----|
| Kernel looks in | `firmware_class.path=/vendor/firmware/` (already in the common cmdline) |
| Extra firmware directories | `firmware_directories` in `ueventd.<device>.rc` |
| Firmware that lives on a partition of the device | Mount that partition, and list its directory in `firmware_directories` |
| linux-firmware files | `PRODUCT_PACKAGES` entries from `external/linux-firmware-mainline`. That repository only has the files pulled in so far; pull in more when your device needs them |
| Needed before `/vendor` is mounted | Put it in the ramdisk (see `generic/docs/porting.md`) |
| Files you do not have | Borrow them from the downstream `vendor/` tree of the device |

Do not ship firmware you may not redistribute.

## 7. Before first flash

- [ ] Backup of the original partitions
- [ ] Know how to get back (stock flash, fastboot, serial)
- [ ] Device specific steps (erase `dtbo`, bootloader build) are in the
      device README

## Check

- [ ] Kernel log shows `/system` and `/vendor` mounted
- [ ] `/metadata` is mounted (`aconfigd` needs it)

Next: [Optional modules](CHOOSING_OPTIONAL_MODULES.md)
