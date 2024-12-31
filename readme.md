# Waydroid Installation and Usage Guide for X11

## Table of Contents
1. [Introduction](#introduction)
2. [System Requirements](#system-requirements)
3. [Installation](#installation)
   - [Installing Weston](#installing-weston)
   - [Installing Waydroid](#installing-waydroid)
   - [Initializing Waydroid](#initializing-waydroid)
4. [Usage](#usage)
   - [Launching Waydroid](#launching-waydroid)
   - [Stopping Waydroid](#stopping-waydroid)
5. [Additional Configuration](#additional-configuration)
   - [Hiding Waydroid Apps](#hiding-waydroid-apps)
   - [Clipboard Integration](#clipboard-integration)
6. [Automation](#automation)
   - [Startup Scripts](#startup-scripts)
7. [Uninstallation](#uninstallation)
8. [Troubleshooting](#troubleshooting)
9. [References](#references)

---

## Introduction

This comprehensive guide walks you through setting up and optimizing **Waydroid** on an X11-based Linux system. Waydroid offers a seamless Android container experience, tightly integrated into your Linux desktop. We cover everything from installation to advanced configuration to ensure a smooth experience.

---

## System Requirements

Ensure your system meets these prerequisites:
- Running an **X11 desktop environment**.
- Administrative privileges (sudo).
- Essential packages: **curl** and **ca-certificates**.

Install the prerequisites:

```bash
sudo apt install curl ca-certificates -y
```

---

## Installation

### Installing Weston

Install Weston, the required Wayland compositor:

```bash
sudo apt install weston -y
```

### Installing Waydroid

#### Step 1: Add the Waydroid Repository

Add the repository:

```bash
curl https://repo.waydro.id | sudo bash
```

#### Step 2: Install Waydroid

Install Waydroid:

```bash
sudo apt install waydroid -y
```

---

### Initializing Waydroid

Follow these steps within a Weston session:

1. **Start Weston**:

   ```bash
   weston --socket=mysocket
   ```

2. **Initialize Waydroid**:
   - Without Google Apps:
     ```bash
     sudo waydroid init
     ```
   - With Google Apps:
     ```bash
     sudo waydroid init -f -s GAPPS
     ```

#### Troubleshooting Binder Module Errors

For issues like:

```bash
[21:15:53] Failed to load binder driver
[21:15:53] ERROR: Binder node "binder" for waydroid not found
```

Follow [this guide](https://github.com/choff/anbox-modules).

---

## Usage

### Launching Waydroid

1. Start Weston:

   ```bash
   weston --socket=mysocket
   ```

2. Launch Waydroid:

   ```bash
   waydroid show-full-ui
   ```

### Stopping Waydroid

Stop Waydroid gracefully:

```bash
waydroid session stop
```

---

## Additional Configuration

### Hiding Waydroid Apps

Run this script to hide Waydroid apps from the system launcher:

```bash
for app in ~/.local/share/applications/waydroid.*.desktop; do
    grep -q NoDisplay $app || sed '/^Icon=/a NoDisplay=true' -i $app
done
```

### Clipboard Integration

Enable clipboard sharing:

1. Install pyclip:

   ```bash
   sudo pip install pyclip
   ```

2. Install wl-clipboard:

   ```bash
   sudo apt install wl-clipboard
   ```

---

## Automation

### Startup Scripts

#### 1. Configure Weston

Create `~/.config/weston.ini`:

```ini
[libinput]
enable-tap=true

[shell]
panel-position=none
```

#### 2. Create a Startup Script

Save this script as `/usr/bin/waydroid-session.sh`:

```bash
#!/bin/bash

weston --xwayland &
WESTON_PID=$!
export WAYLAND_DISPLAY=wayland-1
sleep 2

waydroid show-full-ui &
WAYDROID_PID=$!

trap "waydroid session stop; kill $WESTON_PID; kill $WAYDROID_PID" EXIT

wait $WESTON_PID
```

Make it executable:

```bash
chmod +x /usr/bin/waydroid-session.sh
```

#### 3. Add a Desktop Entry

Create `/usr/share/applications/waydroid-session.desktop`:

```ini
[Desktop Entry]
Version=1.0
Type=Application
Name=Waydroid Session
Comment=Start Waydroid in a Weston session
Exec=/usr/bin/waydroid-session.sh
Icon=waydroid
Terminal=false
Categories=System;Emulator;
```

Make it executable:

```bash
chmod +x /usr/share/applications/waydroid-session.desktop
```

---

## Uninstallation

### Full Removal

Run the `clean-removal.sh` script:

1. Make it executable:

   ```bash
   chmod +x clean-removal.sh
   ```

2. Execute:

   ```bash
   sudo ./clean-removal.sh
   ```

---

## Troubleshooting

- **Weston startup issues**: Verify Weston and X11 configurations.
- **Waydroid launch failures**: Ensure a running Weston session.
- **Performance problems**: Allocate more system resources.

---

## References

- [Waydroid Documentation](https://docs.waydro.id/)
- [Weston Documentation](https://wayland.freedesktop.org/)

---
