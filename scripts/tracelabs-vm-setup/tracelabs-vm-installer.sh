#!/usr/bin/env bash
# Trace Labs VM - Unified Installer Menu
# Combines: Asset Setup + Privacy Settings + Security Hardening + OSINT Tools
# Version: 1.1

set -u -o pipefail

# Ensure a sane PATH for pkexec/root sessions (pkexec often misses /snap/bin, user-local bins, etc.)
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:${PATH:-}"
export HOME="${HOME:-/root}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# Script directory (this file's directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Component scripts (match your actual filenames)
ASSET_SCRIPT="${SCRIPT_DIR}/asset-setup.sh"
PRIVACY_SCRIPT="${SCRIPT_DIR}/privacy-settings.sh"
SECURITY_SCRIPT="${SCRIPT_DIR}/security-hardening.sh"
OSINT_SCRIPT="${SCRIPT_DIR}/tlosint-tools.zsh"

# Log (use /var/log so sudo/pkexec doesn't shove logs into /root)
LOG_FILE="/var/log/tracelabs-installer.log"
sudo touch "$LOG_FILE" >/dev/null 2>&1 || true

# Logging
log_info()    { echo -e "${BLUE}[INFO]${NC} $*"    | tee -a "$LOG_FILE"; }
log_success() { echo -e "${GREEN}[✓]${NC} $*"     | tee -a "$LOG_FILE"; }
log_warn()    { echo -e "${YELLOW}[!]${NC} $*"    | tee -a "$LOG_FILE"; }
log_error()   { echo -e "${RED}[✗]${NC} $*"       | tee -a "$LOG_FILE"; }

# Run a command and log output safely (won't kill the whole installer on non-zero exit)
# Captures the true exit code even when piping to tee via PIPESTATUS[0]
run_and_log() {
  local label="$1"
  shift

  log_info "Starting: $label"
  echo -e "${CYAN}${label}${NC}" | tee -a "$LOG_FILE"

  set +e
  "$@" 2>&1 | tee -a "$LOG_FILE"
  local cmd_rc=${PIPESTATUS[0]}
  set -e 2>/dev/null || true

  if [[ $cmd_rc -ne 0 ]]; then
    log_warn "$label finished with exit code $cmd_rc (continuing)."
    return "$cmd_rc"
  fi

  log_success "$label completed successfully."
  return 0
}

# Banner
show_banner() {
  clear
  echo -e "${CYAN}"
  cat << "BANNER"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║         ████████ ██████   █████   ██████ ███████            ║
║            ██    ██   ██ ██   ██ ██      ██                 ║
║            ██    ██████  ███████ ██      █████              ║
║            ██    ██   ██ ██   ██ ██      ██                 ║
║            ██    ██   ██ ██   ██  ██████ ███████            ║
║                                                              ║
║                    ██      █████  ██████  ███████           ║
║                    ██     ██   ██ ██   ██ ██                ║
║                    ██     ███████ ██████  ███████           ║
║                    ██     ██   ██ ██   ██      ██           ║
║                    ██████ ██   ██ ██████  ███████           ║
║                                                              ║
║              Trace Labs OSINT VM - Setup Installer          ║
║                        Version 1.1                           ║
╚══════════════════════════════════════════════════════════════╝
BANNER
  echo -e "${NC}"
}

check_root() {
  if [[ ${EUID} -ne 0 ]]; then
    log_error "This script must be run as root"
    echo -e "${YELLOW}Please run: sudo $0${NC}"
    exit 1
  fi
}

# Execute a script in a way that matches "su root; cd into folder; run"
# - cd into script directory first (fixes relative paths)
# - run through a login shell (fixes env differences vs pkexec)
run_component_script() {
  local script="$1"
  if [[ ! -f "$script" ]]; then
    log_error "Script not found: $script"
    return 2
  fi

  local dir base
  dir="$(cd "$(dirname "$script")" && pwd)"
  base="$(basename "$script")"

  case "$script" in
    *.zsh)
      # Login-style zsh, run from script directory
      zsh -lc "cd '$dir' && zsh './$base'"
      ;;
    *)
      # Login-style bash, run from script directory
      bash -lc "cd '$dir' && bash './$base'"
      ;;
  esac
}

prompt_continue() {
  local msg="$1"
  echo ""
  read -p "$msg [y/N] " -n 1 -r
  echo
  [[ "$REPLY" =~ ^[Yy]$ ]]
}

how_to_use_vm() {
  show_banner
  echo -e "${MAGENTA}${BOLD}═══════════════════════════════════════════${NC}"
  echo -e "${MAGENTA}${BOLD}    TRACE LABS VM USAGE GUIDE${NC}"
  echo -e "${MAGENTA}${BOLD}═══════════════════════════════════════════${NC}"
  echo ""

  local usage_file="${SCRIPT_DIR}/usage.txt"

  if [[ -f "$usage_file" ]]; then
    less "$usage_file"
  else
    echo -e "${RED}Usage file not found:${NC} $usage_file"
    echo ""
    echo "Please ensure usage.txt exists in the setup directory."
    read -p "Press Enter to return to the menu..."
  fi
}


