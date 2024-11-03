#!/bin/bash

# Waydroid Uninstallation Script for Ubuntu-based Systems
# This script will remove Waydroid, Weston, and any related packages and configuration files.

echo "Starting Waydroid uninstallation..."

# Stop Waydroid service if running
sudo systemctl stop waydroid-container
sudo systemctl disable waydroid-container

# Remove Waydroid and related packages
sudo apt purge --auto-remove waydroid weston -y

# Remove any remaining configuration or data files
sudo rm -rf /var/lib/waydroid /usr/lib/waydroid /etc/waydroid
sudo rm -rf ~/.waydroid

# Remove Waydroid service files
sudo rm -f /etc/systemd/system/waydroid-container.service

# Reload systemd daemon to ensure no leftover services
sudo systemctl daemon-reload

# Clean up any unused dependencies and cache
sudo apt autoremove -y
sudo apt autoclean

echo "Waydroid and related components have been successfully removed."
