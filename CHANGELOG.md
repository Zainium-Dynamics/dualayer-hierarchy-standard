# Changelog

## 1.0 — 2026-10-28

First version of the Dualayer Hierarchy Standard.

- The root directory: `/overlayer`, user data and virtual filesystems only; no `/usr`, `/bin`, `/lib`, `/lib64`, `/etc` or `/boot`.
- The layers under `/overlayer`: `syshub` (base), `zexlib` (userland), `zaisys` (boot), `agents`, and `.syshub-pending` for staged base upgrades.
- Composition of the system view at boot with OverlayFS, rescue boot without the userland, live media.
- musl and glibc side by side: one directory per C library named after its target triplet, rules for loaders, library search paths, shared system configuration and toolchains, and the conflicts the layout prevents.
- Running FHS software: path resolution rules, loader redirection, adapting foreign packages.
- Package manager guarantees: base protection, receipts, staged and atomic base upgrades, protected paths.
- Reference: FHS-to-DHS map, reference implementation (Zainium OS), glossary.
