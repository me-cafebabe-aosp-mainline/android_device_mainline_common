# Choosing the kernel branch: ACK or pristine mainline

**TL;DR:** for a device you want to **ship**, we recommend the Android
Common Kernel (ACK) branch of the Android release you target. Pristine
mainline is for bringup, generic targets and upstream work. This page
is a recommendation, not a rule: it explains the trade-offs so you can
decide for your device.

## Recommendation

| Goal | Recommended kernel |
|------|--------------------|
| Ship a device | The ACK **LTS** branch that matches the Android release (for example the `6.18` ACK for Android 17) |
| Bring a device up, or work on upstream support | Pristine mainline, or the SoC community fork, then move to the ACK when the drivers are in it |
| Generic targets (`device/mainline/generic`, PCs, VMs) | Whatever boots; they are not tied to an ACK |
| Desktop-like devices | ACK works too; pristine mainline is acceptable by exception |

Cuttlefish and ranchu, Google's official Android emulators for
development, run on the ACK and emulate every kind of Android device.
They are a way to test the Android side on an ACK without your hardware.

Why not ship a non-LTS or a too-new kernel:

- No long-term security patch branches. You would maintain the
  backports yourself, on every device.
- Features Android expects can land in the ACK late in the cycle (fuse-bpf
  is an example), so a brand new LTS may not pass VTS before the next
  major Android release.
- A change in mainline can break Android initialization, or booting
  altogether. `android-mainline` sees and reverts such changes; pristine
  mainline does not.

## What each option costs

| | ACK `gki_defconfig` + device fragment | Pristine mainline or community fork |
|---|---|---|
| Android patches | Already in | Applied from [KERNEL_PATCHES.md](KERNEL_PATCHES.md), once, shared by all devices |
| Config upkeep | One fragment per LTS; it changes a little as mainline shuffles, it is not a rewrite | Shared Android fragments, but the device config still needs care on every update |
| Security fixes | Google's patch branches | Upstream LTS only |
| Hardware support | Only what is in the ACK or what you backport | Whatever the upstream maintainers keep working |
| Where the effort goes | Per device: patches, fragment | Once for all devices: the Android fixes |
| Shippable | Yes | Generic and desktop targets only (recommended) |

The trade-off is real. With a wide range of devices, handling the
Android issues once in shared trees is cheaper than keeping a
per-device fragment correct on every update, and the hardware itself is
guaranteed by upstream maintainers. With a single device that is meant
to ship, security branches and Android compliance outweigh that.

## Timing

- Plan by **cycles**. A device whose drivers merged in mainline version
  N is waiting for the next LTS, which becomes an ACK branch (the
  upstream drivers are carried into it automatically). It targets the
  Android release that uses that ACK.
- A device can be usable on the next LTS before it passes VTS or has the
  features of the release. Working on the not-yet-released ACK branch is
  good preparation, but expect rough edges until the release branch
  forks.
- Patches that will never go upstream stay yours. Keep them in the
  device's kernel branch and carry them across updates.
- Carry your own patches that are still under upstream review in the
  kernel branch until they are merged, then drop them with the next
  kernel update. This should not last more than a couple of releases.

## Bringup tips for any kernel

Making a config for a device from scratch is the most painful part of
the work. These tips cost less than guessing.

| Problem | What to do |
|---------|------------|
| Which options does this device need? | Start from the config of a distribution that supports it ([Kernel](KERNEL.md)). Without one: collect every `compatible` string from the device's `.dts` and its includes, search for each under `drivers/`, and add the matching option to the fragment, unless it is already built in |
| Driver enabled but the device does not probe | Look for a hardware dependency: a supplier (regulator, clock, interconnect, power domain) that is not enabled, or a remote processor that must run first. A sound card that needs the audio DSP running is the typical case |
| Boot breaks after enabling hardening options | Turn the hardening options off first, then bisect; some of them break early boot |
| Kernel crashes before any log | Get a log first: serial, `earlycon`, or a pstore/ramoops area. Without it nothing else is debuggable |
| Build, flash, test loop takes hours | Change one thing per iteration, keep the working config under version control, and use `modules.load.basic` for serial first |

Do this once per device and per LTS; later updates are small diffs.

## Related

- [Kernel](KERNEL.md): config approaches, fragments and variables
- [Kernel patches](KERNEL_PATCHES.md): what a pristine kernel needs
- [Debugging](DEBUGGING.md): serial logs and early crashes
