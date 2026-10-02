# libinit and init scripts

**TL;DR:** Device init is: one `init.<device>.rc`, one `ueventd`
file, and (if needed) a tiny `libinit` that sets properties.

## What you write

| File | Installed to | Role |
|------|--------------|------|
| `init.<device>.rc` | `/vendor/etc/init/hw/` | Load modules, mount partitions |
| `init.recovery.<device>.rc` | `/system/etc/init/` (recovery) | Same, for recovery |
| `ueventd.<device>.rc` | `/vendor/etc/` | Device nodes, firmware dirs |
| `libraries/libinit/` | built into init | Set properties at boot |

Install them through `Android.bp` `prebuilt_etc` and add the names to
`PRODUCT_PACKAGES`. See `basic_x86_64_pc/configs/Android.bp`.

## `init.<device>.rc`

Start from this; `basic_x86_64_pc` has a real one:

```
import /vendor/etc/init/hw/init.mainline.rc     # the common one

on post-fs
    exec u:r:vendor_modprobe:s0 -- /vendor/bin/modprobe -s -d /vendor/lib/modules --all=/vendor/etc/modules.load.normal

on fs
    mount_all /vendor/etc/fstab.<name> --early

on late-fs
    mount_all /vendor/etc/fstab.<name> --late
```

| Trigger | Typical use |
|---------|-------------|
| `on fs` | `mount_all --early`: partitions without `latemount` |
| `on post-fs` | Load kernel modules |
| `on late-fs` | Mount partitions that need fsck |
| `on property:...` | Reactions, like unbinding the VT console after boot |

When the fstab is not named after `androidboot.hardware`, pass it:
`mount_all /vendor/etc/fstab.<name> --early`.

## `ueventd.<device>.rc`

```
firmware_directories /vendor/firmware/ /odm/firmware/
modalias_handling enabled
```

Common device entries (IIO, rfkill, dma-heap) are already in
`device/mainline/common/init/ueventd.rc`.

## `libinit`

`init` can call two functions from your library:

| Function | When | Use |
|----------|------|-----|
| `vendor_process_bootenv()` | After init read DT, bootconfig and cmdline properties, before they are exported | Boot-parameter driven behaviour |
| `vendor_load_properties()` | Property load | Set `ro.*` properties |

Skeleton:

```cpp
void vendor_process_bootenv() {
    vendor_process_bootenv_mainline_common();
}

void vendor_load_properties() {
    vendor_load_properties_mainline_common();
    set_prop_from_file("ro.serialno", "/sys/devices/virtual/dmi/id/product_serial");
}
```

Hook it up:

```
$(call soong_config_set,libinit,vendor_init_lib,//$(DEVICE_PATH):init_<device>)
```

and add a `cc_library_static` in `Android.bp` using the
`init_mainline_common_defaults`.

### Helpers you get

`libinit_utils.h`, `libinit_mainline_common.h`: `property_override`,
`set_ro_build_prop`, `set_prop_from_file`, ...

### Switches

| Soong config | Values | Effect |
|--------------|--------|--------|
| `mainline_common_libinit` `set_properties_from` | `devicetree`, `dmi_id`, `both` | Fill model/manufacturer props from that source |
| `mainline_common_libinit` `set_dalvik_heap` | `false` | Do not set the Dalvik heap |

Set with `$(call soong_config_set,mainline_common_libinit,set_properties_from,dmi_id)`.

## Do not rely on `libinit`

`libinit` is built into `init`, which lives in the **system** image.
Anything the vendor side needs from it makes system depend on your
device. That breaks Project Treble rules and makes GSIs unbootable.

- Keep it small: derive a few properties, nothing more.
- Put device behavior in vendor files (`init.<device>.rc`, props,
  fstab) instead.

## Do you need your own `libinit`?

| Situation | Need? |
|-----------|-------|
| PC with DMI | No: use `set_properties_from dmi_id` |
| Phone, serial number from sysfs | Yes, tiny |
| Nothing special | No |

## References

| What | Where |
|------|-------|
| `.rc` syntax | `system/core/init/README.md` |
| `ueventd.rc` syntax | `system/core/init/README.ueventd.md` |
| Platform `.rc` files | `system/core/rootdir/` |
| Boot parameters of `generic_init` | `device/mainline/generic/docs/boot-parameters.md` |

## Check

- [ ] Kernel modules load (`lsmod` or modprobe log)
- [ ] `getprop ro.product.model` is sane
