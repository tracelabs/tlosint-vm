#!/usr/bin/env bash
# Trace Labs VM Fast Bootstrap
# - Downloads setup folder (GitHub repo zip OR release tarball)
# - Installs to /usr/local/share/trace-labs-vm-setup
# - Fixes permissions
# - Installs desktop launcher
# - Runs asset-setup.sh (branding)
# - Sets autostart to launch the installer menu on first login
# - Prints COMPLETE + reboots

set -euo pipefail

########################################
# Defaults (EDIT THESE)
########################################
DEFAULT_REPO="tracelabs/tlosint-vm"     # <-- set to your real repo
DEFAULT_REF="dev"                       # <-- dev for VM builds, or main
INSTALL_DIR="/usr/local/share/trace-labs-vm-setup"
BIN_WRAPPER="/usr/local/bin/tracelabs-setup"
MAIN_SCRIPT="tracelabs-vm-installer.sh"
ASSET_SCRIPT="asset-setup.sh"
DESKTOP_ENTRY_NAME="trace-labs-installer.desktop"

# Autostart target:
# - If run under sudo, uses SUDO_USER
# - else fallback to "osint" if it exists, else first non-root user
FALLBACK_USER="osint"

########################################
# Helpers
########################################
log()  { echo -e "[+] $*"; }
warn() { echo -e "[!] $*" >&2; }
die()  { echo -e "[x] $*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

need_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    die "Run as root (use: sudo $0 ...)"
  fi
}

usage() {
  cat <<EOF
Usage:
  sudo $0 [options]

Options:
  --release-url <url>     Install from a .tar.gz release artifact URL
  --repo <org/repo>       GitHub repo (default: ${DEFAULT_REPO})
  --ref <ref>             Branch/tag/commit (default: ${DEFAULT_REF})
  --user <username>       User to set autostart for (default: SUDO_USER/osint/first non-root)
  --no-reboot             Do everything but skip reboot
  -h, --help              Show help

Examples:
  sudo $0 --repo tracelabs/tlosint-vm --ref dev
  sudo $0 --release-url https://github.com/<org>/<repo>/releases/download/v1.2.3/trace-labs-vm-setup.tar.gz

EOF
}

########################################
# Args
########################################
RELEASE_URL=""
REPO="${DEFAULT_REPO}"
REF="${DEFAULT_REF}"
TARGET_USER=""
NO_REBOOT="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --release-url) RELEASE_URL="${2:-}"; shift 2;;
    --repo)        REPO="${2:-}"; shift 2;;
    --ref)         REF="${2:-}"; shift 2;;
    --user)        TARGET_USER="${2:-}"; shift 2;;
    --no-reboot)   NO_REBOOT="1"; shift;;
    -h|--help)     usage; exit 0;;
    *) die "Unknown arg: $1 (use --help)";;
  esac
done

########################################
# User detection for autostart
########################################
pick_target_user() {
  if [[ -n "${TARGET_USER}" ]]; then
    echo "${TARGET_USER}"
    return 0
  fi

  if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
    echo "${SUDO_USER}"
    return 0
  fi

  if getent passwd "${FALLBACK_USER}" >/dev/null 2>&1; then
    echo "${FALLBACK_USER}"
    return 0
  fi

  # pick first non-root user with a home directory under /home
  local u
  u="$(awk -F: '$3>=1000 && $1!="nobody" {print $1; exit}' /etc/passwd || true)"
  if [[ -n "$u" ]]; then
    echo "$u"
    return 0
  fi

  echo ""
}

########################################
# Download helpers
########################################
download_to() {
  local url="$1"
  local out="$2"
  if have curl; then
    curl -fsSL "$url" -o "$out"
  elif have wget; then
    wget -qO "$out" "$url"
  else
    die "Need curl or wget installed"
  fi
}

download_zip_from_github() {
  local repo="$1"
  local ref="$2"
  local out="$3"
  local url="https://github.com/${repo}/archive/${ref}.zip"
  log "Downloading GitHub ZIP: $url"
  download_to "$url" "$out"
}

extract_zip() {
  local zip="$1"
  local dest="$2"
  have unzip || die "Need unzip (apt-get update && apt-get install -y unzip)"
  unzip -q "$zip" -d "$dest"
}

extract_targz() {
  local tgz="$1"
  local dest="$2"
  mkdir -p "$dest"
  tar -xzf "$tgz" -C "$dest"
}

