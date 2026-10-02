# First boot quickstart

**TL;DR:** Build `basic_x86_64_pc`, copy three files, add one GRUB
entry. No new code.

Use this to see Android run on a PC, before writing your own tree. The
full steps live in `device/pc/basic_x86_64_pc/README.md`; this page is
the short version.

`basic_x86_64_pc` can also be booted in QEMU, which is a good way to
try it without a spare disk. QEMU's direct kernel boot works too. The
details are left for you to work out.

## You need

- An x86_64 PC with GRUB, and a spare disk or partitions
- A built AOSP/LineageOS tree with `device/pc/basic_x86_64_pc`

## Steps

| # | Do | Command or detail |
|---|----|-------------------|
| 1 | Build | `breakfast basic_x86_64_pc` then `m kernel ramdisk recoveryimage systemimage vendorimage` |
| 2 | Copy boot files | `kernel`, `ramdisk.img`, `ramdisk-recovery.img` into `/android/` on a disk GRUB can read |
| 3 | Make partitions | system 2.5 GB, vendor 256 MB, userdata 2 GB, metadata 16 MB |
| 4 | Write images | `dd` `system.img` and `vendor.img` into their partitions |
| 5 | Add GRUB entry | Kernel cmdline from `get_build_var BOARD_KERNEL_CMDLINE` |
| 6 | Set partition map | `androidboot.partition_map=sda5,system\;sda6,vendor\;...` |

Do not skip `/metadata`: `aconfigd` uses it, and many system components
rely on `aconfigd`.

## If it does not boot

Look at [Debugging](DEBUGGING.md). Start with the "no console output"
rows.

## What you just exercised

| Piece | Where it lives |
|-------|----------------|
| Kernel config | `configs/basic_x86_64_pc.config` plus fragments |
| fstab | `configs/fstab.basic_x86_64_pc` |
| Partition names | `androidboot.partition_map` |
| init glue | `configs/init.basic_x86_64_pc.rc` |

Next: [Device tree skeleton](DEVICE_TREE_SKELETON.md) to see how those
fit together.
