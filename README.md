# Dualayer Hierarchy Standard (DHS)

**A layered filesystem hierarchy in which musl and GNU libc run side by side.**

The Dualayer Hierarchy Standard defines where the files of an operating system
live when the system is assembled from layers — a self-sufficient base, a layer
of installed software and a boot layer — and how two C libraries, **musl** and
**glibc**, are installed on the same system without conflicting.

*Dualayer* = **dual** (two C libraries) + **layer** (a system built from layers).

- Version: **1.0** (October 2026)
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
│   ├── syshub/                      base: the complete OS (composed view at run time)
│   │   ├── bin/ sbin/ libexec/ lib/ include/ share/ etc/ var/
│   │   ├── x86_64-<vendor>-linux-musl/   musl: loader, libc, headers, toolchain
│   │   ├── drivers/modules/  drivers/hardware/firmwares/
│   │   └── engine/services/
│   ├── zexlib/                      userland: software the user installs
│   │   ├── union/                   files of installed packages (upper layer)
│   │   │   └── x86_64-<vendor>-linux-gnu/  glibc, when installed
│   │   └── work/  registry/  var/
│   ├── zaisys/                      boot: kernels, initramfs, boot loader (read-only)
│   ├── agents/                      instructions for AI agents (optional)
│   └── .syshub-pending/             a staged base upgrade
├── home/  root/  tmp/  run/  dev/  proc/  sys/
└── var -> /overlayer/syshub/var
```

There is no `/usr`, `/bin`, `/sbin`, `/lib`, `/lib64`, `/etc` or `/boot` at the
root — not even as symbolic links.

| Layer | Path | Changed by |
| :--- | :--- | :--- |
| Base | `/overlayer/syshub` | base upgrades only, applied at boot |
| Userland | `/overlayer/zexlib/union` | the package manager |
| Boot | `/overlayer/zaisys` | base upgrades and the installer |

At boot the initramfs applies a staged base upgrade, then mounts the system view
at `/overlayer/syshub` with OverlayFS: the base as the lower layer, the userland
as the upper layer. Programs see one system; every file on disk belongs to
exactly one layer. Deleting the userland leaves a base that still boots.

## musl and glibc side by side

| | musl (primary) | glibc (secondary) |
| :--- | :--- | :--- |
| Directory | `/overlayer/syshub/<arch>-<vendor>-linux-musl` | `/overlayer/zexlib/union/<arch>-<vendor>-linux-gnu` |
| Layer | base | userland (optional package) |
| Loader | `lib/ld-musl-<arch>.so.1` | `lib/ld-linux-x86-64.so.2` |
| Libraries searched | `/overlayer/syshub/lib`, musl `lib`, union `lib` | glibc's own `lib` only |
| Compiler | `cc`, `gcc`, `g++`, `c99` | `<arch>-<vendor>-linux-gnu-gcc` / `-g++` only |
| `ldd`, `iconv`, `locale` | on `PATH` | in glibc's `bin`, off `PATH` |
| Users, DNS, time zone | `/overlayer/syshub/etc` | `/overlayer/syshub/etc` (same files) |

The base is built against musl. glibc is an ordinary package that the user can
install for prebuilt software — commercial applications, games, vendor SDKs.
Each program names its own loader, each loader searches only its own libraries,
and nothing of glibc enters the shared `bin`, `lib` or `include`. Both libraries
read the same users, hosts, DNS and time zone from the base.

Conflicts this prevents:

- two loaders and two `libc` files competing for `/lib` and `/lib64`;
- headers of one library compiled against the other's `libc`;
- a glibc program loading a musl-built library from the shared `lib`;
- `libstdc++` / `libgcc_s` of one ABI loaded by programs of the other;
- one `ld.so.cache` listing libraries of both;
- glibc's `ldd` replacing musl's and misreporting base programs;
- `pkg-config` returning `.pc` files of the wrong library;
- the two libraries reading users, DNS or the time zone from different places;
- prebuilt binaries that name `/lib64/ld-linux-x86-64.so.2`, a path DHS does not
  have — they are started through the installed glibc loader instead.

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
make pdf        # needs Apache FOP
```

Requirements: `make`, `xsltproc`, `xmllint`. The DocBook schemas and XSL
stylesheets are included in `docbook/`.

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
