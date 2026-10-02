# Kernel patches

**TL;DR:** Kernels that are not the Android Common Kernel need up to
four patches, plus `use_memfd.rc` if there is no ashmem. Link to this
page from your device README instead of copying the table.

The patches here are findings so far. They only aim to make the device
basically usable, and the list is not strictly complete. Expect to find
more.

## Which do I need?

| Your kernel | Patches | `use_memfd.rc` |
|-------------|---------|----------------|
| ACK (`android-mainline`, LTS branches) | None | No |
| Community fork (hardware enablement on top of `torvalds/linux`, usually no Android specifics) | Table below | Only if it has no ashmem driver |
| Pristine `torvalds/linux` | Table below | **Yes** |

## Patch table (recent kernels)

Source: AOSP `kernel/common-patches`, branch `main-kernel`, directory
`android-mainline`.

| Patch | Fixes |
|-------|-------|
| `ANDROID: usb: gadget: configfs: Add Uevent to notify userspace` | USB in normal mode |
| `ANDROID: mm/memfd-ashmem-shim: Introduce shim layer` | Media codec |
| `ANDROID: mm: shmem: Use memfd-ashmem-shim ioctl handler` | Media codec |

After applying the shim patches, edit `mm/Kconfig`: in
`MEMFD_ASHMEM_SHIM`, remove the dependency on `ASHMEM_C`.

URLs:
`https://android.googlesource.com/kernel/common-patches/+/refs/heads/main-kernel/android-mainline/<patch-name>.patch`

## `use_memfd.rc`

| | |
|-|-|
| What | Sets `sys.use_memfd` to `true` when `load-bpf-programs` runs |
| Why | Pristine kernels have no ashmem driver, so userspace must use memfd |
| Where | `kernel/mainline/configs/init/use_memfd.rc` |
| How | Add `use_memfd.rc` to `PRODUCT_PACKAGES`. The module is defined in `kernel/mainline/configs`, so add that to `PRODUCT_SOONG_NAMESPACES` for this module only; config fragments do not need it |

## Android platform patches

Not kernel, but needed with new kernels.

| Repo | Patch | Fixes |
|------|-------|-------|
| `packages/modules/Connectivity` | `jniClatCoordinator: Do not crash on BPF SELinux context mismatch` | Boot on v7.2+ kernels |

Gerrit: `https://review.lineageos.org/c/LineageOS/android_packages_modules_Connectivity/+/494663`

## Older kernels (v6.1)

| Patch | Fixes |
|-------|-------|
| `ANDROID: extract-cert: omit PKCS#11 support if building against BoringSSL` | Build |
| `Revert "staging: remove ashmem"` | Boot |
| `ANDROID: usb: gadget: configfs: Add Uevent to notify userspace` (the `NOUPSTREAM-` variant) | USB in normal mode |

Pin the exact commit in the URL.

## In your device README

Only list **device-specific** patches. For the shared ones, write:

> Apply the patches in
> `device/mainline/common/docs/KERNEL_PATCHES.md`.
