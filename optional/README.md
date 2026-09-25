## A/B

### TARGET_USES_MAINLINE_COMMON_AB_DEFS
| Value | Directory | Description |
|-------|-----------|-------------|
| true | ab | Enable A/B definitions from mainline/common |

## Audio

### TARGET_AUDIO_HAL
| Value | Directory | Description |
|-------|-----------|-------------|
| baylibre | audio-hal_baylibre | Based on `default-aidl`, updated by BayLibre with better configuration |
| default-aidl | audio-hal_default-aidl | Usable on targets without any sound card or with a simple sound card |
| mainline | audio-hal_mainline | Audio AIDL HAL that is built upon alsa-lib and alsa-ucm-conf. Check out `hardware/mainline/common/interfaces/audio/mainline/README.md` for details. |
| ranchu | audio-hal_ranchu | Similar to `default-aidl`, but the interface type is HIDL instead of AIDL |
| tinyhal | audio-hal_tinyhal | For targets with complicated sound card. Requires per-board configuration. |

### TARGET_AUDIO_EFFECT_HAL
| Value | Directory | Description |
|-------|-----------|-------------|
| legacy | audio-effect-hal_legacy | AIDL wrapper for libeffects. It's used with custom made Audio AIDL HAL APEXes mainly because the AIDL Audio Effects modules in AOSP have `visibility` restriction by default. Cannot be used with HIDL Audio HAL. |

### TARGET_AUDIO_POLICY
| Value | Directory | Description |
|-------|-----------|-------------|
| common-handheld-7.0 | audio-policy_common-handheld-7.0 | For common handheld devices. Requires the target to provide `primary_audio_policy_configuration.xml`. |
| cuttlefish | audio-policy_cuttlefish | Used with `TARGET_AUDIO_HAL=default-aidl` |

#### TARGET_PROVIDES_AUDIO_POLICY_VOLUMES
| Value | Description |
|-------|-------------|
| false | Default `audio_policy_volumes.xml` will be copied and default AOSP values will be used |
| true | The downstream device tree must provide `/vendor/etc/audio_policy_volumes.xml` |

#### TARGET_PROVIDES_BLUETOOTH_AUDIO_POLICY
| Value | Description |
|-------|-------------|
| false | Default `bluetooth_audio_policy_configuration_7_0.xml` will be copied to use the software Bluetooth audio AIDL |
| true | Default `/vendor/etc/bluetooth_audio_policy_configuration_7_0.xml` will not be copied to allow the usage of Bluetooth audio hardware offload |

## Bluetooth

### TARGET_BLUETOOTH_HAL
| Value | Directory | Description |
|-------|-----------|-------------|
| default-aidl | bluetooth-hal_default-aidl | HCI-based Bluetooth AIDL HAL |

## Boot

### TARGET_BOOT_HAL
| Value | Directory | Description |
|-------|-----------|-------------|
| default | boot-hal_default | Boot control HAL that uses Android Bootloader Control Block (BCB) as backend. Note that this usually won't make sense on targets that has its own way of handling A/B slot select. |
| grub | boot-hal_grub | Boot control HAL that is designed to work with GRUB boot manager. Note that GRUB itself does not directly support this, the bootloader side boot control handling should be implemented via GRUB configuration file. |

## Camera

### TARGET_CAMERA_PROVIDER_HAL
| Value | Directory | Description |
|-------|-----------|-------------|
| emulated | camera-provider-hal_emulated | Emulated Camera Provider HAL located at `hardware/google/camera/devices/EmulatedCamera` |
| libcamera | camera-provider-hal_libcamera | https://gitlab.baylibre.com/baylibre/ti/android/aosp/external/libcamera https://gitlab.baylibre.com/baylibre/ti/android/aosp/device/ti/am62x |
| mainline | camera-provider-hal_mainline | V4L2 camera provider for internal and external (USB, HDMI capture) cameras. Handles external cameras itself, so it can not be combined with `TARGET_EXTERNAL_CAMERA_PROVIDER_HAL`. Check out `hardware/mainline/common/interfaces/camera/mainline/README.md` for details. |

