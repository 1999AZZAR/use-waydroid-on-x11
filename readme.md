# Waydroid Installation and Usage Guide for X11

## Table of Contents

1. [Introduction](#introduction)
2. [System Requirements](#system-requirements)
3. [Installation](#installation)
   - [Auto](#auto-install)
   - [Manual](#manual-install)
     - [Installing a nested Wayland compositor](#installing-a-nested-wayland-compositor)
     - [Installing Waydroid](#installing-waydroid)
     - [Initializing Waydroid](#initializing-waydroid)
4. [Usage](#usage)
   - [Launching Waydroid](#launching-waydroid)
   - [Stopping Waydroid](#stopping-waydroid)
5. [Additional Configuration](#additional-configuration)
   - [Hiding Waydroid Apps](#hiding-waydroid-apps)
   - [ARM Support](#arm-support-libhoudini--libndk)
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

### Auto Install

You can use the following one-liner to install and set up Waydroid directly.

```bash
curl -sSL https://raw.githubusercontent.com/1999AZZAR/use-waydroid-on-x11/master/install.sh | sudo bash
```

### Manual Install

#### Installing a nested Wayland compositor

Install **Cage** (recommended for many X11 setups, especially around suspend/resume) and **Weston** (optional legacy path):

```bash
sudo apt install cage weston -y
```

#### Installing Waydroid

##### Step 1: Add the Waydroid Repository

Add the repository:

```bash
curl https://repo.waydro.id | sudo bash
```

##### Step 2: Install Waydroid

Install Waydroid:

```bash
sudo apt install waydroid -y
```

---

#### Initializing Waydroid

Follow these steps with Weston running (nested on X11 is the expected case here):

1. **Start Weston** (default Wayland socket is `wayland-0` under `$XDG_RUNTIME_DIR`; that matches Wayland clients when `WAYLAND_DISPLAY` is unset):
   
   ```bash
   weston --xwayland
   ```

   If you use a custom socket (`weston --socket=NAME`), set `export WAYLAND_DISPLAY=NAME` in any terminal where you run Waydroid. If a compositor already uses `wayland-0` (for example you are not on a plain X11 desktop), Weston may create `wayland-1` instead; list sockets with `ls "$XDG_RUNTIME_DIR"/wayland-*` and export the one Weston opened.

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

1. Start Weston (same defaults as above; on a typical X11 session this is `wayland-0`):
   
   ```bash
   weston --xwayland
   ```

2. From another terminal, if needed set `export WAYLAND_DISPLAY=wayland-0`, then launch Waydroid:
   
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

### ARM Support (libhoudini / libndk)

To enable ARM support on x86 for Waydroid, use the `waydroid_script` tool:

```bash
git clone https://github.com/casualsnek/waydroid_script
cd waydroid_script
python3 -m venv venv
venv/bin/pip install -r requirements.txt
sudo venv/bin/pip install InquirerPy tqdm
sudo venv/bin/python3 main.py
```

1. Run the script as shown above.
2. Choose `libhoudini` or `libndk` from the menu to install ARM translation layers.

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

Save the repository `waydroid-session.sh` as `/usr/bin/waydroid-session.sh` (or copy the same file from this project). It defaults to **Cage** and uses a proper `cleanup` trap on `EXIT`, `INT`, `TERM`, and `HUP`. To use Weston instead, set `WAYDROID_COMPOSITOR=weston` in the desktop entry `Exec` line or environment.

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
Comment=Start Waydroid in Cage (set WAYDROID_COMPOSITOR=weston for Weston)
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
- **Suspend/resume and `libwayland` client errors**: Weston can lose nested-Wayland state after repeated suspend cycles under some X11 window managers. The default session script uses **Cage** (`cage -s -- waydroid show-full-ui`) instead. To force the old behavior: `WAYDROID_COMPOSITOR=weston waydroid-session.sh`.

### Fixing Play Store Uncertified Device Issue

If you are using the GApps version of Waydroid and see a "Device is not certified by Google" error in the Play Store, here is a potential fix.

1. **Enter the Waydroid Shell**
   
   Open a terminal on your computer and run:
   
   ```bash
   sudo waydroid shell
   ```
   
   You will now be inside the Android container's shell.

2. **Get Your GSF Android ID**
   
   Inside the `waydroid shell`, run this command to get your Google Services Framework ID:
   
   ```sql
   sqlite3 /data/data/com.google.android.gsf/databases/gservices.db "SELECT * FROM main WHERE name = 'android_id';"
   ```
   
   This will output a long number, which is your `android_id`. Copy this number.

3. **Register Your ID**
   
   Go to the Google Device Registration page: [https://www.google.com/android/uncertified/](https://www.google.com/android/uncertified/)
   
   Paste the `android_id` you copied into the input box and click "Register".

4. **Verify and Restart**
   
   Go back to the `waydroid shell`. The user suggests running the following command to verify the ID.
   
   ```bash
   ANDROID_RUNTIME_ROOT=/apex/com.android.runtime ANDROID_DATA=/data ANDROID_TZDATA_ROOT=/apex/com.android.tzdata ANDROID_I18N_ROOT=/apex/com.android.i18n sqlite3 /data/data/com.google.android.gsf/databases/gservices.db "select * from main where name = "android_id";"
   ```
   
   After this, fully stop and restart Waydroid for the changes to take effect.
   
   ```bash
   # On your main linux terminal, not the waydroid shell
   waydroid session stop
   # Then restart it using your preferred method
   ```

Good luck!

---

## References

- [Waydroid Documentation](https://docs.waydro.id/)
- [Weston Documentation](https://wayland.freedesktop.org/)

---
