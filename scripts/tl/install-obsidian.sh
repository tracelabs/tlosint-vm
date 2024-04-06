#!/bin/bash
# Install Obsidian app image to desktop of user

# username set when launchine the build
username=$1

wget -O /home/$username/Obsidian.AppImage https://github.com/obsidianmd/obsidian-releases/releases/download/v1.5.12/Obsidian-1.5.12.AppImage
chmod +x /home/$username/Obsidian.AppImage
chmod +x /home/$username/Desktop/obsidian.desktop