# Developing the common repos

**TL;DR:** Work on `lineage-24.0`, one topic per commit. The human
builds and tests. Changes go through LineageOS Gerrit review.

For bringing up a *device*, see [BRINGUP_OVERVIEW.md](BRINGUP_OVERVIEW.md).
This page is for changing the shared repos themselves.

## The repos

| Repo | Holds |
|------|-------|
| `device/mainline/common` | Common device tree, `optional/` modules, sepolicy |
| `device/mainline/<vendor>-common` | SoC vendor layer (more may appear; currently `qcom-common`) |
| `hardware/mainline/common` | HALs and tools, and the shared `docs/` |
| `hardware/mainline/<vendor>` | Vendor daemons and libraries |
| `vendor/mainline` | Components that need `//vendor:__subpackages__` visibility |
| `kernel/mainline/configs` | Kernel config fragments |
| `device/mainline/generic` | `generic_init` based tree |
| `-ext` repos | Maintained under their own rules, see [CONTRIBUTING.md](CONTRIBUTING.md) |

The tree must keep working in pristine AOSP, not only LineageOS.

## Set up the source tree

| Step | How |
|------|-----|
| 1 | Sync an Android tree (LineageOS `lineage-24.0`) |
| 2 | Put the matching branch of the mainline `local_manifests` into `.repo/local_manifests` |
| 3 | `repo sync` |
| 4 | Kernel sources are optional: `conditional/kernel/mainline-kernels.xml` |

The manifests use groups so you can sync only what you need:

| Group | Repos |
|-------|-------|
| `mainline` | Everything below |
| `mainline_device_<vendor>`, `_virt`, `_misc` | Device trees |
| `mainline_kernel` | Kernel sources |
| `mainline_external` | Third-party hardware dependencies (Mesa, alsa, ...) |
| `mainline_dep_*` | Dependencies from AOSP, LineageOS, BayLibre |
| `mainline_proprietary` | Vendor blobs |

For a pure AOSP tree use `conditional/for-pure-aosp/`.

## Branches

| Branch | Use |
|--------|-----|
| `lineage-24.0` | Current development |
| `lineage-22.2`, `23.0`, `23.1`, `23.2` | Older Android versions |

Same repo names, one branch per Android version. Ask the maintainer
before you backport.

## The change loop

```
read docs -> edit -> format -> commit -> human builds and tests
                                           |
         merge <- votes <- Gerrit review <- push
```

| Step | Do |
|------|----|
| Read | The repo's `AGENTS.md`, then the docs it points to |
| Check scope | `hardware/mainline/common/docs/SCOPE.md`: fix the category, not the sample |
| Edit | Update README or AGENTS.md in the **same** commit when behavior changes |
| Format | Run the formatter on touched files (`clang-format`, `rustfmt`) |
| Commit | One logical change, subject and trailers per `COMMIT_CONVENTIONS.md` |
| Self review | Go through `REVIEW.md` against your own diff |
| Test | The human builds and runs it on hardware. Agents must not |
| Push | To Gerrit: `git push <gerrit-remote> HEAD:refs/for/lineage-24.0` |
| Review | Reviewers vote `Code-Review` and `Verified` |
| Merge | Only with maximum votes |

The `commit-msg` hook adds `Change-Id`. Do not write it yourself.

## Checks that run for you

| Where | What |
|-------|------|
| Gerrit CI (`device/mainline/common`) | `build/tools/check_sepolicy.py` and its unit tests |
| Reviewers | `REVIEW.md` seven checks; `vendor/mainline/docs/review.md` vote cheatsheet |

CI does not build a device image. A passing CI is not a tested change.

## What reviewers vote down

| Vote | Typical reason |
|------|----------------|
| `-1` | Style differs from nearby code, unclear or long commit message (over 38 lines), unrelated diff noise |
| `-2` | Breaks other devices with no workaround, several independent changes in one commit, missing `Assisted-by` trailer on AI work, bad core idea |

Reviewers care first about their own use cases and get annoyed by
walls of text. Keep both the diff and the message small.

## Testing

State in the commit message **what** you tested, on **which**
hardware or config, and the **result**. If the risk sits on hardware
you do not have, ask someone who does.

## Cross-repo changes

| Change | Order |
|--------|-------|
| New HAL | Land the HAL in `hardware/mainline/common`, then the selection in `optional/` (`hardware/mainline/common/docs/WIRING_A_HAL.md`) |
| New SoC | The SoC vendor tree first, then the device |
| New kernel fragment | `kernel/mainline/configs` first, then the device that uses it |

## After a change is merged

Merged commits are never rewritten. Fix gaps with a new commit; see
`hardware/mainline/common/docs/FIXUPS.md`.

## Upstream-tracked components

Some files copy an upstream (AOSP init rc, cuttlefish HALs, ...).
Keep them in sync on Android version bumps. Where they are listed:

| Where | What |
|-------|------|
| `README.md` "Upstreams" table in `hardware/mainline/common` | HAL origins |
| `device/mainline/generic/docs/maintenance.md` | Table for the generic tree |

## Android version bump checklist

- [ ] Rebuild every reference device (see [README.md](README.md))
- [ ] Check upstream-tracked files for changes
- [ ] Update SELinux for new denials
- [ ] Update docs that name versions
