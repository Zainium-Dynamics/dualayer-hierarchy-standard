# Changelog

## Unreleased

- The userland layer has no `var` of its own: variable data of installed software (for example a system-wide Flatpak installation) lives in `union/var`, used by its path under the userland when its storage cannot live on OverlayFS.

## 1.0 — 2026-10-28

First version of the Dualayer Hierarchy Standard.

- The root directory: `/overlayer`, user data and virtual filesystems only; no `/usr`, `/bin`, `/lib`, `/lib64`, `/etc` or `/boot`.
- The layers under `/overlayer`: `syshub` (system), `userland`, `ignition`, `agents`, and `.syshub-pending` for staged base upgrades; distributions may rename the userland and ignition layers (Zainium OS: `zexlib`, `zaisys`).
- Composition of the system view at boot with OverlayFS, rescue boot without the userland, live media.
- musl and glibc side by side: either can be the primary C library (design A: musl primary, design B: glibc primary); the secondary lives in the system layer or the userland as the distribution chooses; one directory per C library named after its target triplet, rules for loaders, library search paths, shared system configuration and toolchains, and the conflicts the layout prevents.
- Running FHS software: path resolution rules, loader redirection, adapting foreign packages.
- Package manager guarantees: base protection, receipts, staged and atomic base upgrades, protected paths.
- Reference: FHS-to-DHS map, reference implementation (Zainium OS), glossary.
