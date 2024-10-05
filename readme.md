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
   - [Hiding Waydroid Apps from System Launcher](#hiding-waydroid-apps-from-system-launcher)
   - [Enabling Clipboard Integration in Weston](#enabling-clipboard-integration-in-weston)
6. [Automation](#automation)
   - [Automated Startup Scripts](#automated-startup-scripts)
7. [Troubleshooting](#troubleshooting)
8. [References](#references)

---

## Introduction

This guide details the process of installing and using **Waydroid** on an X11-based Linux system. Waydroid allows you to run a complete Android system in a container, seamlessly integrated into your desktop environment. This guide covers the setup, basic usage, and customization options to enhance your Waydroid experience.

---

## System Requirements

Before proceeding with the installation, ensure that your system meets the following requirements:
- Running an X11 environment.
- Administrative privileges (sudo access).
- **curl** and **ca-certificates** packages installed.

Install these dependencies by executing the command:

```sh
sudo apt install curl ca-certificates -y
```

---

## Installation

### Installing Weston

**Weston** is the Wayland compositor required for rendering the Waydroid environment. To install it, run:

```sh
sudo apt install weston -y
```

### Installing Waydroid

Follow the steps below to install Waydroid.

#### Step 1: Add the Waydroid Repository

Add the official Waydroid repository by running the following command:

```sh
curl https://repo.waydro.id | sudo bash
```

#### Step 2: Install Waydroid

Once the repository is added, install Waydroid using:

```sh
sudo apt install waydroid -y
```

---

### Initializing Waydroid

Initialization must be performed within a **Weston session**. Follow these steps to initialize Waydroid:

1. **Start Weston:**

   Open a terminal and run:

   ```sh
   weston --socket=mysocket
   ```

   This will start a Weston session on the specified socket.

2. **Initialize Waydroid:**

   In the Weston terminal, you can initialize Waydroid using one of the following commands:

   - **Vanilla Android (No Google Apps):**

     ```sh
     sudo waydroid init
     ```

   - **Android with Google Apps (GAPPS):**

     ```sh
     sudo waydroid init -f -s GAPPS
     ```

Once initialized, Waydroid is ready for use.

#### Fix for Missing Binder Module

If you encounter an error related to missing binder modules, such as:

```bash
[21:15:53] Failed to load binder driver
[21:15:53] ERROR: Binder node "binder" for waydroid not found
```

Refer to [this guide](https://github.com/choff/anbox-modules) for instructions on resolving the issue.

---

## Usage

### Launching Waydroid

Once initialized, launch Waydroid within the Weston session:

1. **Start Weston:**

   ```sh
   weston --socket=mysocket
   ```

2. **Launch Waydroid Interface:**

   In the Weston terminal, run:

   ```sh
   waydroid show-full-ui
   ```

   This will launch the full Android system in the Wayland environment.

### Stopping Waydroid

To stop Waydroid, use the following command:

```sh
waydroid session stop
```

This will gracefully terminate the session.

---

## Additional Configuration

### Hiding Waydroid Apps from System Launcher

Waydroid apps may appear in your system's application launcher by default. To hide these entries, run the following script:

```sh
for a in ~/.local/share/applications/waydroid.*.desktop; do
    grep -q NoDisplay $a || sed '/^Icon=/a NoDisplay=true' -i $a
done
```

This will add a `NoDisplay=true` entry to all Waydroid `.desktop` files, hiding them from the launcher.

### Enabling Clipboard Integration in Weston

To enable clipboard sharing between Weston and the X11 environment:

1. **Install pyclip:**

   ```sh
   sudo pip install pyclip
   ```

2. **Install wl-clipboard:**

   ```sh
   sudo apt install wl-clipboard
   ```

This allows for seamless copy-paste functionality between Waydroid and your Linux environment.

---

## Automation

To automate Waydroid startup and shutdown, follow the steps below.

### Automated Startup Scripts

#### 1. Create a Weston Configuration

Create a `~/.config/weston.ini` file with the following configuration to improve input handling and hide the panel:

```ini
[libinput]
enable-tap=true

[shell]
panel-position=none
```

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

# Stop Waydroid when Weston exits
trap "waydroid session stop; kill $WESTON_PID; kill $WAYDROID_PID" EXIT

wait $WESTON_PID
```

Make the script executable:

```sh
chmod +x /usr/bin/waydroid-session.sh
```

#### 3. Create a Desktop Entry

Create a desktop entry to launch Waydroid easily. Save the following file as `/usr/share/applications/waydroid-session.desktop`:

```ini
[Desktop Entry]
Version=1.0
Type=Application
Name=Waydroid Session
Comment=Start Waydroid in a Weston session
Exec=/bin/bash -c "cd /usr/bin && ./waydroid-session.sh"
Icon=waydroid
Terminal=false
Categories=System;Emulator;
```

Make it executable:

```sh
chmod +x /usr/share/applications/waydroid-session.desktop
```

---

## Troubleshooting

- **Weston fails to start:** Ensure Weston is correctly installed and that your X11 environment is properly configured.
- **Waydroid doesn’t launch:** Verify the Weston session is active and Waydroid is installed correctly.
- **Performance issues:** Consider adjusting your system’s resource allocation for better performance.

For more information, refer to the [official Waydroid documentation](https://docs.waydro.id/).

---

## References

- [Waydroid Official Documentation](https://docs.waydro.id/)
- [Weston Reference Documentation](https://wayland.freedesktop.org/)

---

This guide covers both the installation and configuration of Waydroid, including clipboard integration and automated startup for a smoother experience.
