#!/bin/bash
# ============================================================
# Trace Labs VM Updater - Uninstaller
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[!] Must be run as root. Use: sudo ./uninstall.sh${NC}"
    exit 1
fi

echo ""
echo -e "${CYAN}[*] Removing Trace Labs VM Updater...${NC}"

# Stop and disable timer
systemctl stop tracelabs-update-check.timer 2>/dev/null && echo "  ✓ Timer stopped"
systemctl disable tracelabs-update-check.timer 2>/dev/null && echo "  ✓ Timer disabled"

# Remove systemd units
rm -f /etc/systemd/system/tracelabs-update-check.service
rm -f /etc/systemd/system/tracelabs-update-check.timer
systemctl daemon-reload
echo "  ✓ Systemd units removed"

# Remove scripts
for script in tl-check-updates tl-notify-updates tl-updater-gui tl-run-updates; do
    rm -f "/usr/local/bin/$script"
done
echo "  ✓ Scripts removed"

# Remove desktop/autostart entries
rm -f /etc/xdg/autostart/tracelabs-updater-autostart.desktop
rm -f /usr/share/polkit-1/actions/org.tracelabs.vm.update.policy
echo "  ✓ Desktop and polkit entries removed"

# Remove state/cache files
rm -rf /var/cache/tracelabs
echo "  ✓ Cache files removed"

echo ""
echo -e "${GREEN}[✓] Trace Labs VM Updater uninstalled.${NC}"
echo "    Logs remain at /var/log/tracelabs/ — remove manually if desired."
echo ""
