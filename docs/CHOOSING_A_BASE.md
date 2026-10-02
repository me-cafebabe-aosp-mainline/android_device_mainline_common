# Choosing a base

**TL;DR:** a PC, SBC or other device that should "just work" → `generic`.
SoC with its own vendor tree → that tree. Anything else → write your
own on top of `mainline/common`.

## Decision table

| Your device | Use | Why |
|-------------|-----|-----|
| A kernel can boot on it and its hardware works through drivers | `device/mainline/generic` | One image for many machines: `generic_init` finds the partitions and `hardware_detect` detects the hardware at boot |
| Needs a minimal start, just to see Android run | `device/pc/basic_x86_64_pc` | Smallest tree, easy to read |
| SoC that has a `<SoC vendor>-common` tree | `device/mainline/<vendor>-common` | SoC support is already there |
| Virtual machine | `device/virt/*` | Already done; no new tree needed |
| Anything else | `device/mainline/common` | You write the device-specific parts |

## SoC vendor trees

A `<SoC vendor>-common` tree sits on top of `mainline/common` and holds
everything specific to that vendor's SoCs. More of them may appear.

- Its docs live in its own repo: `device/mainline/<vendor>-common/docs/`.
- Vendor specifics (bootloader, firmware, daemons, SoC lists) are
  documented **there**, not in this guide.
- Currently available: `qcom-common`.

## How generic boots

`generic` is not tied to one boot method. Any way that boots the
kernel works, as long as the hardware is reachable through drivers.

| Platform | Examples |
|----------|----------|
| PC | UEFI, or legacy BIOS |
| SBC | The many bootloaders SBCs use |

## What each base gives you

| Base | Gives you | You still write |
|------|-----------|-----------------|
| `mainline/common` | Optional HAL system, sepolicy, common init, `libinit` | Everything device-specific |
| `mainline/<vendor>-common` | The above plus the vendor layer | See its docs |
| `mainline/generic` | Partition detection (`generic_init`) and hardware detection (`hardware_detect`) at boot | Usually nothing, only a kernel config |

## Per-device vs generic: how to pick

- Fixed hardware, one board: **per-device tree**. Everything is known at
  build time, so the image is smaller and simpler.
- Many different machines: **generic**.
- Unsure? Start per-device with `basic_x86_64_pc` as a model. You can
  switch later.

## Next

[Bringup overview](BRINGUP_OVERVIEW.md)
