# Extensions (`-ext`)

The common trees have hooks for your own additions. This page tells
you what they are.

**TL;DR:** if `device/mainline/common-ext` exists, `mainline/common`
includes it. Put your extras there. The common trees never need it.

No `-ext` repository is provided in the mainline organization. You
create and host your own.

## The hooks

`device/mainline/common` and `device/mainline/qcom-common` each look
for a matching `-ext` tree and include it **only if it exists**:

| Tree | Product makefile | Board config | Options |
|------|------------------|--------------|---------|
| `mainline/common` | `device/mainline/common-ext/mainline_common-ext.mk` | `.../BoardConfigMainlineCommonExt.mk` | `.../optional/options.mk` |
| `mainline/qcom-common` | `device/mainline/qcom-common-ext/mainline_qcom-common-ext.mk` | `.../BoardConfigMainlineQcomCommonExt.mk` | `.../optional/options.mk` |

| Hook | Where it is included | Use it for |
|------|----------------------|------------|
| Product makefile | Inherited at the top of the common product makefile | Packages, Soong namespaces, your `optional/*/product.mk` |
| Board config | `-include`d at the end of the common board config | Board variables, SELinux dirs |
| `optional/options.mk` | `-include`d at the end of the common `options.mk` | Defaults (`?=`), and replacements of common modules |

Because the options hook is included last, defaults you write with `?=`
only apply to variables the common tree left unset.

## Replacing a common module

| Step | Do |
|------|----|
| 1 | In your `optional/options.mk`, map the common value to your own, for example `TARGET_AUDIO_HAL := mainline_ext` when it was `mainline` |
| 2 | Put your module in `optional/<dir>/{board,product}.mk` |
| 3 | In the device, set `MAINLINE_COMMON_PREFER_EXT_MODULES := true` (or `MAINLINE_QCOM_COMMON_PREFER_EXT_MODULES` for the Qualcomm tree) |

Convention: end replacement values with `_ext`, so they never clash
with a common value.

What the flag does:

| Case | Result |
|------|--------|
| Flag set, `-ext/optional/options.mk` exists | `MAINLINE_COMMON_USE_EXT_MODULES := true`; common modules that would clash switch themselves off (for example the framebuffer graphics HAL packages) |
| Flag set, tree missing | A build warning; the common modules stay |
| Flag not set | Your `options.mk` still loads, but nothing is switched off |

## A minimal extension tree

```
device/mainline/common-ext/
├── Android.bp
├── mainline_common-ext.mk
├── BoardConfigMainlineCommonExt.mk
└── optional/
    ├── options.mk
    └── <your-module>/product.mk
```

HAL code that goes with it can live in your own
`hardware/mainline/common-ext` (add it to `PRODUCT_SOONG_NAMESPACES` in
your product makefile).

## Rules

- The common trees must keep working without any `-ext` tree. Never
  add a dependency on one.
- Keep things in the common trees if they are useful to everyone;
  `-ext` is for what only you need.
- The usual quality rules still apply to your own tree: see
  `hardware/mainline/common/docs/`.
