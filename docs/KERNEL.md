# Kernel

**TL;DR:** if the kernel is an Android Common Kernel, use
`gki_defconfig` plus one device fragment. Otherwise use the base
defconfig plus the Android fragments, and your own fixups last.

## Pick a kernel source

| Source | Notes |
|--------|-------|
| `android-mainline` or a modern ACK branch | Has Android patches already, and a `gki_defconfig` |
| SoC community fork | More hardware enablement on top of `torvalds/linux`. Usually no Android specifics, so it needs [Android patches](KERNEL_PATCHES.md) |
| Pristine `torvalds/linux` | Needs patches and `use_memfd.rc` |

Set it with `TARGET_KERNEL_SOURCE := kernel/...`.

## Pick a config approach

| Approach | When | `TARGET_KERNEL_CONFIG` | `TARGET_KERNEL_CONFIG_EXT` |
|----------|------|------------------------|----------------------------|
| **ACK `gki_defconfig` + a device fragment** (preferred) | The kernel is a modern ACK and the device's needs fit in one fragment | `gki_defconfig` and `<device>.config` | Usually not needed |
| Base defconfig + Android fragments | Any other kernel | The kernel's defconfig, plus in-tree fragments | The Android fragments below, then your fixups |

`gki_defconfig` already has the Android enablement. If the device can
get by with a small fragment on top of it, that is better than applying
the Android fragments from `kernel/configs` and
`kernel/mainline/configs`: fewer entries to maintain, and no conflicts
with the kernel's own choices. `basic_x86_64_pc` does this
(`gki_defconfig` plus `configs/basic_x86_64_pc.config`).

## Start from the distribution config

When a Linux distribution already supports the device (for example
postmarketOS), start from its kernel config and sources. Keep what the
hardware needs, then add the Android configuration (a `gki_defconfig`
base or the fragments below). Drop options that exist only for
GNU/Linux userspace.

## Config variables

| Variable | Meaning |
|----------|---------|
| `TARGET_KERNEL_CONFIG` | Base defconfig first, then in-tree fragments |
| `TARGET_KERNEL_CONFIG_EXT` | Paths to fragments **outside** the kernel source |
| `BOARD_KERNEL_IMAGE_NAME` | `Image`, `bzImage`, ... |
| `TARGET_KERNEL_DTB` | DTB make target (default `dtbs`) |
| `TARGET_KERNEL_ARCH` | Kernel arch, if auto-detect is wrong |

Full list: `vendor/lineage/build/tasks/kernel.mk` and
`vendor/lineage/config/BoardConfigKernel.mk`.

## Fragment order (`TARGET_KERNEL_CONFIG_EXT`)

Only for the "base defconfig + Android fragments" approach. Later
fragments win. Use this order:

| # | Fragment | Purpose |
|---|----------|---------|
| 1 | `fragments/android-base-pre/common.config` | Entries commonly missing or mismatching |
| 2 | `fragments/android-base-pre/<arch>.config` | Arch defconfig fixes |
| 3 | `kernel/configs/b/android-6.12/android-base.config` | AOSP requirement |
| 4 | `fragments/android-base-conditional/CONFIG_<ARCH>-y.config` | AOSP conditional entries |
| 5 | `fragments/common.config` | Mainline common additions |
| 6 | `fragments/y/*.config` | Optional: `y/fbcon.config`, ... |
| 7 | `fragments/n/*.config` | Optional: disable hardening, Rust, ... |
| 8 | `$(DEVICE_PATH)/kconfigs/fixups.config` | Yours, always last |

All `fragments/` paths are under `kernel/mainline/configs/`. Using the
fragments needs no Soong namespace: they are plain files referenced by
path.

## Fixups

Some options disappear because of dependencies. After a build,
check them:

```
kernel/mainline/configs/utilities/validate_kernel_config.py
```

Put the wanted ones back in `fixups.config`, each with a short comment.

## Kernel modules

| Variable | Meaning |
|----------|---------|
| `BOARD_VENDOR_KERNEL_MODULES_LOAD` | Vendor modules to load (in `vendor_dlkm`, or an existing partition if it is not standalone) |
| `BOARD_RECOVERY_RAMDISK_KERNEL_MODULES_LOAD` | Modules loaded in recovery |
| `RECOVERY_KERNEL_MODULES` | Modules copied to recovery |
| `TARGET_AUTO_COLLECT_KERNEL_MODULE_DEPS` | Pull dependencies automatically |

Typical files in `modprobe/`:

| File | Content |
|------|---------|
| `modules.load.basic` | Needed early: storage, **serial console**, display and input, and the hardware they depend on (clocks, power, buses) |
| `modules.load.normal` | Everything loaded after `post-fs` |
| `modules.blocklist` | Modules to never load |

`modules.load.basic` must contain the serial console modules, and the
modules that enable the hardware those modules need. Without them the
early stages have no log.

Load them from init (see [init](LIBINIT_AND_INIT.md)).

## Console and logs

Add a kernel console to `BOARD_KERNEL_CMDLINE` (`console=tty0`,
`console=ttyS0,115200n8`, ...). Without it stage 2 is blind. SoC vendor
trees may already add the serial console of their SoCs.

## Check

- [ ] Kernel builds
- [ ] `validate_kernel_config.py` shows nothing important
- [ ] Kernel log appears on the console
