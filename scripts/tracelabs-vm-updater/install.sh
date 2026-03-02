#!/bin/bash
# ============================================================
# Trace Labs VM Updater - Installer
# https://github.com/tracelabs/tl-vm-updater
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

banner() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     Trace Labs VM Updater Installer      ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
    echo ""
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}[!] This installer must be run as root.${NC}"
        echo "    Run: sudo ./install.sh"
        exit 1
    fi
}

check_deps() {
    echo -e "${CYAN}[*] Checking dependencies...${NC}"
    local missing=()

    command -v python3 >/dev/null 2>&1 || missing+=("python3")
    command -v notify-send >/dev/null 2>&1 || missing+=("libnotify-bin")
    python3 -c "import gi" 2>/dev/null || missing+=("python3-gi")

    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${YELLOW}[!] Installing missing dependencies: ${missing[*]}${NC}"
        apt-get install -y "${missing[@]}" gir1.2-gtk-3.0 python3-gi-cairo
    else
        echo -e "${GREEN}[✓] All dependencies satisfied.${NC}"
    fi
}

install_scripts() {
    echo -e "${CYAN}[*] Installing scripts to /usr/local/bin/...${NC}"

    for script in tl-check-updates tl-notify-updates tl-updater-gui tl-run-updates; do
        install -m 755 "$REPO_DIR/bin/$script" "/usr/local/bin/$script"
        echo -e "  ${GREEN}✓${NC} /usr/local/bin/$script"
    done
}

install_systemd() {
    echo -e "${CYAN}[*] Installing systemd units...${NC}"

    install -m 644 "$REPO_DIR/systemd/tracelabs-update-check.service" /etc/systemd/system/
    install -m 644 "$REPO_DIR/systemd/tracelabs-update-check.timer" /etc/systemd/system/

    systemctl daemon-reload
    systemctl enable --now tracelabs-update-check.timer

    echo -e "  ${GREEN}✓${NC} Timer enabled and started"
}

install_autostart() {
    echo -e "${CYAN}[*] Installing XDG autostart entry...${NC}"
    install -m 644 "$REPO_DIR/desktop/tracelabs-updater-autostart.desktop" /etc/xdg/autostart/
    echo -e "  ${GREEN}✓${NC} Autostart entry installed"
}

install_desktop_shortcut() {
    echo -e "${CYAN}[*] Installing desktop shortcut...${NC}"

    # Find the default user's Desktop (skip root)
    TARGET_USER="${SUDO_USER:-$USER}"
    TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
    DESKTOP_DIR="$TARGET_HOME/Desktop"

    if [ -d "$DESKTOP_DIR" ]; then
        install -m 755 -o "$TARGET_USER" "$REPO_DIR/desktop/tracelabs-updater.desktop" "$DESKTOP_DIR/"
        echo -e "  ${GREEN}✓${NC} Desktop shortcut added for $TARGET_USER"
    else
        echo -e "  ${YELLOW}[!]${NC} Desktop directory not found at $DESKTOP_DIR — skipping shortcut."
    fi
}

install_polkit() {
    echo -e "${CYAN}[*] Installing polkit policy...${NC}"
    install -m 644 "$REPO_DIR/polkit/org.tracelabs.vm.update.policy" /usr/share/polkit-1/actions/
    echo -e "  ${GREEN}✓${NC} Polkit policy installed"
}

create_dirs() {
    echo -e "${CYAN}[*] Creating runtime directories...${NC}"
    mkdir -p /var/cache/tracelabs /var/log/tracelabs
    echo -e "  ${GREEN}✓${NC} /var/cache/tracelabs"
    echo -e "  ${GREEN}✓${NC} /var/log/tracelabs"
}

print_summary() {
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     Installation Complete! 🔍            ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${CYAN}Timer status:${NC}"
    systemctl status tracelabs-update-check.timer --no-pager -l | grep -E "Active|Trigger" | sed 's/^/    /'
    echo ""
    echo -e "  ${CYAN}Test commands:${NC}"
    echo "    sudo systemctl start tracelabs-update-check.service  # trigger update check now"
    echo "    python3 /usr/local/bin/tl-updater-gui               # launch GUI"
    echo "    /usr/local/bin/tl-notify-updates                    # test notification"
    echo ""
}

# ── Run installer ───────────────────────────────────────────
banner
check_root
check_deps
create_dirs
install_scripts
install_systemd
install_autostart
install_desktop_shortcut
install_polkit
print_summary
