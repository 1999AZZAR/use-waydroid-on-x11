#!/bin/bash

# Waydroid and Weston Uninstallation Script for Ubuntu-based Systems
# This script will remove Waydroid, Weston, associated packages, and custom desktop files and configuration directories.

echo "Starting Waydroid and Weston uninstallation..."

# Stop and disable Waydroid service if running
sudo systemctl stop waydroid-container
sudo systemctl disable waydroid-container

# Remove Waydroid package and its dependencies
sudo apt purge -y waydroid
sudo apt autoremove -y

# Remove Weston package and its dependencies
sudo apt purge -y weston
sudo apt autoremove -y

# Delete user configuration and cache related to Waydroid
rm -rf ~/.config/waydroid
rm -rf ~/.local/share/waydroid
rm -rf ~/.cache/waydroid

# Remove custom .desktop files (e.g., launchers)
find ~/.local/share/applications -type f -name '*waydroid*.desktop' -exec rm -f {} \;

# Remove any system-wide .desktop files related to Waydroid (if present)
sudo find /usr/share/applications -type f -name '*waydroid*.desktop' -exec rm -f {} \;

# Clean up remaining Waydroid directories (safety check)
sudo rm -rf /var/lib/waydroid
sudo rm -rf /etc/waydroid

echo "Waydroid and related files have been successfully removed from your system."

# Final confirmation
echo "Uninstallation complete. It is recommended to restart your system to apply changes."
