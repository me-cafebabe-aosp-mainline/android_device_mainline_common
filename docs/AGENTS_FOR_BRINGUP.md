# AI agents and bringup

**TL;DR:** An agent can write the tree and docs. It does not guess,
and does not build, flash or test without asking. Usually the human
builds, tests and reports back.

Applies in addition to `hardware/mainline/common/docs/WORKFLOW.md`
and `SCOPE.md`. Those win if they differ.

## Rules for the agent

| Do | Don't |
|----|-------|
| Read this guide and the nearest `AGENTS.md` first | Search from the AOSP tree root |
| Look at reference trees and HALs in the manifests | Browse outside the AOSP tree |
| Present a plan and wait for a "yes" | Create files before the plan is confirmed |
| Ask for logs when something fails | Build, flash, or run tests without asking (`WORKFLOW.md`) |
| Mark unknown facts `TODO(maintainer)` | Invent hardware values |
| Read values from DT, sysfs, props or config files | Hardcode per-device values that can be detected |

## Where to look

| Question | Look in |
|----------|---------|
| Build system rules | `build/make`, `build/soong` |
| Kernel build variables | `vendor/lineage/build/tasks/kernel.mk`, `vendor/lineage/config/BoardConfigKernel.mk` |
| fstab and mounting | `system/fs/fs_mgr` |
| `.rc` syntax, ueventd | `system/core/init` |
| Platform `.rc` files | `system/core/rootdir` |
| AOSP HALs | `hardware/interfaces` |
| LineageOS HALs | `hardware/lineage/interfaces` |
| Mainline HALs | `hardware/mainline/common/interfaces` |
| Other repos | The paths in `local_manifests/mainline/*.xml` |

Always use a precise directory and specific search terms.

## Workflow for a new device

1. Ask the human: SoC, bootloader, kernel source, what already boots,
   and which Linux distribution port (e.g. postmarketOS) to follow.
2. Pick the base: [CHOOSING_A_BASE.md](CHOOSING_A_BASE.md), and the
   names (`mainline` suffix, see [DEVICE_TREE_SKELETON.md](DEVICE_TREE_SKELETON.md)).
3. Write a plan (below) and get it confirmed.
4. Create the skeleton: [DEVICE_TREE_SKELETON.md](DEVICE_TREE_SKELETON.md).
5. Stop. The human builds and boots, or says how you may.
6. Work from the human's logs, **one stage at a time**:
   [BRINGUP_OVERVIEW.md](BRINGUP_OVERVIEW.md).
7. Commit each stage: [CONTRIBUTING.md](CONTRIBUTING.md).

### Plan template

| Item | Content |
|------|---------|
| Base tree | |
| Directory and names | |
| Kernel source and fragments | |
| Bootloader and boot image | |
| Partitions and fstab | |
| Optional modules to set | |
| Files to create | |
| What the human must do or provide | |

## Files the agent adds for the new tree

- `AGENTS.md`: starts with "agents must read this before touching the
  tree"; hard rules, quirks, reference paths.
- `CLAUDE.md`: only the line `@AGENTS.md`.
- `README.md`: see [DEVICE_README_TEMPLATE.md](DEVICE_README_TEMPLATE.md).

## Style of the docs

Applies to every page you write or change in this guide, and in the
device trees. Humans get tired of long text, so make pages easy to scan.

| Topic | Rule |
|-------|------|
| Shape | `# Title`, a `**TL;DR:**` of one to three lines, then `##` sections. End a page with a `## Check` list where there is something to check. A page that grows past a screen or two is split |
| Form | Tables for "situation → what to do" and for lists of options; checklists for steps; short bullets. No long paragraphs. One idea per row |
| Wording | Plain and present tense. Say what to do. Put paths, variables, properties and commands in backticks, with paths from the tree root |
| Recommendations | Say it is a recommendation, and give the reason and the cost of each option. Do not turn a discussion into a rule |
| Facts | Check each one in the code, the makefiles or AOSP before you write it. Unknown: `TODO(maintainer)`, never a guess. No hardware values, and no specs recited from memory |
| One owner | Each fact lives in one page. Other pages link to it instead of repeating it |
| Neutral | This tree is SoC-vendor neutral: vendor specifics go to the docs of the `<SoC vendor>-common` tree and are linked from here. Do not put names of people or chat quotes in docs, nor lists of "patterns seen in history" |
| Links | Relative links inside one repository (check the anchors). To another repository write the path in backticks |
| Examples | Point to a reference tree instead of pasting a long file. Keep a snippet short, and take it from a tree that builds |
| Staying right | When you change an option or a default, update `optional/README.md` and every page that states it (`grep` for the variable). When the maintainer corrects a fact, fix it everywhere it appears, not only where it was noticed |

Commit docs as in [CONTRIBUTING.md](CONTRIBUTING.md). The subject starts
with the repository prefix and `docs:`, like
`mainline/common: docs: Add KERNEL_CHOICE.md`.

## Stop and ask when

- A value depends on hardware you cannot read (boot device path,
  partition sizes, firmware names)
- The fix would touch a common repo instead of the device tree
- A spec is proprietary (do not recite it from memory)