install_asset_setup() {
  show_banner
  echo -e "${MAGENTA}${BOLD}═══════════════════════════════════════════${NC}"
  echo -e "${MAGENTA}${BOLD}    ASSET SETUP${NC}"
  echo -e "${MAGENTA}${BOLD}═══════════════════════════════════════════${NC}"
  echo ""
  echo -e "${CYAN}This will:${NC}"
  echo "  • Apply wallpapers / branding assets (if configured)"
  echo "  • Set up folders or VM cosmetics (depends on your script)"
  echo ""

  if ! prompt_continue "Continue?"; then
    log_warn "Asset setup cancelled"
    return 0
  fi

  log_info "Running asset setup..."
  run_and_log "Asset setup" run_component_script "$ASSET_SCRIPT"
  local rc=$?
  echo ""
  read -p "Press Enter to continue..."
  return $rc
}

install_privacy_settings() {
  show_banner
  echo -e "${MAGENTA}${BOLD}═══════════════════════════════════════════${NC}"
  echo -e "${MAGENTA}${BOLD}    PRIVACY SETTINGS${NC}"
  echo -e "${MAGENTA}${BOLD}═══════════════════════════════════════════${NC}"
  echo ""
  echo -e "${CYAN}This will:${NC}"
  echo "  • Apply privacy cleanup/settings (depends on your script)"
  echo ""

  if ! prompt_continue "Continue?"; then
    log_warn "Privacy settings cancelled"
    return 0
  fi

  log_info "Running privacy settings..."
  run_and_log "Privacy settings" run_component_script "$PRIVACY_SCRIPT"
  local rc=$?
  echo ""
  read -p "Press Enter to continue..."
  return $rc
}

install_security_hardening() {
  show_banner
  echo -e "${MAGENTA}${BOLD}═══════════════════════════════════════════${NC}"
  echo -e "${MAGENTA}${BOLD}    SECURITY HARDENING${NC}"
  echo -e "${MAGENTA}${BOLD}═══════════════════════════════════════════${NC}"
  echo ""
  echo -e "${CYAN}This will:${NC}"
  echo "  • Firewall / updates / hardening (depends on your script)"
  echo ""

  if ! prompt_continue "Continue?"; then
    log_warn "Security hardening cancelled"
    return 0
  fi

  log_info "Running security hardening..."
  run_and_log "Security hardening" run_component_script "$SECURITY_SCRIPT"
  local rc=$?
  echo ""
  read -p "Press Enter to continue..."
  return $rc
}

install_osint_tools() {
  show_banner
  echo -e "${MAGENTA}${BOLD}═══════════════════════════════════════════${NC}"
  echo -e "${MAGENTA}${BOLD}    OSINT TOOLS INSTALLATION${NC}"
  echo -e "${MAGENTA}${BOLD}═══════════════════════════════════════════${NC}"
  echo ""
  echo -e "${CYAN}This will:${NC}"
  echo "  • Install Trace Labs OSINT tool suite (depends on your script)"
  echo ""

  if ! prompt_continue "Continue?"; then
    log_warn "OSINT tools installation cancelled"
    return 0
  fi

  log_info "Running OSINT tools installer..."
  run_and_log "OSINT tools installer" run_component_script "$OSINT_SCRIPT"
  local rc=$?
  echo ""
  read -p "Press Enter to continue..."
  return $rc
}

run_full_setup() {
  show_banner
  echo -e "${MAGENTA}${BOLD}═══════════════════════════════════════════${NC}"
  echo -e "${MAGENTA}${BOLD}    FULL SETUP (RECOMMENDED)${NC}"
  echo -e "${MAGENTA}${BOLD}═══════════════════════════════════════════${NC}"
  echo ""
  echo -e "${CYAN}This runs:${NC}"
  echo "  1) OSINT Tools"
  echo "  2) Privacy Settings"
  echo "  3) Security Hardening"
  echo ""

  if ! prompt_continue "Are you ready to begin?"; then
    log_warn "Full setup cancelled"
    return 0
  fi

  local failed=0

  echo -e "${BOLD}${CYAN}[1/3] OSINT Tools...${NC}"
  install_osint_tools || failed=1

  echo -e "${BOLD}${CYAN}[2/3] Privacy Settings...${NC}"
  install_privacy_settings || failed=1

  echo -e "${BOLD}${CYAN}[3/3] Security Hardening...${NC}"
  install_security_hardening || failed=1

  show_banner
  echo ""
  if (( failed == 0 )); then
    echo -e "${GREEN}${BOLD}✓ Full setup completed successfully!${NC}"
  else
    echo -e "${YELLOW}${BOLD}⚠ Setup finished with some issues.${NC}"
    echo "Check log: $LOG_FILE"
  fi
  echo ""
  read -p "Press Enter to return to menu..."
  return 0
}

