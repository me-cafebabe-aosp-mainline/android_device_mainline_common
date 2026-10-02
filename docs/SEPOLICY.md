# SELinux policy

**TL;DR:** Boot permissive, collect denials, fix them in the right
layer, then switch to enforcing.

## The loop

```
boot permissive -> use the device -> collect avc -> fix policy -> repeat
                                                       |
                                           no new avc -> enforcing
```

| Step | How |
|------|-----|
| Permissive | `androidboot.selinux=permissive` (set by `TARGET_INITIAL_BRINGUP`) |
| Collect | `adb shell dmesg \| grep avc` and `adb logcat -b all \| grep avc` |
| Cover | Boot, adb, display, audio, camera, USB, Wi-Fi, sleep and wake, recovery |
| Enforce | Remove the permissive parameters, test again |

Collect **every** denial of a session, not only the first one.

## Where does a rule go?

| The rule is about | Put it in |
|-------------------|-----------|
| Something every mainline device needs | `device/mainline/common/sepolicy/vendor` |
| A common HAL | next to that module, e.g. `optional/<name>/sepolicy` |
| One SoC vendor | `<vendor>-common/sepolicy` (see that tree's docs) |
| One device | `$(DEVICE_PATH)/sepolicy` |

Ask: "would the next device with this hardware need it?" If yes, it
does not belong in your device tree (see
`hardware/mainline/common/docs/SCOPE.md`).

Add device policy with:

```
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor
```

## Rules of thumb

- Fix labels first (`file_contexts`, `genfs_contexts`), then add allows.
- Never add `allow ... self:capability *` style wide rules.
- A denial for a kernel object that is new in mainline (a netlink or
  `memfd` class) may need a policy capability. Look at
  `sepolicy/vendor/policy_capabilities` before adding rules.
- Do not use `permissive` domains in a release.

## Style check

Policy files are checked in review by
`build/tools/check_sepolicy.py`. It checks:

- 4-space indentation
- Section headings and their order
- Rule order inside a section
- Tabs in `*_contexts` files
- No Lineage-only macros in files meant for AOSP builds

Run it before you send a change (the maintainer runs builds; this
script is a plain check).

```
python3 device/mainline/common/build/tools/check_sepolicy.py <paths>
```

## Check

- [ ] No avc denial in a full test session
- [ ] No `permissive` leftovers
- [ ] `check_sepolicy.py` is clean
