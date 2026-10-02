# Debugging

**TL;DR:** First get any console. Then use the table below.

More techniques: `device/mainline/generic/docs/debugging.md`.

## Get a console

| Method | How |
|--------|-----|
| Serial | `console=ttyXXX,115200n8` in the cmdline |
| Screen | `console=tty0`, `TARGET_ENABLE_FBKEYBOARD` for touch input |
| Root shell on console | `TARGET_CONSOLE_AS_ROOT := true` (default in bringup) |
| logcat on serial | `TARGET_ENABLE_LOGCAT_TO_SERIAL` and `androidboot.seriallogging=<tty>` |
| Insecure adb | `androidboot.insecure_adb=1`, or create `/metadata/.enable_insecure_debugging` |
| No kernel panic reboot | `panic=-1` (bringup default) |

## Stuck at X

| Symptom | Likely cause | Check |
|---------|--------------|-------|
| Nothing after the bootloader | Kernel not loaded, wrong image or offset | Bootloader log, boot header version, DTB |
| Kernel starts, no output | No console in cmdline, display driver missing | `console=`, serial |
| Kernel panics: no root | Ramdisk missing or storage driver missing | Modules in ramdisk, `modules.load.basic` |
| `Failed to mount /system` | Wrong `boot_devices` or `partition_map` | `androidboot.boot_devices`, fstab names |
| System components misbehave early, `/metadata` not mounted | Partition or fstab entry missing: `aconfigd` uses `/metadata`, and many components rely on `aconfigd` | `mount \| grep metadata`, fstab, `aconfigd` in logcat |
| init reboots to recovery | Fatal service failed | `androidboot.init_fatal_reboot_target`, serial log |
| Loops on `CanQuitUeventd` | Install problem (generic only) | `generic/docs/porting.md` |
| Boot animation never shows | No composer or allocator, **or Mesa and the graphics card** (no driver, no render node) | `TARGET_GRAPHICS*`; `ls /dev/dri`; `dmesg` for DRM and GPU; compare with `swiftshader` + `drmfb-composer` to separate GPU problems from the rest |
| Black screen, system alive | Display driver or backlight | `adb logcat`, `ls /sys/class/backlight` |
| adb not visible | USB gadget | Kernel patches in [KERNEL_PATCHES.md](KERNEL_PATCHES.md), USB HAL |
| Media crashes | Missing ashmem or memfd | `use_memfd.rc`, kernel patches |
| Services crash with avc | SELinux | [SEPOLICY.md](SEPOLICY.md) |
| No audio | UCM profile or card not found | `TARGET_AUDIO_MAINLINE_UCM_PROFILES`, HAL README |
| No touch | Driver, or name mismatch | `getevent -lp`, `ts_vkeys` docs |

## Logs to collect before asking for help

- [ ] Full kernel log (`dmesg` or serial)
- [ ] `logcat -b all`
- [ ] Your `BOARD_KERNEL_CMDLINE`
- [ ] Which stage you are at
- [ ] Which commit of the tree and kernel

## Tools

| Need | Tool |
|------|------|
| Check kernel config | `kernel/mainline/configs/utilities/validate_kernel_config.py` |
| Check init `.rc` syntax | `system/core/init/README.md` |
| Check fstab parsing | `system/fs/fs_mgr/libfstab/fstab.cpp` |
