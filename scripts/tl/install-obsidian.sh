#!/bin/bash
# Install Obsidian latest AppImage

latest_version=$(curl -sLo /dev/null/ -w %{url_effective} https://github.com/obsidianmd/obsidian-releases/releases/latest/ | grep -oP '(?<=tag/).*')
latest_link=$(curl -s https://github.com/obsidianmd/obsidian-releases/releases/expanded_assets/$latest_version | grep -v arm64 | grep -oP '(?<=href="/).*AppImage')
wget -O /home/osint/Obsidian.AppImage https://github.com/$latest_link
chmod +x /home/osint/Obsidian.AppImage
chmod +x /home/osint/Desktop/obsidian.desktop
