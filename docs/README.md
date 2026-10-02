# Mainline device bringup guide

How to bring up your own device tree for a device that runs a
mainline-style kernel.

Pages are short on purpose: each one has a TL;DR, then tables and
checklists. If a page grows past a screen or two, it should be split.

## Start here

1. Pick your base tree: [Choosing a base](CHOOSING_A_BASE.md).
2. Follow the stages: [Bringup overview](BRINGUP_OVERVIEW.md).
3. Want a working result in an hour? Try
   [First boot quickstart](FIRST_BOOT_QUICKSTART.md).

## Pages

| Page | Read it when you need to... |
|------|------------------------------|
| [CHOOSING_A_BASE.md](CHOOSING_A_BASE.md) | Decide between `pc`, `generic`, a SoC vendor tree, `virt` |
| [BRINGUP_OVERVIEW.md](BRINGUP_OVERVIEW.md) | See the staged path and exit criteria |
| [FIRST_BOOT_QUICKSTART.md](FIRST_BOOT_QUICKSTART.md) | Boot something quickly, on x86_64 PC |
| [DEVICE_TREE_SKELETON.md](DEVICE_TREE_SKELETON.md) | Create the files of a new device tree |
| [KERNEL.md](KERNEL.md) | Set up the kernel build |
| [KERNEL_PATCHES.md](KERNEL_PATCHES.md) | Find the patches pristine kernels need |
| [BOOT_AND_PARTITIONS.md](BOOT_AND_PARTITIONS.md) | Handle bootloader, partitions, fstab |
| [CHOOSING_OPTIONAL_MODULES.md](CHOOSING_OPTIONAL_MODULES.md) | Pick HALs and other options |
| [LIBINIT_AND_INIT.md](LIBINIT_AND_INIT.md) | Write init scripts, `libinit`, `ueventd` |
| [SEPOLICY.md](SEPOLICY.md) | Go from permissive to enforcing |
| [DEBUGGING.md](DEBUGGING.md) | Fix "stuck at X" |
| [DEVICE_README_TEMPLATE.md](DEVICE_README_TEMPLATE.md) | Write the README of your device tree |
| [AGENTS_FOR_BRINGUP.md](AGENTS_FOR_BRINGUP.md) | Let an AI agent help (rules apply) |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Send your work upstream |
| [DEVELOPING.md](DEVELOPING.md) | Work on the common repos themselves |

## Related docs

| Where | What |
|-------|------|
| `../README.md` | Integration snippets of this tree |
| `../optional/README.md` | Every `TARGET_*` option |
| `device/mainline/generic/docs/` | `generic_init` docs (porting, boot parameters, debugging) |
| `device/mainline/<vendor>-common/docs/` | SoC vendor specifics (currently `qcom-common`) |
| `hardware/mainline/common/docs/` | Code style, commits, review, workflow |

## Reference trees

| Tree | Why look at it |
|------|----------------|
| `device/pc/basic_x86_64_pc` | Smallest working tree |
| `device/mainline/generic` | One image for many machines |

SoC vendor trees list their own reference devices in their docs.
