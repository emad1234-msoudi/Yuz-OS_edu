# Yuz-OS Build Configuration

This directory contains all configuration files used to build the Yuz-OS ISO image
using Debian Live Build.

Each subdirectory has a specific role in the build process.

---

## 1. chroot_local-hooks/

This directory contains build hooks.

Hook files (`*.chroot`) are scripts that run automatically during the ISO build
inside the chroot environment.

Important notes:
- Hooks are executed in alphabetical order
- Numbering is used to control execution order
- All hook files must be executable (`chmod +x`)

Examples:
- Installing local `.deb` packages
- Enabling system features like ZRAM
- Applying system-level optimizations

---

## 2. includes.chroot/

This directory contains files that are copied directly into the final system.

Everything placed here will appear **exactly in the installed OS**.

Used for:
- Startup scripts
- System sounds
- Autostart desktop entries
- Custom system files

---

## 3. package-lists/

This directory defines which packages are installed or removed.

Files:
- `*.list.chroot` → packages to install from Debian repositories
- `*.purge.chroot` → packages to explicitly remove

Only official Debian repository packages should be listed here.

---

## 4. packages.chroot/

This directory is used for local `.deb` packages.

Notes:
- `.deb` files are installed automatically during the build
- For repository size and licensing reasons, `.deb` files are ignored in git
- Required packages and versions should be documented here

---

## Summary (For Presentation)

- package-lists → what to install/remove
- packages.chroot → local deb files
- includes.chroot → files copied into the system
- chroot_local-hooks → automation and system setup

This structure keeps the build clean, reproducible, and easy to maintain.