### TARGET_CAMERA_PROVIDER_HAL_MAINLINE_HWDB
| Value | Description |
|-------|-------------|
| true | Default value, install the systemd camera hwdb (`70-cameras.hwdb`) for `TARGET_CAMERA_PROVIDER_HAL=mainline` |
| false | Do not install it; the target may provide its own in `/vendor/etc/camera/hwdb.d/` |

### TARGET_SUPPORTS_EXTERNAL_CAMERAS
| Value | Description |
|-------|-------------|
| false | Default value, the target does not support external V4L2 cameras |
| true | The target supports external V4L2 cameras, `TARGET_EXTERNAL_CAMERA_PROVIDER_HAL` will be set to `default-aidl` |

### TARGET_EXTERNAL_CAMERA_PROVIDER_HAL
| Value | Directory | Description |
|-------|-----------|-------------|
| default-aidl | external-camera-provider-hal_default-aidl | https://source.android.com/docs/core/camera/external-usb-cameras |

### TARGET_EXTERNAL_CAMERA_PROVIDER_HAL_USE_EXAMPLE_CONFIG
| Value | Description |
|-------|-------------|
| true | Default value, use the example configuration |
| false | The target will have to provide `/vendor/etc/external_camera_config.xml` |

## Display

### TARGET_ENABLE_BOOTSPLASH
| Value | Directory | Description |
|-------|-----------|-------------|
| true | bootsplash | Install the optional early DRM/fbdev bootsplash in system_ext. If fbkeyboard is installed, request its stop before starting the splash. The device supplies `/product/etc/bootsplash.bmp` if a static fallback is wanted. |

## Graphics

### TARGET_GRAPHICS
| Value | Directory | Description |
|-------|-----------|-------------|
| mesa | mesa | Typically for targets that supports 3D acceleration |
| swiftshader | swiftshader | For targets without 3D acceleration |

### TARGET_GRAPHICS_EGL
| Value | Directory | Description |
|-------|-----------|-------------|
| angle | angle | An EGL implementation that uses the Vulkan HAL to provide OpenGL ES |
| mesa | mesa | Typically for targets that supports 3D acceleration |

### TARGET_GRAPHICS_VULKAN
| Value | Directory | Description |
|-------|-----------|-------------|
| mesa | mesa | Typically for targets that supports Vulkan acceleration |
| swiftshader | swiftshader | For targets without Vulkan support |

## Graphics HALs

### TARGET_GRAPHICS_ALLOCATOR_HAL
| Value | Directory | Description |
|-------|-----------|-------------|
| default-hidl-2.0 | graphics-allocator-hal_default-hidl-2.0 | Supports framebuffer display |
| gbm | gbm_gralloc | Android gralloc libhardware module using libgbm API from Mesa |
| gralloc_gbm_mesa | gralloc_gbm_mesa | Standalone Mesa GBM Gralloc HAL, using AIDL interface. |
| minigbm | minigbm | May require additional build flags |
| minigbm-upstream | minigbm-upstream | Upstream variant of minigbm, with our additions. Requires targets configuring its soong config variables directly. |

### TARGET_GRAPHICS_COMPOSER_HAL
| Value | Directory | Description |
|-------|-----------|-------------|
| default-hidl-2.2 | graphics-composer-hal_default-hidl-2.2 | Supports framebuffer display |
| drm_hwcomposer | drm_hwcomposer | Generic DRM HWComposer |
| drmfb-composer | drmfb-composer | Refer to hardware/mainline/common/interfaces/graphics/composer/drmfb/README.md |

### TARGET_MEMTRACK_HAL
| Value | Directory | Description |
|-------|-----------|-------------|
| default-aidl | memtrack-hal_default-aidl | |

### TARGET_USES_FRAMEBUFFER_DISPLAY
| Value | Directory | Description |
|-------|-----------|-------------|
| true | graphics-hals_fb | Enables Framebuffer Graphics AIDL HALs. |

## Health

### TARGET_HEALTH_HAL
| Value | Directory | Description |
|-------|-----------|-------------|
| cuttlefish | health-hal_cuttlefish | For devices without battery |
| default-aidl | health-hal_default-aidl | For devices with a battery accessible through /sys/class/power_supply |

