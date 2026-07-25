## 🏗️ [PROJECT_ARCHITECTURE.md](/docs/PROJECT_ARCHITECTURE.md)


«Yuz-OS Educational Edition»

> «Persian Documentation: [PROJECT_ARCHITECTURE-fa.md](/docs/PROJECT_ARCHITECTURE-fa.md)»

A high-level overview of the Yuz-OS build system, project layout, and build pipeline.»

---

## 📖 Overview

Yuz-OS is an educational Linux distribution built on top of Debian Live Build.

Instead of modifying Debian directly, Yuz provides its own modular build framework that automates the entire ISO generation process.

The goal of this document is to explain how the project is organized and how every component works together.

This is not a developer reference.
It is the architectural map of the project.

---

# 🗂 Repository Layout

```
Yuz-OS_Edu/

├── archive/
├── docs/
├── live-build/
├── release/
│
├── README.md
├── README-fa.md
├── LICENSE
└── ...
```

Directory| Description
`archive/`| Legacy files and experimental resources
`docs/`| Project documentation
`live-build/`| Main build system
`release/`| Generated release artifacts

---

## ⚙️ Build System Layout

```
live-build/

├── setup.sh
├── cache/
├── config/
└── scripts/
```

---

## 🚀 setup.sh

The main entry point of the entire project.

**Responsibilities:**

- Check system requirements
- Prepare the environment
- Load the framework
- Execute build modules
- Launch Debian Live Build
- Produce the final ISO

---

## 🧩 Framework

```
scripts/framework/

check.sh
env.sh
filesystem.sh
log.sh
package.sh
runtime.sh
ui.sh
```

The framework contains reusable building blocks shared by every module.

**Examples:**

- Logging
- User Interface
- Runtime helpers
- Filesystem helpers
- Package management
- Environment validation

The framework itself performs no build actions.
It only provides reusable functionality.

---

# 🔧 Modules

```
scripts/modules/

build/
flatpak/
...
```

Modules perform actual build tasks.

Each module has a single responsibility.

**Examples:**

- Build environment preparation
- Offline Flatpak repository generation
- Future ISO customization modules

The framework calls modules.
Modules never call each other directly.

---

## 📦 Configuration

```
config/

hooks/
includes.chroot/
package-lists/
packages.chroot/
...
```

This directory contains everything consumed by Debian Live Build.

**Typical content includes:**

- Package lists
- Local packages
- Live Build hooks
- Themes
- Icons
- Calamares configuration
- Desktop integration
- System configuration files

---

## 🗄 Cache

`cache/`

Temporary working directory used during the build process.

Safe to remove.

Automatically recreated when needed.

---

## 🔄 Build Pipeline

```
┌────────────────────┐
│   System Check     │
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│     setup.sh       │
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│     Framework      │
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│      Modules       │
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│ Debian Live Build  │
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│    ISO Image       │
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│ Boot Live System   │
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│    Calamares       │
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│ Installed Yuz-OS   │
└────────────────────┘
```

---

## 🎯 Design Philosophy

**The Yuz build system follows a few simple principles:**

- Modular
- Predictable
- Reproducible
- Easy to maintain
- Easy to extend

Every component should have one clear responsibility.

---

## 📚 Next Step

This document explains the overall architecture.

Detailed implementation of individual components may be documented separately as the project evolves.

>[!TIP]
>for newest and other architecture please read : [README.md](/README.md). 