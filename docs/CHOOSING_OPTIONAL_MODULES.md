# Choosing optional modules

**TL;DR:** The defaults in `optional/options.mk` are a good start.
Override a `TARGET_*` variable only when something does not work.

Full reference: `../optional/README.md`. This page tells you **what to
change first**.

## How selection works

1. `optional/options.mk` sets defaults with `?=`.
2. Your tree sets a variable in `device.mk`.
3. `optional/<dir>/product.mk` or `board.mk` reacts to it.

```
TARGET_AUDIO_HAL := default-aidl   # in your device.mk
```

Where you put the line does not matter, as long as it is in a makefile
that loads before `options.mk` is evaluated. The common makefiles are
inherited, so they load after your `device.mk` finishes (see
[how makefiles load](DEVICE_TREE_SKELETON.md#how-makefiles-load)).

| You want | Do |
|----------|----|
| Change a default for your device | Set the variable in `device.mk` |
| Try a value once | Set it in the environment: `TARGET_GRAPHICS=swiftshader m ...`. Works only if your device does not set it with `:=` |
| Read the defaults earlier | `include device/mainline/common/optional/options.mk` yourself |

## Design principles of the mainline HALs

Most mainline HALs (audio, camera, sensors, ...) are built to these
four rules. Their own `README.md` and `INITIAL_IMPLEMENTATION.md`
(`## Design`) give details.

| Principle | What it means for you |
|-----------|-----------------------|
| Configuration-less | They should work without any config. Do not add config the HAL can detect |
| Flexible | When config is needed, use Android properties, with selectors where a device has several parts |
| Generic | One HAL for phones, tablets, PCs, VMs |
| No crash without hardware | The HAL keeps answering when the hardware is absent (no sound card, no camera) |

So an absent device is **not** a reason to switch to another HAL.

## Old HALs and their replacements

Some HALs are old and not good; the mainline ones were added to replace
them. The old ones stay in `optional/` for compatibility. Do not pick
them for a new device.

| Area | Old | Use instead |
|------|-----|-------------|
| Audio | `tinyhal` (per-device config in its own format) | `mainline` |
| Sensors | `iio` | `mainline` |
| Camera | `libcamera` (a third party repo, not forked here) | `mainline`, unless the target needs something only libcamera supports |

`ffmpeg` Codec2 is also third party, not forked here.

## Rules for picking an option

1. **Default to the mainline implementation** where one exists.
2. **Use the more generic option for bringup.** It works on more
   hardware, so fewer things can be wrong while you get to a shell.
3. **Use the more mature option to finish bringup**, once the hardware
   is known to work.

Rule 1 applies first. Rules 2 and 3 are about the moment you are in.

## Generic for bringup, mature to finish

Pairs backed by `optional/options.mk`; `TARGET_INITIAL_BRINGUP` picks
the left column for you.

| Area | Variable | Bringup (generic) | Finishing (mature) |
|------|----------|-------------------|--------------------|
| Graphics | `TARGET_GRAPHICS` | `swiftshader` | `mesa` |
| Allocator | `TARGET_GRAPHICS_ALLOCATOR_HAL` | `gralloc_gbm_mesa` (only for `mesa` graphics) | `minigbm-upstream` if it works |
| Composer | `TARGET_GRAPHICS_COMPOSER_HAL` | `drmfb-composer` | `drm_hwcomposer` |
| Health | `TARGET_HEALTH_HAL` | `cuttlefish` | `default-aidl` if there is a battery |
| Power | `TARGET_SUPPORTS_SUSPEND` | `false` | `true` once suspend works |

`TARGET_USES_FRAMEBUFFER_DISPLAY := true` is the most generic display
path, for devices that only have a framebuffer.

## Defaults and when to change them

| Area | Variable | Default | Change it when |
|------|----------|---------|----------------|
| Audio | `TARGET_AUDIO_HAL` | `mainline` | Keep it, even with no sound card yet; it needs no audio policy file. Avoid `tinyhal`: it is old and needs per-device config in its own format |
| Audio UCM | `TARGET_AUDIO_MAINLINE_UCM_PROFILES` | `all` | Keep the image small: list your card(s) |
| Sensors | `TARGET_SENSORS_HAL` | `mainline` | Do not use `iio`; the mainline HAL replaces it and reads IIO itself |
| USB gadget | `TARGET_USB_GADGET_HAL` | `mainline` | |
| Vibrator | `TARGET_VIBRATOR_HAL` | `mainline` | No vibrator: `TARGET_HAS_VIBRATOR := false` |
| Light | `TARGET_LIGHT_HAL` | `lineage` | |
| Camera | `TARGET_CAMERA_PROVIDER_HAL` | `mainline` with `common-ext`, otherwise not set | Prefer `mainline`. `libcamera` only if the target explicitly needs something only libcamera supports. `emulated` to test |
| Media | `TARGET_MEDIA_C2_HAL` | not set: AOSP software codecs are used | `ffmpeg` is software only for now (may get hardware codecs later) and builds for ARM64 only |
| Wi-Fi | `TARGET_HOSTAPD_AND_WPA_SUPPLICANT_FORM` | `apex-aosp` | |

## Pick by stage

| Stage | Pick | Why |
|-------|------|-----|
| 4 Shell | `TARGET_INITIAL_BRINGUP := true` | Console-as-root, fbkeyboard, generic graphics |
| 5 Display | Keep the bringup column above | Works without GPU drivers |
| 5 Display, GPU works | `mesa` + `drm_hwcomposer` | Mature path |
| 6 Audio | `mainline` HAL | Configuration-less; set UCM profiles only to slim the image |
| 6 Sensors | `mainline` | Reads IIO and input |
| 6 Camera | `mainline` provider | Needs V4L2 or media controller nodes |
| 8 Done | Mature column, set explicitly | `TARGET_INITIAL_BRINGUP` is gone |

## Read the HAL's own README

HALs live in `hardware/mainline/common/interfaces/`. Each has a
README, and most have an `AGENTS.md`. Paths below are relative to that
directory unless noted.

| Area | README |
|------|--------|
| Audio | `audio/mainline/README.md` |
| Audio, S/PDIF and passthrough | `audio/mainline/spdif/README.md` |
| Audio effects (legacy wrapper) | `audio/effect/legacy/README.md` |
| Sensors | `sensors/mainline/README.md` |
| Sensors, backends | `sensors/mainline/backends/{iio,input,mock}/README.md` |
| Sensors, composite sensors | `sensors/mainline/composite/README.md` |
| Sensors, utilities | `sensors/mainline/utils/{common,hwdb}/README.md` |
| Sensors, older HAL | `sensors/mainline_orig/README.md` |
| Display, DRM composer | `graphics/composer/drmfb/README.md` |
| Display, DRM composer (HIDL) | `graphics/composer/drmfb-hidl/README.md` |
| Allocator, Mesa GBM | `graphics/allocator/gbm_mesa/README.md` |
| Allocator, framebuffer | `graphics/allocator/fb/README.md` |
| Vibrator | `vibrator/mainline/README.md` |
| Camera | `camera/mainline/INITIAL_IMPLEMENTATION.md`; the README is in `hardware/mainline/common-ext` |

Tools and libraries next to them, in `hardware/mainline/common/`:

| Component | README |
|-----------|--------|
| GRUB boot control | `grub/README.md` |
| Tablet input as touchscreen | `tablet2multitouch/README.md` |
| Touchscreen virtual keys | `ts_vkeys/README.md` |
| SMBIOS parser | `libraries/smbios-parser/README.md` |

USB gadget has no README yet; see its directory under `usb/gadget/`.
SoC vendor HAL READMEs are listed in that vendor tree's docs.

## Using the `-ext` modules

Set `MAINLINE_COMMON_PREFER_EXT_MODULES := true` to swap some modules
for the ones in `device/mainline/common-ext` (they get an `_ext`
value, e.g. `mainline_ext`). Without that repository the build warns
and keeps the common modules.

## SoC vendor options

`<SoC vendor>-common` trees add options of their own in
`<vendor>-common/optional/README.md`. Read that file in the tree you
use; the same rules apply.

## Adding a new optional module

Copy `optional/_template.mk` and follow the directory pattern
`optional/<name>/{board,product}.mk`. Document the variable in
`optional/README.md`.

## Check

- [ ] You can explain why each override exists (comment it)
- [ ] No leftover `TARGET_INITIAL_BRINGUP` defaults you depend on