## Input

### TARGET_TOUCHSCREEN_HAS_VIRTUAL_KEYS
| Value | Directory | Description |
|-------|-----------|-------------|
| true | ts_vkeys | Enables support for touchscreen virtual keys. It reads touchscreen input events, registers a uinput device, and sends EV_KEY events to the uinput device. Requires the target to provide properties to function. |

### TARGET_USES_TABLET_INPUT_AS_TOUCHSCREEN
| Value | Directory | Description |
|-------|-----------|-------------|
| true | tablet2multitouch | A program that creates a virtual touchscreen, converting input events from a tablet input device, effectively allowing to use tablet input devices as touchscreen. To use this, blacklist the source tablet input device names via `/vendor/etc/excluded-input-devices.xml` file for system, and `ro.minui.blacklist_input_devices` property for LineageOS Recovery, and specify the source tablet input device names via `vendor.tablet2multitouch.device_names` property (separated by `,`) |

## Kernel

### TARGET_PREBUILT_KERNEL
| Value | Directory | Description |
|-------|-----------|-------------|
| * | prebuilt_kernel | Path to the prebuilt kernel image |

### TARGET_KERNEL_MIXED_MODE
| Value | Directory | Description |
|-------|-----------|-------------|
| true | prebuilt_kernel | Kernel was built in gki mixed mode |
| false | prebuilt_kernel | Kernel was not built in gki mixed mode, requiring module signature workarounds |

## Level

### TARGET_FOLLOWS_LATEST_SHIPPING_API_LEVEL
| Value | Directory | Description |
|-------|-----------|-------------|
| true | shipping-api-level_latest | Follows latest shipping API level. |

### TARGET_FOLLOWS_LATEST_VINTF_TARGET_LEVEL
| Value | Directory | Description |
|-------|-----------|-------------|
| true | vintf-target-level_latest | Follows latest VINTF target-level. |

## Light

### TARGET_LIGHT_HAL
| Value | Directory | Description |
|-------|-----------|-------------|
| lineage | light-hal_lineage | Supports most of generic backlight and LED devices |

#### TARGET_LIGHT_HAL_SCAN_FOR_BACKLIGHT_DEVICES
| Value | Description |
|-------|-------------|
| false | Light HAL will not scan for backlight devices. Backlight may be handled by graphics composer HAL instead. |
| true | Light HAL will scan for backlight devices. Useful if light HAL is supposed to handle backlight and it could not find the backlight device by default. |

## Logging

### TARGET_ENABLE_LOGCAT_TO_SERIAL
| Value | Directory | Description |
|-------|-----------|-------------|
| true | logcat-to-serial | Enable support for printing logcat messages over serial console. Specify the serial console device to use via property `ro.boot.seriallogging` or property `ro.vendor.seriallogging` or boot parameter `androidboot.seriallogging`. |

## Media

