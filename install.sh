#!/bin/bash

# Waydroid Complete Auto Installer Script

set -e

# Function to check for root privileges
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "This script must be run as root. Use sudo." >&2
        exit 1
    fi
}

# Function to install prerequisites
install_prerequisites() {
    echo "Installing prerequisites..."
    sudo apt update
    sudo apt install -y curl ca-certificates python3-pip wl-clipboard
}

# Function to install nested Wayland compositors (Cage default in session script; Weston optional)
install_compositors() {
    echo "Installing Cage and Weston..."
    sudo apt install -y cage weston
}

# Function to install Waydroid
install_waydroid() {
    echo "Adding Waydroid repository..."
    curl https://repo.waydro.id | sudo bash

    echo "Installing Waydroid..."
    sudo apt install -y waydroid
}

# Function to initialize Waydroid
initialize_waydroid() {
    echo "Choose Android mode for Waydroid:"
    echo "1) Vanilla (No Google Apps)"
    echo "2) GApps (With Google Apps)"
    read -rp "Enter your choice (1 or 2): " choice

    case $choice in
        1)
            echo "Initializing Waydroid without Google Apps..."
            sudo waydroid init
            ;;
        2)
            echo "Initializing Waydroid with Google Apps..."
            sudo waydroid init -f -s GAPPS
            ;;
        *)
            echo "Invalid choice. Please run the script again."
            exit 1
            ;;
    esac
}

# Function to configure additional settings
configure_additional_settings() {
    echo "Configuring clipboard integration..."
    sudo pip3 install pyclip

    echo "Creating Weston configuration..."
    mkdir -p ~/.config
    cat <<EOF > ~/.config/weston.ini
[libinput]
enable-tap=true

[shell]
panel-position=none
EOF

    echo "Creating Waydroid automation script..."
    _install_dir=""
    if [ -n "${BASH_SOURCE[0]:-}" ] && [ "${BASH_SOURCE[0]}" != "bash" ] && [ "${BASH_SOURCE[0]}" != "-bash" ]; then
        _install_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    fi
    if [ -n "$_install_dir" ] && [ -f "$_install_dir/waydroid-session.sh" ]; then
        sudo install -m 755 "$_install_dir/waydroid-session.sh" /usr/bin/waydroid-session.sh
    else
        sudo tee /usr/bin/waydroid-session.sh > /dev/null <<'EOS'
#!/bin/bash

# Start Waydroid inside a nested Wayland compositor on X11.
#
# Default compositor is Cage (more stable across suspend/resume than Weston
# for many setups). Override with:
#   WAYDROID_COMPOSITOR=weston waydroid-session.sh

cd "$(dirname "$0")" || exit 1

COMPOSITOR="${WAYDROID_COMPOSITOR:-cage}"
COMPOSITOR=$(printf '%s' "$COMPOSITOR" | tr '[:upper:]' '[:lower:]')

COMPOSITOR_PID=
WAYDROID_PID=

cleanup() {
  trap - EXIT INT TERM HUP

  waydroid session stop 2>/dev/null || true

  if [ -n "${WAYDROID_PID:-}" ]; then
    kill "$WAYDROID_PID" 2>/dev/null || true
    wait "$WAYDROID_PID" 2>/dev/null || true
  fi

  if [ -n "${COMPOSITOR_PID:-}" ]; then
    kill "$COMPOSITOR_PID" 2>/dev/null || true
    wait "$COMPOSITOR_PID" 2>/dev/null || true
  fi

  killall waydroid 2>/dev/null || true

  case "$COMPOSITOR" in
    weston) killall weston 2>/dev/null || true ;;
    cage)   killall cage 2>/dev/null || true ;;
  esac
}

trap cleanup EXIT INT TERM HUP

run_cage() {
  if ! command -v cage >/dev/null 2>&1; then
    echo "cage not found; install it (e.g. sudo apt install cage) or use WAYDROID_COMPOSITOR=weston" >&2
    exit 1
  fi
  # Foreground: do not exec, so EXIT trap still runs when Cage exits.
  cage -s -- waydroid show-full-ui
}

run_weston() {
  if ! command -v weston >/dev/null 2>&1; then
    echo "weston not found" >&2
    exit 1
  fi
  weston --xwayland &
  COMPOSITOR_PID=$!
  # First nested Weston on a typical X11 desktop uses wayland-0 (Waydroid default).
  export WAYLAND_DISPLAY=wayland-0
  sleep 2
  waydroid show-full-ui &
  WAYDROID_PID=$!
  wait "$COMPOSITOR_PID"
}

case "$COMPOSITOR" in
  cage)  run_cage ;;
  weston) run_weston ;;
  *)
    echo "Unknown WAYDROID_COMPOSITOR=$COMPOSITOR (use cage or weston)" >&2
    exit 1
    ;;
esac
EOS
        sudo chmod +x /usr/bin/waydroid-session.sh
    fi

    echo "Creating Waydroid desktop entry..."
    sudo bash -c 'cat <<EOF > /usr/share/applications/waydroid-session.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Waydroid Session
Comment=Start Waydroid in Cage (WAYDROID_COMPOSITOR=weston for Weston)
Exec=/usr/bin/waydroid-session.sh
Icon=waydroid
Terminal=false
Categories=System;Emulator;
EOF'
    sudo chmod +x /usr/share/applications/waydroid-session.desktop
}

# Main script execution
main() {
    check_root
    install_prerequisites
    install_compositors
    install_waydroid
    initialize_waydroid
    configure_additional_settings

    echo "Waydroid installation and configuration complete!"
    echo "To start Waydroid, use the Waydroid Session desktop entry or run:"
    echo "  waydroid-session.sh"
    echo "Legacy Weston-style (if needed): WAYDROID_COMPOSITOR=weston waydroid-session.sh"
}

main
