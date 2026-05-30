#!/bin/sh

# Sets the Trace Labs wallpaper for every connected RandR output XFCE
# can see. Runs once per user via /etc/xdg/autostart, then drops a marker
# so it doesn't re-run on every login. We need the runtime detection
# because xfce4-desktop.xml's static monitorN keys don't match the
# RandR connector names that modern xfdesktop (4.16+) actually queries.

set -eu

WALLPAPER=/usr/share/backgrounds/tracelabs/tracelabs.png
MARKER="${HOME}/.config/tracelabs/wallpaper-applied"

[ -f "$WALLPAPER" ] || exit 0
[ -f "$MARKER" ] && exit 0
command -v xfconf-query >/dev/null 2>&1 || exit 0
command -v xrandr >/dev/null 2>&1 || exit 0

# All connected RandR outputs (e.g. Virtual-1, DP-1, eDP-1).
outputs=$(xrandr --query 2>/dev/null \
    | awk '/ connected/ {print $1}')

[ -n "$outputs" ] || exit 0

for out in $outputs; do
    base="/backdrop/screen0/monitor${out}/workspace0"
    xfconf-query -c xfce4-desktop -p "${base}/last-image" \
        -n -t string -s "$WALLPAPER" 2>/dev/null \
    || xfconf-query -c xfce4-desktop -p "${base}/last-image" \
        -t string -s "$WALLPAPER"
    xfconf-query -c xfce4-desktop -p "${base}/image-style" \
        -n -t int -s 5 2>/dev/null \
    || xfconf-query -c xfce4-desktop -p "${base}/image-style" \
        -t int -s 5
done

# Tell xfdesktop to reload backdrops.
xfdesktop --reload >/dev/null 2>&1 || true

mkdir -p "$(dirname "$MARKER")"
touch "$MARKER"