### TARGET_MEDIA_C2_HAL
| Value | Directory | Description |
|-------|-----------|-------------|
| ffmpeg | media-c2-hal_ffmpeg | Codec2 AIDL HAL using ffmpeg as backend. Imported from [raspberry-vanilla](https://github.com/raspberry-vanilla). |
| v4l2_codec2 | v4l2_codec2 | Refer to external/v4l2_codec2/README.md |

## Miscellaneous

### TARGET_CONSOLE_AS_ROOT
| Value | Directory | Description |
|-------|-----------|-------------|
| true | console-as-root | Runs the `console` service as root user, in `u:r:su:0` SELinux domain. Useful for debugging via console. |

### TARGET_ENABLE_FBKEYBOARD
| Value | Directory | Description |
|-------|-----------|-------------|
| true | fbkeyboard | Shows a virtual keyboard on the first framebuffer device. Useful for interacting with framebuffer console on touchscreen devices. |

## Power

### TARGET_POWER_HAL
| Value | Directory | Description |
|-------|-----------|-------------|
| default-aidl | power-hal_default-aidl | |
| perfmgr-lineage | power-hal_perfmgr-lineage | Lineage perfmgr hal, requires device to provide powerhint.json file as module with the filename being module name. |

### TARGET_SUPPORTS_SUSPEND
| Value | Directory | Description |
|-------|-----------|-------------|
| false | suspend_blocker | Disables suspend |

## Recovery mode

### TARGET_ENABLE_RECOVERY_ETHERNET_DHCP
| Value | Directory | Description |
|-------|-----------|-------------|
| true | recovery-ethernet-dhcp | Configure IPv4 address on ethernet interface via DHCP in recovery mode. Defaults to `eth0` interface, can be changed via property `vendor.recovery.ethernet.dhcp.iface`. |

## Security

### TARGET_GATEKEEPER_HAL
| Value | Directory | Description |
|-------|-----------|-------------|
| software-aidl | gatekeeper-hal_software-aidl | |

### TARGET_SECURITY_KEYMINT_HAL
| Value | Directory | Description |
|-------|-----------|-------------|
| default | keymint-hal_default | |

## Sensors

### TARGET_SENSORS_HAL
| Value | Directory | Description |
|-------|-----------|-------------|
| cuttlefish | sensors-hal_cuttlefish | Emulated sensors HAL. Command `cuttlefish_sensor_injection` can be used to inject sensor values. |
| iio | sensors-hal_iio | Support sensors that exposes IIO interface. |
| mainline | sensors-hal_mainline | Sensors HAL that exactly matches with mainline kernel usecase by design. Multiple backends are supported, and more backends can be added later. |

## Thermal

### TARGET_THERMAL_HAL
| Value | Directory | Description |
|-------|-----------|-------------|
| linaro-libpm | thermal-hal_linaro-libpm | |

## TV - HDMI

### TARGET_TV_HDMI_CEC_HAL
| Value | Directory | Description |
|-------|-----------|-------------|
| baylibre | tv-hdmi-cec-hal_baylibre | Generic AIDL CEC HAL by BayLibre |

## USB

### TARGET_USB_HAL
| Value | Directory | Description |
|-------|-----------|-------------|
| lineage-basic | usb-hal_lineage | |
| lineage-dual_role_usb | usb-hal_lineage | |
| lineage-typec | usb-hal_lineage | |

### TARGET_USB_GADGET_HAL
| Value | Directory | Description |
|-------|-----------|-------------|
| mainline | usb-gadget-hal_mainline | |

### TARGET_USB_INIT_SCRIPT
| Value | Directory | Description |
|-------|-----------|-------------|
| mainline | usb-init-script_mainline | |

## Vibrator

### TARGET_VIBRATOR_HAL
| Value | Directory | Description |
|-------|-----------|-------------|
| glodroid | vibrator-hal_glodroid | Supports generic FF class vibrator devices |
| mainline | vibrator-hal_glodroid | Supports generic FF class vibrator devices, and is more properly implemented |

## Wi-Fi

### TARGET_ENABLE_VIRT_WIFI
| Value | Directory | Description |
|-------|-----------|-------------|
| true | virt_wifi | Enable support for creation of virtual Wi-Fi interface with MAC address prefix specified by property `ro.boot.wifi_mac_prefix` based on a ethernet interface specified via property `ro.vendor.virtwifi.port` (defaults to `eth0`). This requires `CONFIG_VIRT_WIFI` to be enabled in the kernel. The service should be started by device-specific init rc. After this starts to function, the ethernet interface will become unavailable to the others. |

### TARGET_HOSTAPD_AND_WPA_SUPPLICANT_FORM
| Value | Description |
|-------|-------------|
| legacy | Installs to `/vendor/bin/hw` directory, and loads configuration files from `/vendor` base path. |
| apex-aosp | Installs to `com.android.hardware.wpa_supplicant` APEX, and loads configuration files from the APEX. This APEX includes a default wpa_supplicant configuration file. |
| apex-mainline_common | Similar to `apex-aosp`, however expects the target to specify to include its own configuration files (as soong prebuilt_etc modules) via soong config variable (namespace: `mainline_common_apex_wpa_supplicant`, variable: `include_prebuilts`, type: `string_list`). |