show_system_info() {
  show_banner
  echo -e "${MAGENTA}${BOLD}═══════════════════════════════════════════${NC}"
  echo -e "${MAGENTA}${BOLD}    SYSTEM INFORMATION${NC}"
  echo -e "${MAGENTA}${BOLD}═══════════════════════════════════════════${NC}"
  echo ""

  echo -e "${CYAN}OS:${NC}"
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    echo "  $NAME $VERSION ($VERSION_CODENAME)"
  fi
  echo ""

  echo -e "${CYAN}Disk:${NC}"
  df -h / | tail -1 | awk '{print "  "$0}'
  echo ""

  echo -e "${CYAN}Memory:${NC}"
  free -h | awk 'NR==2{print "  Total: "$2"  Used: "$3"  Free: "$4}'
  echo ""

  echo -e "${CYAN}Component Scripts:${NC}"
  [[ -f "$ASSET_SCRIPT"   ]] && echo -e "  ${GREEN}✓${NC} asset-setup.sh"         || echo -e "  ${RED}✗${NC} asset-setup.sh"
  [[ -f "$OSINT_SCRIPT"   ]] && echo -e "  ${GREEN}✓${NC} tlosint-tools.zsh"      || echo -e "  ${RED}✗${NC} tlosint-tools.zsh"
  [[ -f "$PRIVACY_SCRIPT" ]] && echo -e "  ${GREEN}✓${NC} privacy-settings.sh"    || echo -e "  ${RED}✗${NC} privacy-settings.sh"
  [[ -f "$SECURITY_SCRIPT" ]] && echo -e "  ${GREEN}✓${NC} security-hardening.sh"  || echo -e "  ${RED}✗${NC} security-hardening.sh"
  echo ""

  echo -e "${CYAN}Log:${NC} $LOG_FILE"
  echo ""
  read -p "Press Enter to continue..."
}

view_log() {
  show_banner
  echo -e "${MAGENTA}${BOLD}═══════════════════════════════════════════${NC}"
  echo -e "${MAGENTA}${BOLD}    INSTALLATION LOG${NC}"
  echo -e "${MAGENTA}${BOLD}═══════════════════════════════════════════${NC}"
  echo ""
  if [[ -f "$LOG_FILE" ]]; then
    tail -80 "$LOG_FILE" || true
    echo ""
    echo -e "${CYAN}Full log:${NC} $LOG_FILE"
  else
    echo "No log file found yet."
  fi
  echo ""
  read -p "Press Enter to continue..."
}

show_about() {
  show_banner
  echo -e "${MAGENTA}${BOLD}═══════════════════════════════════════════${NC}"
  echo -e "${MAGENTA}${BOLD}    ABOUT${NC}"
  echo -e "${MAGENTA}${BOLD}═══════════════════════════════════════════${NC}"
  echo ""
  echo "Trace Labs OSINT VM - Unified Installer"
  echo "Version: 1.1"
  echo ""
  echo "Includes:"
  echo "  • Asset Setup"
  echo "  • OSINT Tools installer (zsh)"
  echo "  • Privacy Settings"
  echo "  • Security Hardening"
  echo ""
  echo "Log: $LOG_FILE"
  echo ""
  read -p "Press Enter to continue..."
}

show_menu() {
  show_banner
  echo -e "${CYAN}${BOLD}Main Menu${NC}"
  echo -e "${CYAN}═════════════════════════════════════════════════${NC}"
  echo ""
  echo -e "  ${BOLD}1)${NC} How to use Trace Labs VM (press q when finished)"
  echo -e "  ${BOLD}2)${NC} Install OSINT Tools"
  echo -e "  ${BOLD}3)${NC} Apply Privacy Settings"
  echo -e "  ${BOLD}4)${NC} Apply Security Hardening"
  echo ""
  echo -e "  ${BOLD}5)${NC} ${GREEN}${BOLD}Run Full Setup (Recommended)${NC}"
  echo ""
  echo -e "  ${BOLD}6)${NC} System Information"
  echo -e "  ${BOLD}7)${NC} View Installation Log"
  echo -e "  ${BOLD}8)${NC} About"
  echo ""
  echo -e "  ${BOLD}0)${NC} Exit"
  echo ""
  echo -e "${CYAN}═════════════════════════════════════════════════${NC}"
  echo -n "Select an option: "
}

main() {
  check_root
  echo "=== Trace Labs VM Installer - $(date) ===" >> "$LOG_FILE"

  while true; do
    show_menu
    read -r choice

    case "$choice" in
      1) how_to_use_vm ;;
      2) install_osint_tools ;;
      3) install_privacy_settings ;;
      4) install_security_hardening ;;
      5) run_full_setup ;;
      6) show_system_info ;;
      7) view_log ;;
      8) show_about ;;
      0)
        show_banner
        echo -e "${GREEN}Thank you for using Trace Labs VM Installer!${NC}"
        log_info "Installer exited normally"
        exit 0
        ;;
      *)
        echo -e "${RED}Invalid option. Please try again.${NC}"
        sleep 1
        ;;
    esac
  done
}

main
