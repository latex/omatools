# OmaTools

> **OmaTools**: A high-performance productivity power suite for **Omarchy / Linux (Wayland / Hyprland)**, bringing the complete feature set of **Microsoft PowerToys** to Linux, architected in pure **x86_64 Assembly** with native Linux syscalls and direct Wayland/Hyprland IPC.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Linux x86_64](https://img.shields.io/badge/Platform-Linux%20x86__64-orange.svg)](https://kernel.org)
[![Compositor: Hyprland / Wayland](https://img.shields.io/badge/Compositor-Hyprland%20%2F%20Wayland-00b4d8.svg)](https://hyprland.org)

---

## 🎯 Mission

Microsoft PowerToys is widely acclaimed for its suite of desktop utilities on Windows (Workspaces, FancyZones, ColorPicker, Run, Awake, Peek, etc.). 

**OmaTools** is a ground-up reimplementation for modern Linux desktops, specifically tuned for **Omarchy** and **Hyprland / Wayland**. Instead of heavy electron runtimes or multi-megabyte frameworks, OmaTools is built with ultra-low latency, zero runtime overhead, and minimal memory footprint using **x86_64 Assembly** and direct Linux kernel syscalls (`sys_socket`, `sys_connect`, `sys_openat`).

---

## 🛠️ Feature Mapping (PowerToys ➔ OmaTools)

| # | Windows PowerToys | OmaTools (Linux / Wayland) | Description | Status |
|---|-------------------|----------------------------|-------------|--------|
| 1 | **Workspaces** | `oma-workspaces` | Instant snapshot and multi-window session restoration via Hyprland IPC | 🚀 In Progress (Sprint 1) |
| 2 | **FancyZones** | `oma-zones` | Dynamic custom window snapping grids and layout presets | 📋 Planned |
| 3 | **Color Picker** | `oma-picker` | Pixel magnifier and hex/rgb color sampler via `wlr-screencopy` | 📋 Planned |
| 4 | **PowerToys Run** | `oma-run` | Ultra-fast Wayland application launcher and calculator | 📋 Planned |
| 5 | **Keyboard Manager** | `oma-keys` | Low-level evdev / libinput key remapper and macro engine | 📋 Planned |
| 6 | **Text Extractor** | `oma-ocr` | Instant screen region snipping and optical character recognition (OCR) | 📋 Planned |
| 7 | **Awake** | `oma-awake` | Sleep and idle inhibitor using `ext-idle-inhibit-v1` protocol | 📋 Planned |
| 8 | **Screen Ruler** | `oma-ruler` | On-screen pixel measuring, bounding boxes, and spacing inspection | 📋 Planned |
| 9 | **Find My Mouse** | `oma-mouse-find` | Spotlight effect focusing on the cursor position on key trigger | 📋 Planned |
| 10 | **Mouse Highlighter** | `oma-mouse-high` | Visual click indicators for left and right mouse buttons | 📋 Planned |
| 11 | **Mouse Jump** | `oma-mouse-jump` | Monitor mini-map for instant cursor teleportation across multi-monitors | 📋 Planned |
| 12 | **Mouse Crosshairs** | `oma-crosshairs` | Cartesian precision crosshairs centered on cursor | 📋 Planned |
| 13 | **Peek** | `oma-peek` | Instant file preview (images, markdown, code, media) with Spacebar | 📋 Planned |
| 14 | **Paste as Plain Text** | `oma-paste-clean` | Instant clipboard sanitization to clean plain text or Markdown | 📋 Planned |
| 15 | **Image Resizer** | `oma-img-resize` | Batch image dimension scaling and optimization | 📋 Planned |
| 16 | **File Locksmith** | `oma-locksmith` | Rapid procfs inspector showing processes holding file locks | 📋 Planned |
| 17 | **Hosts File Editor** | `oma-hosts` | Quick `/etc/hosts` rule manager | 📋 Planned |
| 18 | **Shortcut Guide** | `oma-shortcuts` | Dynamic overlay displaying active Hyprland and app keybindings | 📋 Planned |
| 19 | **Crop and Lock** | `oma-crop` | Picture-in-picture sub-window cropper and floating pin | 📋 Planned |
| 20 | **Quick Accent** | `oma-accent` | Fast character accent picker on key hold | 📋 Planned |
| 21 | **Environment Variables** | `oma-env` | Environment inspection and session variable management | 📋 Planned |
| 22 | **File Explorer Add-ons** | `oma-thumbs` | Thumbnail providers and preview integrations for Flea file manager | 📋 Planned |
| 23 | **Advanced AI Paste** | `oma-ai-paste` | Contextual clipboard text transformation powered by local Ollama LLMs | 📋 Planned |

---

## ⚡ Technical Architecture

- **Language:** Pure x86_64 Assembly (`as` / `nasm`)
- **Runtime:** Native Linux Kernel Syscalls (Zero libc dependency, no C runtime baggage)
- **Binary Footprint:** Hardened ELF binaries < 10 KB per utility
- **IPC Interface:** Direct Unix Domain Socket communication:
  - Hyprland command socket (`/run/user/$UID/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock`)
  - Hyprland real-time event socket (`.socket2.sock`)
  - Wayland compositor protocols (`wl_compositor`, `wl_shm`, `wlr-screencopy-unstable-v1`)

---

## 📦 Building and Running

### Prerequisites
- Linux x86_64
- GNU Assembler (`as`) and GNU Linker (`ld`)
- Hyprland / Wayland compositor

### Compilation
```bash
# Clone the repository
git clone https://github.com/latex/omatools.git
cd omatools

# Build all utilities
make

# Run the test binary
./bin/oma-test
```

---

## 📄 License
MIT License. Open source and community-driven.
