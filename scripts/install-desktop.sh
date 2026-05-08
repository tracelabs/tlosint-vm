#!/bin/sh

# Installs a desktop environment based on the variant requested at build
# time, then compiles any dconf overrides laid down by the tl-overlays
# action (e.g. the GNOME wallpaper defaults at
# /etc/dconf/db/local.d/01-tracelabs-background).
#
# This script must run AFTER the tl-overlays overlay action, because
# `dconf update` reads files the overlay has just placed.

set -eu

desktop=$1

export DEBIAN_FRONTEND=noninteractive

case $desktop in
    headless)
        echo "INFO: headless variant — skipping desktop install"
        exit 0
        ;;
    # greybird-gtk-theme provides the Greybird-dark variant referenced by
    # the dark-mode xsettings/lightdm overlay configs.
    xfce)     pkgs="task-xfce-desktop greybird-gtk-theme" ;;
    gnome)    pkgs="gnome-core dconf-cli" ;;
    kde)      pkgs="task-kde-desktop" ;;
    lxde)     pkgs="task-lxde-desktop" ;;
    mate)     pkgs="task-mate-desktop dconf-cli" ;;
    i3)       pkgs="xorg lightdm i3 i3status dmenu" ;;
    e17)      pkgs="xorg lightdm enlightenment" ;;
    *)
        echo "ERROR: unsupported desktop '$desktop'"
        exit 1
        ;;
esac

apt-get update
apt-get install -y $pkgs
apt-get clean

# Compile dconf overrides for desktops that use dconf (GNOME, MATE).
# A no-op on desktops without dconf-cli installed.
if command -v dconf >/dev/null 2>&1; then
    dconf update
fi
