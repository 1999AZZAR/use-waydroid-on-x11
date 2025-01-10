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

# Function to install Weston
install_weston() {
    echo "Installing Weston..."
    sudo apt install -y weston
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
    sudo bash -c 'cat <<EOF > /usr/bin/waydroid-session.sh
#!/bin/bash

weston --xwayland &
WESTON_PID=$!
export WAYLAND_DISPLAY=wayland-1
sleep 2

waydroid show-full-ui &
WAYDROID_PID=$!

trap "waydroid session stop; kill $WESTON_PID; kill $WAYDROID_PID" EXIT

wait $WESTON_PID
EOF'
    sudo chmod +x /usr/bin/waydroid-session.sh

    echo "Creating Waydroid desktop entry..."
    sudo bash -c 'cat <<EOF > /usr/share/applications/waydroid-session.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Waydroid Session
Comment=Start Waydroid in a Weston session
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
    install_weston
    install_waydroid
    initialize_waydroid
    configure_additional_settings

    echo "Waydroid installation and configuration complete!"
    echo "To start Waydroid, use the Waydroid Session desktop entry or run:"
    echo "weston --socket=mysocket & waydroid show-full-ui"
}

main
