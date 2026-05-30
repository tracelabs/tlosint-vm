#!/bin/bash
# shellcheck disable=SC2086
# Install the Obsidian AppImage into the target user's home directory.
# The TL-Vault and obsidian.desktop launcher are delivered via the skel overlay
# (overlays/tl-overlays/etc/skel/Desktop/), so this script only handles the
# binary download and permissions/ownership.
# Supports amd64 and arm64.

set -euo pipefail

username=$1
home="/home/${username}"
OBSIDIAN_VERSION="1.12.7"
ARCH=$(dpkg --print-architecture)

case "$ARCH" in
    arm64)
        appimage_url="https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/Obsidian-${OBSIDIAN_VERSION}-arm64.AppImage"
        ;;
    amd64)
        appimage_url="https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/Obsidian-${OBSIDIAN_VERSION}.AppImage"
        ;;
    *)
        echo "WARNING: Unsupported architecture '$ARCH', skipping Obsidian install"
        exit 0
        ;;
esac

appimage_path="${home}/Obsidian.AppImage"
wget -O "${appimage_path}" "${appimage_url}"
chmod 0755 "${appimage_path}"
chown "${username}:${username}" "${appimage_path}"

if [ -f "${home}/Desktop/obsidian.desktop" ]; then
    chmod 0755 "${home}/Desktop/obsidian.desktop"
fi
