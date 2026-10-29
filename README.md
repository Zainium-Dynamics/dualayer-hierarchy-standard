# Dualayer Hierarchy Standard (DHS)

**A layered filesystem hierarchy in which musl and GNU libc run side by side.**

The Dualayer Hierarchy Standard defines where the files of an operating system
live when the system is assembled from layers — a self-sufficient base, a layer
of installed software and a boot layer — and how two C libraries, **musl** and
**glibc**, are installed on the same system without conflicting.

*Dualayer* = **dual** (two C libraries) + **layer** (a system built from layers).

- Version: **1.0** (October 2026)
- PDF: [dualayer-hierarchy-standard.pdf](https://github.com/Zainium-Dynamics/dualayer-hierarchy-standard/releases/download/latest/dualayer-hierarchy-standard.pdf) — rebuilt from `main` on every change
- Reference implementation: [Zainium OS](https://github.com/Zainium-Dynamics)
- License: [CC BY-SA 4.0](LICENSE)

## Why

The [Filesystem Hierarchy Standard](https://specifications.freedesktop.org/fhs/)
describes one shared tree: the vendor's software and the user's software both
go into `/usr`, and one C library serves every program. That makes three things
hard:

- keeping what the vendor ships apart from what the user installs;
- upgrading the base system as one unit instead of file by file while it runs;
- having a second C library, because `/lib`, `/lib64`, `/usr/include` and the
  loader path assume there is only one.

DHS gives every part of the system its own layer with a single owner, composes
the layers into one view at boot with OverlayFS, and gives each C library a
directory of its own.

## The layout

```text
/
├── overlayer/
│   ├── syshub/                      system layer: the base OS (composed view at run time)
│   │   ├── bin/ sbin/ libexec/ lib/ include/ share/ etc/ var/
│   │   ├── x86_64-<vendor>-linux-musl/   primary C library: loader, libc, headers, toolchain
│   │   └── drivers/modules/  drivers/hardware/firmwares/
│   ├── userland/                    userland layer: software the user installs
│   │   ├── union/                   files of installed packages (upper layer)
│   │   │   ├── var/                 variable data of installed software
│   │   │   └── x86_64-<vendor>-linux-gnu/  secondary C library, when installed as a package
│   │   └── work/  registry/
│   ├── ignition/                    ignition layer: kernels, initramfs, boot loader (read-only)
│   ├── agents/                      instructions for AI agents (optional)
│   └── .syshub-pending/             a staged base upgrade
├── home/  root/  tmp/  run/  dev/  proc/  sys/
└── var -> /overlayer/syshub/var
```

There is no `/usr`, `/bin`, `/sbin`, `/lib`, `/lib64`, `/etc` or `/boot` at the
root — not even as symbolic links.

| Layer | DHS name | Changed by | Zainium OS name |
| :--- | :--- | :--- | :--- |
| System (base) | `/overlayer/syshub` | base upgrades only, applied at boot | `syshub` |
| Userland | `/overlayer/userland` | the package manager | `zexlib` (Zainium Executable Library) |
| Ignition (boot) | `/overlayer/ignition` | base upgrades and the installer | `zaisys` |

A distribution may give the userland and ignition layers names of its own, as
Zainium OS does, as long as the structure inside them is unchanged and the names
are documented in `/overlayer`.

At boot the initramfs applies a staged base upgrade, then mounts the system view
at `/overlayer/syshub` with OverlayFS: the system layer as the lower layer, the
userland as the upper layer. Programs see one system; every file on disk belongs
to exactly one layer. Deleting the userland leaves a base that still boots.

## musl and glibc side by side

Every distribution chooses its **primary** C library — the one the base is
built against. The other one is the optional **secondary** C library. Each
lives in its own directory named after its target triplet, so both run on one
system without conflicts.

| | Design A: musl primary | Design B: glibc primary |
| :--- | :--- | :--- |
| Base built against | musl | glibc |
| Primary directory | `syshub/<arch>-<vendor>-linux-musl` | `syshub/<arch>-<vendor>-linux-gnu` |
| Secondary directory | `…-linux-gnu`, in `syshub` or `userland/union` | `…-linux-musl`, in `syshub` or `userland/union` |
| `cc`, `gcc`, `ldd` on `PATH` | musl's | glibc's |
| Secondary compiler | `<arch>-<vendor>-linux-gnu-gcc` | `<arch>-<vendor>-linux-musl-gcc` |
| Example | Zainium OS (glibc as a userland package) | — |

> **Where the secondary C library lives varies by distribution.** A
> distribution can ship it in the system layer (always installed) or offer it as
> a userland package (installed when needed). Both conform; the secondary always
> keeps its own triplet directory and never writes into the shared `bin`, `lib`
> or `include`.

The rules that make this work:

- the shared `bin`, `lib` and `include` belong to the primary C library;
- every program names the loader of the C library it was linked against;
- the secondary loader searches only its own `lib`, never the shared one;
- both C libraries read users, hosts, DNS and the time zone from
  `/overlayer/syshub/etc`;
- unprefixed compilers belong to the primary; the secondary's compiler has its
  triplet name and its own `pkg-config` path.

Conflicts this prevents:

- two loaders and two `libc` files competing for `/lib` and `/lib64`;
- headers of one library compiled against the other's `libc`;
- a program of one library loading a library built for the other;
- `libstdc++` / `libgcc_s` of one ABI loaded by programs of the other;
- one loader cache listing libraries of both;
- the secondary's `ldd` replacing the primary's and misreporting base programs;
- `pkg-config` returning `.pc` files of the wrong library;
- the two libraries reading users, DNS or the time zone from different places;
- prebuilt binaries that name `/lib64/ld-linux-x86-64.so.2` or
  `/lib/ld-musl-x86_64.so.1`, paths DHS does not have — they are started
  through the installed loader of the same C library instead.

## Software built for FHS systems

Scripts with `#!/usr/bin/env`, programs that open `/etc/passwd` or
`/usr/share/...`, and binaries built on other distributions keep working: FHS
paths that do not exist are resolved to their DHS location when they are used
(`/usr/bin/env` → `/overlayer/syshub/bin/env`, `/etc/passwd` →
`/overlayer/syshub/etc/passwd`), and missing loader paths are redirected to the
installed loader of the same C library. Packages from other distributions are
adapted when they are installed.

## Reading the standard

The source is DocBook 5 XML in [`xml/`](xml), one file per chapter:

1. [Introduction](xml/intro.xml)
2. [Design principles](xml/principles.xml)
3. [The root directory](xml/root.xml)
4. [The `/overlayer` hierarchy](xml/overlayer.xml)
5. [Composing the system view](xml/composition.xml)
6. [Two C libraries side by side: musl and glibc](xml/libc.xml)
7. [Running software built for FHS systems](xml/compat.xml)
8. [Package management](xml/packages.xml)
9. [Reference: FHS map, reference implementation, glossary](xml/appendix.xml)

Rendered HTML is attached to every CI run (artifact `dhs-html`).

## Building

```sh
make valid      # validate against the DocBook 5 schema (xmllint)
make html       # one page per chapter: build/dhs/html/
make single     # one page: build/dhs/single/index.html
make pdf        # build/dhs/dhs.pdf, the print edition, needs WeasyPrint
```

Requirements: `make`, `xsltproc`, `xmllint`. The DocBook schemas and XSL
stylesheets are included in `docbook/`. The print edition has its own
stylesheet, logos and fonts (IBM Plex, SIL Open Font License) in
`docbook/print/`, so it looks the same wherever it is built. CI builds the
HTML and the PDF for every change and publishes the PDF of `main` on the
`latest` release.

## Implementations

| Implementation | Status |
| :--- | :--- |
| [Zainium OS](https://github.com/Zainium-Dynamics) | reference implementation |

Implementing DHS in another distribution? Open an issue or a pull request to be
listed here.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Issues and pull requests are welcome,
especially from distribution, toolchain and package manager maintainers.

## Credits

DHS builds on the [Filesystem Hierarchy Standard](https://specifications.freedesktop.org/fhs/),
maintained by freedesktop.org. The build system is derived from the
[FHS project's](https://gitlab.freedesktop.org/FHS/fhs-spec); see
[Attributions](Attributions).
