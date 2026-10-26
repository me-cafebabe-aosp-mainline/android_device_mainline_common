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
| Collect | [`selogger`](#collect-with-selogger), or `adb shell dmesg \| grep avc` and `adb logcat -b all \| grep avc` |
| Cover | Boot, adb, display, audio, camera, USB, Wi-Fi, sleep and wake, recovery |
| Enforce | Remove the permissive parameters, test again |

Collect **every** denial of a session, not only the first one.

## Collect with selogger

**TL;DR:** set `TARGET_ENABLE_SELOGGER := true` and let the device
collect the denials. It writes sepolicy you review, instead of you
reading `avc` lines.

`tools/selogger` is a separate repository, and its `README.md` is the
manual. It must be in the source tree. The option installs the daemon on
`userdebug` and `eng` builds only, and adds its sepolicy to the vendor
policy.

| Step | How |
|------|-----|
| Collect | Use the device; the daemon keeps each kind of denial once, with counters, across reboots |
| Dump | `adb shell selogger dump`, then `adb pull /data/local/tmp/selogger-dump` |
| Read | `REVIEW.md` of the dump first: it lists what needs a decision |
| Merge | `tools/selogger/scripts/selogger_expand.py --pull --sepolicy-dir <your sepolicy/vendor>` (`--dry-run` first) |
| Build, repeat | Rebuild, collect again |

What it gives you:

- Rules written with `te_macros` macros, and label proposals
  (`file_contexts`, `genfs_contexts`, `property_contexts`, ...) for
  targets that only have a fallback label, so you do not allow
  everything of `default_prop` or `vendor_file`.
- Output in the style `check_sepolicy.py` expects.

What it does not do:

- It does not decide. The rules are a starting point, and a denial is as
  often a missing label or a bug as a missing rule.
- The kernel drops denials beyond its rate limit (selogger raises it
  while collecting; `status` shows `kernel_lost`), and an enforcing
  process usually stops at its first denial. Collect with the domain you
  work on in `permissive`, then tighten.
- `dontaudit` rules hide denials, and `neverallow` rules are only known
  to the build.

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
- [ ] `selogger` reports nothing new in a full session (if you use it)
