# Waydroid Installation and Usage Guide on X11

## Table of Contents
1. [Introduction](#introduction)
2. [Installation](#installation)
   - [Install Weston](#install-weston)
   - [Install Waydroid](#install-waydroid)
3. [Usage](#usage)
   - [Running Waydroid](#running-waydroid)
   - [Stopping Waydroid](#stopping-waydroid)
4. [Additional Configuration](#additional-configuration)
   - [Hiding Waydroid Apps from System Launcher](#hiding-waydroid-apps-from-system-launcher)
5. [Automation](#automation)
6. [References](#references)

## Introduction

This guide provides step-by-step instructions for installing and using Waydroid on an X11 system. Waydroid is a container-based approach to boot a full Android system on Linux.

## Installation

### Install Weston

Weston is a reference implementation of a Wayland compositor. Install it using the following command:

```sh
sudo apt install weston
```

### Install Waydroid

#### Prerequisites

First, ensure you have the necessary prerequisites:

```sh
sudo apt install curl ca-certificates -y
```

#### Add the Waydroid Repository

Add the Waydroid repository to your system:

```sh
curl https://repo.waydro.id | sudo bash
```

#### Install Waydroid

Install Waydroid using the following command:

```sh
sudo apt install waydroid -y
```

## Usage

### Running Waydroid

1. Open Weston:

   ```sh
   weston --socket=mysocket
   ```

2. Inside the Weston terminal, launch Waydroid:

   ```sh
   waydroid show-full-ui
   ```

### Stopping Waydroid

To stop Waydroid, use the following command:

```sh
waydroid session stop
```

## Additional Configuration

### Hiding Waydroid Apps from System Launcher

To prevent Waydroid apps from appearing in your system launcher, run:

```sh
for a in ~/.local/share/applications/waydroid.*.desktop; do
    grep -q NoDisplay $a || sed '/^Icon=/a NoDisplay=true' -i $a
done
```

This command adds a `NoDisplay=true` entry to each Waydroid application's `.desktop` file.

## Automation

To automate the Waydroid startup process, create the following configuration files:

1. `~/.config/weston.ini`:

   ```ini
   [libinput]
   enable-tap=true

   [shell]
   panel-position=none
   ```

2. `/usr/bin/waydroid-session.sh`:

   ```sh
   #!/bin/bash

   # Ensure the script is run from its directory
   cd "$(dirname "$0")"

   start_waydroid() {
       weston --xwayland &
       WESTON_PID=$!
       export WAYLAND_DISPLAY=wayland-1
       sleep 2
       waydroid show-full-ui &
       WAYDROID_PID=$!
   }

   stop_waydroid() {
       # Stop Waydroid session
       waydroid session stop

       # Kill Weston
       if [ -n "$WESTON_PID" ]; then
           kill $WESTON_PID
       else
           killall weston
       fi

       # Ensure Waydroid is stopped
       if [ -n "$WAYDROID_PID" ]; then
           kill $WAYDROID_PID 2>/dev/null
       fi
       killall waydroid 2>/dev/null
   }

   # Start Waydroid
   start_waydroid

   # Wait for Weston to exit
   wait $WESTON_PID

   # When Weston exits, stop the session
   stop_waydroid
   ```

   Make sure to make this script executable:

   ```sh
   chmod +x waydroid-session.sh
   ```

3. `/usr/share/applications/waydroid-session.desktop`:

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

   Make sure to make this .desktop file executable:

   ```sh
   chmod +x /usr/share/applications/waydroid-session.desktop
   ```

## References

For more detailed information, refer to the [official Waydroid documentation](https://docs.waydro.id/).
