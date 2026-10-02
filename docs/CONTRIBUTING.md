# Contributing

**TL;DR:** Small commits, one stage or one topic each. Standards live
in `hardware/mainline/common/docs/`.

See also [DEVELOPING.md](DEVELOPING.md) for branches, review and checks.

## Read first

| Doc | For |
|-----|-----|
| `hardware/mainline/common/docs/COMMIT_CONVENTIONS.md` | Subject, body, trailers |
| `hardware/mainline/common/docs/CODE_STYLE.md` | SPDX headers, style |
| `hardware/mainline/common/docs/REVIEW.md` | What reviewers check |
| `hardware/mainline/common/docs/SCOPE.md` | Fix the category, not the sample |
| `hardware/mainline/common/docs/WORKFLOW.md` | What AI agents may do |

## Commit subjects in device trees

```
<tree>: <area>: <imperative summary>
```

| Tree | Prefix |
|------|--------|
| `device/mainline/common` | `mainline/common` |
| `device/mainline/<vendor>-common` | `mainline/<vendor>-common` |
| `device/pc/basic_x86_64_pc` | `basic_x86_64_pc` |
| Any device tree | Its directory name, e.g. `<device>` |

Example: `basic_x86_64_pc: README: Update boot steps`.

AI assisted commits carry two trailers, in this order:

```
Assisted-by: LLM
Assisted-by: <Agent>:<Model ID>
```

## Before you send

- [ ] One topic per commit
- [ ] Every new file has the SPDX header
- [ ] Device-specific things stay in the device tree; shared things go
      to the common tree (ask first)
- [ ] README updated (new patch, new repo, new known issue)
- [ ] `check_sepolicy.py` run on sepolicy changes
- [ ] You did not edit files that are marked as one-time briefs

## Where to send what

| Change | Repo |
|--------|------|
| Device specific | Your device tree |
| Applies to many devices | `device/mainline/common` or the `<vendor>-common` tree |
| New HAL or HAL fix | `hardware/mainline/common` |
| Needs a private rule | An `-ext` repo (see below) |

## The `-ext` repos

Repos with an `-ext` suffix (`device/mainline/common-ext`,
`hardware/mainline/common-ext`, and `<vendor>-common-ext`) are maintained by
the same author with their own rules. The common trees include them
when present and work without them. Do not make the common trees
depend on them.
