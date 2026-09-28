# OmaTools

> **OmaTools**: A high-performance productivity power suite for **Omarchy / Linux (Wayland / Hyprland)**, bringing the complete feature set of **Microsoft PowerToys** to Linux, architected in modern, idiomatic **Rust** with direct Hyprland / Wayland IPC.

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache--2.0-blue.svg)](LICENSE)
[![Language: Rust](https://img.shields.io/badge/Language-Rust%202024-orange.svg)](https://www.rust-lang.org)
[![Compositor: Hyprland / Wayland](https://img.shields.io/badge/Compositor-Hyprland%20%2F%20Wayland-00b4d8.svg)](https://hyprland.org)

---

## 🎯 Mission

Microsoft PowerToys is widely acclaimed for its suite of desktop utilities on Windows (Workspaces, FancyZones, ColorPicker, Run, Awake, Peek, etc.). 

**OmaTools** is a ground-up reimplementation for modern Linux desktops, specifically tuned for **Omarchy** and **Hyprland / Wayland**. Built with Rust, OmaTools provides memory safety, ultra-fast async execution, and tight integration with Linux Wayland protocols.

---

## 🛠️ Feature Mapping (PowerToys ➔ OmaTools)

| # | Windows PowerToys | OmaTools (Linux / Wayland) | Description | Status |
|---|-------------------|----------------------------|-------------|--------|
| 1 | **Workspaces** | `omatools workspaces` | Instant snapshot and multi-window session restoration via Hyprland IPC | 🚀 Implemented (Sprint 1) |
| 2 | **FancyZones** | `omatools zones` | Dynamic custom window snapping grids and layout presets | 📋 Planned |
| 3 | **Color Picker** | `omatools picker` | Pixel magnifier and hex/rgb color sampler via `wlr-screencopy` | 📋 Planned |
| 4 | **PowerToys Run** | `omatools run` | Ultra-fast Wayland application launcher and calculator | 📋 Planned |
| 5 | **Keyboard Manager** | `omatools keys` | Low-level evdev / libinput key remapper and macro engine | 📋 Planned |
| 6 | **Text Extractor** | `omatools ocr` | Instant screen region snipping and optical character recognition (OCR) | 📋 Planned |
| 7 | **Awake** | `omatools awake` | Sleep and idle inhibitor using `ext-idle-inhibit-v1` protocol | 📋 Planned |
| 8 | **Screen Ruler** | `omatools ruler` | On-screen pixel measuring, bounding boxes, and spacing inspection | 📋 Planned |
| 9 | **Find My Mouse** | `omatools mouse-find` | Spotlight effect focusing on the cursor position on key trigger | 📋 Planned |
| 10 | **Mouse Highlighter** | `omatools mouse-high` | Visual click indicators for left and right mouse buttons | 📋 Planned |
| 11 | **Mouse Jump** | `omatools mouse-jump` | Monitor mini-map for instant cursor teleportation across multi-monitors | 📋 Planned |
| 12 | **Mouse Crosshairs** | `omatools crosshairs` | Cartesian precision crosshairs centered on cursor | 📋 Planned |
| 13 | **Peek** | `omatools peek` | Instant file preview (images, markdown, code, media) with Spacebar | 📋 Planned |
| 14 | **Paste as Plain Text** | `omatools paste-clean` | Instant clipboard sanitization to clean plain text or Markdown | 📋 Planned |
| 15 | **Image Resizer** | `omatools img-resize` | Batch image dimension scaling and optimization | 📋 Planned |
| 16 | **File Locksmith** | `omatools locksmith` | Rapid procfs inspector showing processes holding file locks | 📋 Planned |
| 17 | **Hosts File Editor** | `omatools hosts` | Quick `/etc/hosts` rule manager | 📋 Planned |
| 18 | **Shortcut Guide** | `omatools shortcuts` | Dynamic overlay displaying active Hyprland and app keybindings | 📋 Planned |
| 19 | **Crop and Lock** | `omatools crop` | Picture-in-picture sub-window cropper and floating pin | 📋 Planned |
| 20 | **Quick Accent** | `omatools accent` | Fast character accent picker on key hold | 📋 Planned |
| 21 | **Environment Variables** | `omatools env` | Environment inspection and session variable management | 📋 Planned |
| 22 | **File Explorer Add-ons** | `omatools thumbs` | Thumbnail providers and preview integrations for Flea file manager | 📋 Planned |
| 23 | **Advanced AI Paste** | `omatools ai-paste` | Contextual clipboard text transformation powered by local Ollama LLMs | 📋 Planned |

---

## ⚡ Technical Architecture

- **Language:** Idiomatic Rust (Edition 2024)
- **Async Runtime:** Tokio
- **CLI Framework:** Clap v4 (derive)
- **Serialization:** Serde / Serde JSON
- **IPC Interface:** Direct Unix Domain Socket communication:
  - Hyprland command socket (`/run/user/$UID/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock`)
  - Hyprland real-time event socket (`.socket2.sock`)
  - Wayland protocols (`wl_compositor`, `ext-idle-inhibit-v1`)

---

## 📦 Building and Running

### Prerequisites
- Linux x86_64
- Rust toolchain (`cargo`, `rustc`)
- Hyprland / Wayland compositor

### Compilation
```bash
# Clone the repository
git clone https://github.com/latex/omatools.git
cd omatools

# Build release binary
cargo build --release

# Run status check
./target/release/omatools status

# Capture workspace snapshot
./target/release/omatools workspaces capture --workspace 1 --name dev-setup
```

---

## 📄 License
Licensed under the Apache License, Version 2.0 ([LICENSE](LICENSE)).
