# Device README template

**TL;DR:** Copy the block below to your device tree `README.md`.
Delete sections that do not apply. Keep each one a table or a list.

Do **not** copy the shared kernel patch table; link to
[KERNEL_PATCHES.md](KERNEL_PATCHES.md).

```markdown
# Android device tree for <Vendor> <device> running mainline kernel

<One or two sentences: what the device is, what works.>

## Status

| Feature | Works | Notes |
|---------|-------|-------|
| Boot | yes | |
| Display | yes | |
| Touch | | |
| Audio | | |
| Wi-Fi / Bluetooth | | |
| Camera | | |
| Modem | | |
| Charging | | |

## Before flashing the Android build

1. <Bootloader step, e.g. erase `dtbo`>
2. <Install the bootloader build>

## Additional repositories required to build

| Path | Source |
|------|--------|
| kernel/mainline/<name> | <URL> (branch: `<branch>`) |
| vendor/<vendor>/<device> | <how to extract blobs> |

## Android platform patches

| Commit name | Purpose | Source |
|-------------|---------|--------|

## Kernel

Apply the patches in
`device/mainline/common/docs/KERNEL_PATCHES.md`.

Device specific:

| Commit name | Purpose | Source |
|-------------|---------|--------|

## Build

    breakfast <device>
    m <targets>

## Install

<Flash or copy steps.>

## Known issues

- <Issue and workaround.>
```

## Rules

| Do | Don't |
|----|-------|
| One table per topic | Long paragraphs |
| Pin kernel branch names | "latest" |
| Say what a patch fixes | List a patch without purpose |
| Warn about legal issues (firmware) | Ship non-redistributable files |
| Update on every kernel bump | Let it rot |

## Examples

| README | Good for |
|--------|----------|
| `device/pc/basic_x86_64_pc` | Boot steps without a bootloader image |
| A device README in your SoC vendor tree | Closest match for your hardware |
