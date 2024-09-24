# Waydroid Installation and Usage Guide on X11

## Table of Contents
1. [Introduction](#introduction)
2. [System Requirements](#system-requirements)
3. [Installation](#installation)
   - [Install Weston](#install-weston)
   - [Install Waydroid](#install-waydroid)
   - [Initialize Waydroid](#initialize-waydroid)
4. [Usage](#usage)
   - [Launching Waydroid](#launching-waydroid)
   - [Stopping Waydroid](#stopping-waydroid)
5. [Additional Configuration](#additional-configuration)
   - [Hiding Waydroid Apps from the System Launcher](#hiding-waydroid-apps-from-the-system-launcher)
   - [Enable Clipboard on Weston](#enable-clipboard-on-weston)
6. [Automation](#automation)
   - [Creating Automated Startup Scripts](#creating-automated-startup-scripts)
7. [Troubleshooting](#troubleshooting)
8. [References](#references)

---

## Introduction

This guide provides comprehensive instructions for installing and using **Waydroid** on an X11-based Linux system. Waydroid is a powerful tool that enables you to run Android in a containerized environment on Linux, giving you a full Android system experience directly on your desktop.

---

## System Requirements

Before you proceed, ensure that your system meets the following prerequisites:
- A working X11 environment.
- Administrative privileges (sudo access).
- **curl** and **ca-certificates** installed.

Ensure you have these dependencies installed by running:

```sh
sudo apt install curl ca-certificates -y
```

---

## Installation

### Install Weston

**Weston** is a reference Wayland compositor required by Waydroid to render the Android interface. Install Weston with the following command:

```sh
sudo apt install weston -y
```

### Install Waydroid

Follow these steps to install Waydroid on your system.

#### Step 1: Add the Waydroid Repository

Run the following command to add the official Waydroid repository:

```sh
curl https://repo.waydro.id | sudo bash
```

#### Step 2: Install Waydroid

Once the repository is added, install Waydroid using:

```sh
sudo apt install waydroid -y
```

---

### Initialize Waydroid

**Waydroid initialization** must be done from within the **Weston session**. Follow these steps to initialize Waydroid:

1. **Start Weston:**

   In a terminal, run:

   ```sh
   weston --socket=mysocket
   ```

   This command starts a Weston session on the specified socket.

2. **Switch to the Weston terminal:**

   In the Weston terminal window (where Weston is running), perform one of the following initialization commands depending on your preference.

#### Vanilla Android Initialization

To initialize Waydroid without Google Apps (GAPPS), run:

```sh
sudo waydroid init
```

#### Android with GAPPS

To initialize Waydroid with Google Apps (GAPPS) support, use:

```sh
sudo waydroid init -f -s GAPPS
```

After initialization, Waydroid is ready to be launched. You can now proceed with launching Waydroid using the instructions below.

---

## Usage

### Launching Waydroid

Once initialized, you can launch Waydroid within a Weston session using the following steps:

1. **Start Weston:**

   In a terminal, run:

   ```sh
   weston --socket=mysocket
   ```

   This command initializes a Weston session with a specific socket.

2. **Launch Waydroid:**

   Inside the Weston terminal, start the Waydroid user interface:

   ```sh
   waydroid show-full-ui
   ```

   This will boot the full Android system within the Wayland environment.

### Stopping Waydroid

When you are finished using Waydroid, you can stop the session by running:

```sh
waydroid session stop
```

This will gracefully terminate the Waydroid session.

---

## Additional Configuration

### Hiding Waydroid Apps from the System Launcher

By default, Waydroid apps may appear in your system launcher. To prevent this and keep your launcher clean, run the following script:

```sh
for a in ~/.local/share/applications/waydroid.*.desktop; do
    grep -q NoDisplay $a || sed '/^Icon=/a NoDisplay=true' -i $a
done
```

This script adds the `NoDisplay=true` entry to each Waydroid `.desktop` file, effectively hiding them from the system launcher.

### Enable Clipboard on Weston

To enable clipboard functionality between Weston and X11 environments, follow these steps:

1. **Install pyclip (Python clipboard library):**

   ```sh
   sudo pip install pyclip
   ```

2. **Install wl-clipboard (Wayland clipboard utility):**

   ```sh
   sudo apt install wl-clipboard
   ```

With these tools, you can now share clipboard data between your Waydroid session and the X11 environment, making copy-pasting more seamless.

---

## Automation

You can automate Waydroid’s startup and shutdown processes by creating scripts and a desktop entry.

### Creating Automated Startup Scripts

#### 1. Create a Weston Configuration File

Create a `~/.config/weston.ini` file to configure Weston’s behavior:

```ini
[libinput]
enable-tap=true

[shell]
panel-position=none
```

This configuration improves input handling and removes the panel from Weston.

#### 2. Create a Waydroid Startup Script

Save the following script as `/usr/bin/waydroid-session.sh`:

```sh
#!/bin/bash

# Start Weston
weston --xwayland &
WESTON_PID=$!
export WAYLAND_DISPLAY=wayland-1
sleep 2

# Launch Waydroid
waydroid show-full-ui &
WAYDROID_PID=$!

# Function to stop Waydroid
stop_waydroid() {
    waydroid session stop
    kill $WESTON_PID
    kill $WAYDROID_PID 2>/dev/null
}

# Wait for Weston to finish
wait $WESTON_PID

# Stop Waydroid after Weston exits
stop_waydroid
```

Make the script executable:

```sh
chmod +x /usr/bin/waydroid-session.sh
```

#### 3. Create a Desktop Entry

Create a desktop entry to easily launch the session from your system launcher. Save the following as `/usr/share/applications/waydroid-session.desktop`:

```ini
[Desktop Entry]
Version=1.0
Type=Application
Name=Waydroid Session
Comment=Launch Waydroid X11 Session
Exec=/bin/bash -c "cd /usr/bin && ./waydroid-session.sh"
Icon=waydroid
Terminal=false
Categories=System;Emulator;
```

Make the desktop entry executable:

```sh
chmod +x /usr/share/applications/waydroid-session.desktop
```

---

## Troubleshooting

If you encounter any issues, consider the following:

- **Weston fails to start:** Ensure that you have Weston installed and your X11 session is running correctly.
- **Waydroid session does not launch:** Check your Weston configuration and ensure that Waydroid is properly installed.
- **Performance issues:** Consider allocating more system resources to Waydroid and Weston by adjusting your system settings.

For advanced troubleshooting, consult the [official Waydroid documentation](https://docs.waydro.id/).

---

## References

- [Waydroid Official Documentation](https://docs.waydro.id/)
- [Weston Reference Documentation](https://wayland.freedesktop.org/)

---

This guide now includes the initialization steps for Waydroid, both with and without GAPPS, and instructions for enabling clipboard functionality inside the Weston.