########################################
# Install payload to /usr/local/share
########################################
install_payload() {
  need_root

  local tmpdir
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT

  mkdir -p "$tmpdir/src"

  if [[ -n "$RELEASE_URL" ]]; then
    local tgz="$tmpdir/release.tar.gz"
    log "Downloading release artifact..."
    download_to "$RELEASE_URL" "$tgz"
    log "Extracting release artifact..."
    extract_targz "$tgz" "$tmpdir/src"
  else
    local zip="$tmpdir/repo.zip"
    download_zip_from_github "$REPO" "$REF" "$zip"
    log "Extracting repo zip..."
    extract_zip "$zip" "$tmpdir/src"
  fi

  # Find directory containing MAIN_SCRIPT
  local script_path
  script_path="$(find "$tmpdir/src" -type f -name "$MAIN_SCRIPT" | head -n 1 || true)"
  [[ -n "$script_path" ]] || die "Could not find $MAIN_SCRIPT in downloaded content."

  local found_dir
  found_dir="$(dirname "$script_path")"

  log "Found payload dir: $found_dir"
  log "Installing into: $INSTALL_DIR"

  rm -rf "$INSTALL_DIR"
  mkdir -p "$INSTALL_DIR"
  cp -a "$found_dir/." "$INSTALL_DIR/"

  # Ownership + permissions
  chown -R root:root "$INSTALL_DIR"
  chmod -R a+rX "$INSTALL_DIR"

  # Ensure executables
  chmod +x "$INSTALL_DIR/$MAIN_SCRIPT" 2>/dev/null || true
  find "$INSTALL_DIR" -maxdepth 2 -type f \( -name "*.sh" -o -name "*.zsh" \) -exec chmod +x {} \; 2>/dev/null || true

  # Create wrapper command (nice for CLI + autostart)
  log "Creating wrapper: $BIN_WRAPPER"
  cat > "$BIN_WRAPPER" <<EOF
#!/usr/bin/env bash
set -euo pipefail
cd "${INSTALL_DIR}"
exec sudo "${INSTALL_DIR}/${MAIN_SCRIPT}"
EOF
  chmod +x "$BIN_WRAPPER"

  # Sanity check
  [[ -f "$INSTALL_DIR/$MAIN_SCRIPT" ]] || die "Install failed: missing $INSTALL_DIR/$MAIN_SCRIPT"
  [[ -f "$INSTALL_DIR/$ASSET_SCRIPT" ]] || warn "Asset script not found at $INSTALL_DIR/$ASSET_SCRIPT (branding step may not run)."
}

########################################
# Desktop launcher install
########################################
install_desktop_entry_systemwide() {
  local src="$INSTALL_DIR/$DESKTOP_ENTRY_NAME"
  if [[ ! -f "$src" ]]; then
    warn "Desktop entry not found: $src (skipping Applications launcher install)"
    return 0
  fi

  log "Installing Applications launcher: /usr/share/applications/$DESKTOP_ENTRY_NAME"
  cp -f "$src" "/usr/share/applications/$DESKTOP_ENTRY_NAME"
  chmod 644 "/usr/share/applications/$DESKTOP_ENTRY_NAME"
}

install_desktop_shortcut_for_user() {
  local user="$1"
  local src="$INSTALL_DIR/$DESKTOP_ENTRY_NAME"
  [[ -n "$user" ]] || return 0
  [[ -f "$src" ]] || return 0

  local home
  home="$(getent passwd "$user" | cut -d: -f6 || true)"
  [[ -n "$home" && -d "$home" ]] || { warn "Could not resolve home for user '$user'"; return 0; }

  if [[ -d "$home/Desktop" ]]; then
    log "Placing Desktop shortcut for $user: $home/Desktop/$DESKTOP_ENTRY_NAME"
    cp -f "$src" "$home/Desktop/$DESKTOP_ENTRY_NAME"
    chown "$user:$user" "$home/Desktop/$DESKTOP_ENTRY_NAME"
    chmod 755 "$home/Desktop/$DESKTOP_ENTRY_NAME" 2>/dev/null || true
  else
    warn "No Desktop folder for $user (skipping Desktop shortcut)"
  fi
}

########################################
# Run branding/assets now
########################################
run_assets_now() {
  if [[ -f "$INSTALL_DIR/$ASSET_SCRIPT" ]]; then
    log "Running assets/branding script now: $ASSET_SCRIPT"
    ( cd "$INSTALL_DIR" && bash "./$ASSET_SCRIPT" )
  else
    warn "Skipping assets: $INSTALL_DIR/$ASSET_SCRIPT not found"
  fi
}

########################################
# Autostart setup (menu on first login)
########################################
setup_autostart_for_user() {
  local user="$1"
  [[ -n "$user" ]] || { warn "No target user found; skipping autostart"; return 0; }

  local home
  home="$(getent passwd "$user" | cut -d: -f6 || true)"
  [[ -n "$home" && -d "$home" ]] || { warn "Could not resolve home for user '$user'; skipping autostart"; return 0; }

  local autostart_dir="$home/.config/autostart"
  mkdir -p "$autostart_dir"
  chown -R "$user:$user" "$home/.config"

  # Create a dedicated autostart entry so it works even if the .desktop doesn't support autostart well.
  local autostart_file="$autostart_dir/tracelabs-installer-autostart.desktop"

  log "Setting autostart for $user: $autostart_file"
  cat > "$autostart_file" <<EOF
[Desktop Entry]
Type=Application
Name=Trace Labs VM Installer (Autostart)
Comment=Launch Trace Labs setup menu on login
Exec=${BIN_WRAPPER}
Terminal=true
X-GNOME-Autostart-enabled=true
NoDisplay=true
EOF

  chown "$user:$user" "$autostart_file"
  chmod 644 "$autostart_file"
}

########################################
# Reboot
########################################
reboot_now() {
  log "=================================================="
  log "COMPLETE ✅ Trace Labs setup has been installed."
  log "Next boot:"
  log "- Your wallpaper/login branding should be applied (assets)"
  log "- The installer menu should auto-launch on login"
  log "- Users can also run: tracelabs-setup"
  log "=================================================="

  if [[ "$NO_REBOOT" == "1" ]]; then
    warn "Skipping reboot (--no-reboot). Please reboot manually."
    return 0
  fi

  log "Rebooting in 5 seconds..."
  sleep 5
  reboot
}

########################################
# MAIN
########################################
need_root

TARGET_USER="$(pick_target_user)"
if [[ -z "$TARGET_USER" ]]; then
  warn "Could not auto-detect a non-root user. Autostart/Desktop shortcut may be skipped."
else
  log "Target user for autostart/Desktop shortcut: $TARGET_USER"
fi

install_payload
install_desktop_entry_systemwide
install_desktop_shortcut_for_user "$TARGET_USER"
run_assets_now
setup_autostart_for_user "$TARGET_USER"
reboot_now
