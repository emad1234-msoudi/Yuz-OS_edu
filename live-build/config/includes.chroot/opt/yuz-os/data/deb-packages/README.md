# Yuz-OS Local Debian Packages

This directory contains local Debian packages used by the Yuz-OS live-build
process.

The packages are copied into the live filesystem and installed by the Yuz-OS
APT runtime module:

```text
/opt/yuz-os/scripts/modules/apt/apt.sh
```

The runtime module scans this directory and installs all available `.deb`
packages with `apt-get`.

## Package categories

### Third-party desktop applications

The following packages are optional third-party applications that are useful
for a complete Yuz-OS desktop experience and are intentionally not tracked in
Git:

- `code_*.deb` — Visual Studio Code
- `onlyoffice-desktopeditors_*.deb` — ONLYOFFICE Desktop Editors

### Yuz-OS branding packages

The following packages belong to the Yuz-OS project and are intentionally
tracked in Git so they are always present in the ISO:

- `yuz-branding-base_*.deb`
- `yuz-branding-grub_*.deb`
- `yuz-branding-plymouth_*.deb`
- `yuz-branding-calamares_*.deb`

## Git policy

Binary `.deb` files must not be committed to the Git repository.

The repository intentionally tracks this `README.md`, but ignores all Debian
binary packages using the repository-wide `*.deb` rule in `.gitignore`.

Before running a build, place the required local packages in this directory:

```text
live-build/config/includes.chroot/opt/yuz-os/data/deb-packages/
```

Example:

```bash
cp /path/to/package.deb \
  live-build/config/includes.chroot/opt/yuz-os/data/deb-packages/
```

The build requires packages to match the target architecture. For the current
Yuz-OS amd64 build, use amd64 or architecture-independent packages.

## Build behavior

If no `.deb` files are present, the APT module skips local package
installation.

If packages are present, the module updates the APT package lists and installs
all local `.deb` files together so that dependencies can be resolved through
the enabled Debian repositories.

Do not use `git add -f` for `.deb` files unless there is an exceptional,
documented release-engineering reason.
