# Bringup overview

**TL;DR:** Get to a shell first, then add features one at a time.
Set `TARGET_INITIAL_BRINGUP := true` until stage 7.

## Before you start

Look at how Linux distributions that already support your device do
it (for example postmarketOS). Follow them for the kernel config,
device tree, firmware list, cmdline and bootloader steps. Skip the
parts that only work on GNU/Linux.

## Stages

```
 1 Skeleton  ->  2 Kernel boots  ->  3 init runs  ->  4 Shell + adb
                                                          |
 8 Done  <-  7 SELinux enforcing  <-  6 Hardware  <-  5 Display
```

| # | Stage | Exit criteria | Page |
|---|-------|---------------|------|
| 1 | Skeleton | `lunch` works, `m` finishes | [Skeleton](DEVICE_TREE_SKELETON.md) |
| 2 | Kernel boots | Kernel log is visible (serial or screen) | [Kernel](KERNEL.md), [Boot](BOOT_AND_PARTITIONS.md) |
| 3 | init runs | First-stage init mounts `/system` and `/vendor` | [Boot](BOOT_AND_PARTITIONS.md) |
| 4 | Shell + adb | `adb shell` works, or serial console as root | [Debugging](DEBUGGING.md) |
| 5 | Display | Boot animation shows | [Optional modules](CHOOSING_OPTIONAL_MODULES.md) |
| 6 | Hardware | Touch, audio, Wi-Fi, ... (one by one) | [Optional modules](CHOOSING_OPTIONAL_MODULES.md) |
| 7 | SELinux enforcing | No denials in a normal session | [SEPolicy](SEPOLICY.md) |
| 8 | Done | `TARGET_INITIAL_BRINGUP` removed, README written | [Template](DEVICE_README_TEMPLATE.md) |

## What `TARGET_INITIAL_BRINGUP` does

Set it in `device.mk`, or in `BoardConfig.mk` above the `include` of the
common board file (see
[how makefiles load](DEVICE_TREE_SKELETON.md#how-makefiles-load)).

| Area | Effect |
|------|--------|
| Kernel cmdline | `audit=0`, `panic=-1` |
| Boot config | `androidboot.selinux=permissive`, `androidboot.boot_devices=any` |
| Console | `TARGET_CONSOLE_AS_ROOT` defaults to `true` |
| Input | `TARGET_ENABLE_FBKEYBOARD` defaults to `true` |
| Graphics | `TARGET_GRAPHICS` defaults to `swiftshader`, composer to `drmfb-composer` |
| Health | `TARGET_HEALTH_HAL` defaults to `cuttlefish` |
| Power | `TARGET_SUPPORTS_SUSPEND` defaults to `false` |

The build prints a warning while it is set. That is the reminder.

## Rules of thumb

- Change **one** thing per build.
- Keep a log of the serial console for every boot.
- Commit every working stage. Easy to go back.
- Do not tune hardware before stage 4.
- Remove `TARGET_INITIAL_BRINGUP` only when the table in each stage
  is satisfied; then set the real values by hand.
- Option rules: default to **mainline** implementations, use the
  **generic** option for bringup, and the **mature** option to finish
  (see [Optional modules](CHOOSING_OPTIONAL_MODULES.md)).

## Checklist to leave bringup

- [ ] `androidboot.boot_devices` set to the real device
- [ ] SELinux is enforcing, no denials in normal use
- [ ] Graphics HALs set explicitly: the mature option, not the bringup one
- [ ] Suspend decided (`TARGET_SUPPORTS_SUSPEND`)
- [ ] Health HAL decided
- [ ] README written
