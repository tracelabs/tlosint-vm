#!/bin/bash
# Install Obsidian app image to desktop of user

# username set when launchine the build
username=$1

download_link=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | sed 's/[()",{}]/ /g; s/ /\n/g' | grep "https.*releases/download/.*AppImage" | grep -v arm64)
wget -O /home/$username/Obsidian.AppImage $download_link
chmod +x /home/$username/Obsidian.AppImage
chmod +x /home/$username/Desktop/obsidian.desktop