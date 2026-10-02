# AGENTS.md - device/mainline/common

Agents must read this file before touching anything in this repository.

Part of the mainline repository set. Map of all repos: `vendor/mainline/docs/REPOSITORIES.md`.

This repository is the common Android device tree for devices running a
mainline-style kernel. It is also used inside pristine AOSP, so it must
keep working without LineageOS and without the `-ext` repositories.

## Read first

| Task | Read |
|------|------|
| Bring up a new device | `docs/README.md`, then `docs/AGENTS_FOR_BRINGUP.md` |
| Change an optional module | `optional/README.md`, `optional/_template.mk` |
| Commit | `hardware/mainline/common/docs/COMMIT_CONVENTIONS.md` |
| Style, review, scope, workflow | `hardware/mainline/common/docs/` |

## Hard rules

- Do not build, flash or run tests. The human does and reports back.
- Do not search from the AOSP tree root. Use precise directories.
- Do not make this tree depend on `device/mainline/common-ext`.
- Do not hardcode per-device values here. A device belongs in its own
  tree.
- New optional module: `optional/<name>/{board,product}.mk`, and
  document its variable in `optional/README.md`.
- `TARGET_INITIAL_BRINGUP` defaults live in `optional/options.mk` and
  `BoardConfigMainlineCommon.mk`; keep them in sync with
  `docs/BRINGUP_OVERVIEW.md`.
- Makefile sections are commented (`# Name`) and sorted alphabetically.
- Every new source file starts with the SPDX header.

## Layout

See `README.md` ("Structure").
