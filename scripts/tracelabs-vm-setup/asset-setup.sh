#!/bin/bash

# Trace Labs VM Branding Setup Script
# This script sets up wallpapers, login screen, and user icon for the Trace Labs VM

set -e  # Exit on error

echo "==================================="
echo "Trace Labs VM Branding Setup"
echo "==================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
   echo "Please do not run this script as root. Run as your normal user."
   echo "The script will use sudo when needed."
   exit 1
fi

# Get the username
USERNAME=$(whoami)
echo "Setting up branding for user: $USERNAME"
echo ""

# Check if asset files exist in current directory
ASSETS_DIR=$(pwd)
WALLPAPER="$ASSETS_DIR/tracelabs-wallpaper.png"
LOGO="$ASSETS_DIR/tracelabs-logo.jpg"

echo "Checking for required asset files..."
missing_files=0

if [ ! -f "$WALLPAPER" ]; then
    echo "❌ Missing: tracelabs-wallpaper.png"
    missing_files=1
fi

if [ ! -f "$LOGO" ]; then
    echo "❌ Missing: tracelabs-logo.jpg"
    missing_files=1
fi

if [ $missing_files -eq 1 ]; then
    echo ""
    echo "Please ensure these files are in the current directory:"
    echo "  - tracelabs-wallpaper.png (desktop and login wallpaper)"
    echo "  - tracelabs-logo.jpg (user icon/logo)"
    exit 1
fi

echo "✓ All asset files found!"
echo ""

# Create system directories
echo "Creating system directories..."
sudo mkdir -p /usr/share/backgrounds/tracelabs
sudo mkdir -p /usr/share/pixmaps/tracelabs

# Copy assets
echo "Copying branding assets..."
sudo cp "$WALLPAPER" /usr/share/backgrounds/tracelabs/
sudo cp "$LOGO" /usr/share/pixmaps/tracelabs/

# Set permissions
echo "Setting permissions..."
sudo chmod 644 /usr/share/backgrounds/tracelabs/*
sudo chmod 644 /usr/share/pixmaps/tracelabs/*

# Configure XFCE desktop wallpaper for current user
echo "Configuring XFCE desktop wallpaper..."
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s /usr/share/backgrounds/tracelabs/tracelabs-wallpaper.png 2>/dev/null || \
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -n -t string -s /usr/share/backgrounds/tracelabs/tracelabs-wallpaper.png

# Set image style to zoomed (5)
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/image-style -s 5 2>/dev/null || \
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/image-style -n -t int -s 5

# Configure default wallpaper for new users
echo "Setting default wallpaper for new users..."
sudo mkdir -p /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/

sudo tee /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml > /dev/null << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/tracelabs/tracelabs-wallpaper.png"/>
        </property>
      </property>
    </property>
  </property>
</channel>
EOF

# Configure LightDM login screen
echo "Configuring LightDM login screen..."

# Backup existing config if it exists
if [ -f /etc/lightdm/lightdm-gtk-greeter.conf ]; then
    sudo cp /etc/lightdm/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf.backup
    echo "  (Backed up existing config to lightdm-gtk-greeter.conf.backup)"
fi

# Create or update LightDM config
sudo tee /etc/lightdm/lightdm-gtk-greeter.conf > /dev/null << EOF
[greeter]
background=/usr/share/backgrounds/tracelabs/tracelabs-wallpaper.png
theme-name=Adwaita-dark
icon-theme-name=Adwaita
user-background=false
hide-user-image=false
default-user-image=/usr/share/pixmaps/tracelabs/tracelabs-logo.jpg
EOF

# Set user account icon
echo "Setting user account icon..."
sudo mkdir -p /var/lib/AccountsService/users/

sudo tee /var/lib/AccountsService/users/$USERNAME > /dev/null << EOF
[User]
Icon=/usr/share/pixmaps/tracelabs/tracelabs-logo.jpg
EOF

sudo chmod 644 /var/lib/AccountsService/users/$USERNAME

# Restart AccountsService to pick up changes
echo "Restarting AccountsService..."
sudo systemctl restart accounts-daemon

# Reload XFCE desktop
echo "Reloading XFCE desktop..."
xfdesktop --reload &

echo ""
echo "==================================="
echo "✓ Branding setup complete!"
echo "==================================="
echo ""
echo "Changes applied:"
echo "  ✓ Desktop wallpaper set"
echo "  ✓ Login screen background configured"
echo "  ✓ Login icon configured"
echo "  ✓ Default settings for new users configured"
echo ""
echo "To see login screen changes, restart LightDM with:"
echo "  sudo systemctl restart lightdm"
echo ""
echo "WARNING: Restarting LightDM will log you out!"
echo ""

read -p "Would you like to restart LightDM now? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Restarting LightDM..."
    sudo systemctl restart lightdm
else
    echo "Skipped LightDM restart. Changes will take effect on next login/reboot."
fi
