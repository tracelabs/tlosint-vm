#!/bin/bash
# shellcheck disable=SC2086
# Install the Obsidian AppImage into the target user's home directory.
# The TL-Vault and obsidian.desktop launcher are delivered via the skel overlay
# (overlays/tl-overlays/etc/skel/Desktop/), so this script only handles the
# binary download and permissions/ownership.

set -euo pipefail

username=$1
home="/home/${username}"
appimage_url="https://github.com/obsidianmd/obsidian-releases/releases/download/v1.5.12/Obsidian-1.5.12.AppImage"
appimage_path="${home}/Obsidian.AppImage"

wget -O "${appimage_path}" "${appimage_url}"
chmod 0755 "${appimage_path}"
chown "${username}:${username}" "${appimage_path}"

if [ -f "${home}/Desktop/obsidian.desktop" ]; then
    chmod 0755 "${home}/Desktop/obsidian.desktop"
fi
