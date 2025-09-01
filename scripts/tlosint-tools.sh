#!/bin/zsh
# Ultimate OSINT Setup for Kali + Updater + Validator (translate-shell + robust Shodan/cargo)
set -uo pipefail
export DEBIAN_FRONTEND=noninteractive

LOG_FILE="${HOME}/osint-bootstrap.log"
touch "$LOG_FILE" || { echo "Cannot write ${LOG_FILE}"; exit 1; }

# Resolve target user (for per-user installs & desktop files)
if [[ $EUID -eq 0 && -n "${SUDO_USER-}" && "${SUDO_USER}" != "root" ]]; then
  TARGET_USER="${SUDO_USER}"
  TARGET_HOME="$(getent passwd "${TARGET_USER}" | cut -d: -f6)"
else
  TARGET_USER="$(id -un)"
  TARGET_HOME="${HOME}"
fi
[[ -z "${TARGET_HOME}" ]] && TARGET_HOME="${HOME}"

if [[ $EUID -eq 0 ]]; then SUDO=""; else SUDO="sudo"; fi

log()   { print -r -- "$(date +'%F %T') [INFO] $*" | tee -a "$LOG_FILE" >&2; }
logerr(){ print -r -- "$(date +'%F %T') [ERR ]  $*" | tee -a "$LOG_FILE" >&2; }
run()   { print -r -- "$(date +'%F %T') [EXEC] $*" | tee -a "$LOG_FILE" >&2; eval "$@" 2>>"$LOG_FILE"; }

# ---------- wrappers/symlinks ----------
write_wrapper() {
  local DEST="$1" REAL="$2"
  [[ -x "$REAL" ]] || return 0
  ${SUDO} mkdir -p "$(dirname "$DEST")"
  ${SUDO} tee "$DEST" >/dev/null <<'EOS'
#!/usr/bin/env bash
REAL="__REAL__"
exec "$REAL" "$@"
EOS
  ${SUDO} sed -i "s#__REAL__#${REAL}#g" "$DEST"
  ${SUDO} chmod 0755 "$DEST"
}

symlink_if_exists() {
  local SRC="$1" DEST_NAME="$2"
  [[ -x "$SRC" ]] || return 0
  ${SUDO} ln -sf "$SRC" "/usr/local/bin/${DEST_NAME}"
}

ensure_global_symlinks() {
  local CARGODIR="${TARGET_HOME}/.cargo/bin"
  for b in cargo rustc rustup sn0int; do
    command -v "$b" >/dev/null 2>&1 || symlink_if_exists "${CARGODIR}/${b}" "${b}"
  done
}

ensure_pipx_wrappers() {
  local bins=(shodan sherlock metagoofil sublist3r sf.py)
  for b in "${bins[@]}"; do
    [[ -x "${TARGET_HOME}/.local/bin/${b}" ]] && write_wrapper "/usr/local/bin/${b}" "${TARGET_HOME}/.local/bin/${b}"
  done
}

# ---------- Kali keyring ----------
ensure_kali_keyring() {
  local KR="/usr/share/keyrings/kali-archive-keyring.gpg"
  ${SUDO} mkdir -p /usr/share/keyrings 2>>"$LOG_FILE" || logerr "mkdir keyrings failed"
  log "[*] Forcing Kali archive keyring refresh…"
  if command -v wget >/dev/null 2>&1; then
    ${SUDO} wget -q "https://archive.kali.org/archive-keyring.gpg" -o /dev/null -O "$KR" || logerr "Kali keyring download failed (wget)"
  elif command -v curl >/dev/null 2>&1; then
    ${SUDO} curl -fsSL "https://archive.kali.org/archive-keyring.gpg" -o "$KR" || logerr "Kali keyring download failed (curl)"
  else
    logerr "Neither wget nor curl available to fetch Kali keyring"
  fi
  ${SUDO} chmod 0644 "$KR" 2>>"$LOG_FILE" || true
  ${SUDO} chown root:root "$KR" 2>>"$LOG_FILE" || true
  ${SUDO} mkdir -p /etc/apt/trusted.gpg.d 2>>"$LOG_FILE" || true
  ${SUDO} cp -f "$KR" /etc/apt/trusted.gpg.d/kali-archive-keyring.gpg 2>>"$LOG_FILE" || true
}

apt_self_heal() {
  log "[*] APT self-heal & upgrade"
  ensure_kali_keyring
  run "${SUDO} apt-get update -y"
  run "${SUDO} apt-get -y --allow-downgrades --allow-remove-essential --allow-change-held-packages dist-upgrade"
  run "${SUDO} apt-get -f install -y || true"
  run "${SUDO} dpkg --configure -a || true"
  run "${SUDO} apt-get -y autoremove --purge || true"
  run "${SUDO} apt-get -y clean || true"
}

install_base_packages() {
  log "[*] Base packages & build deps"
  ensure_kali_keyring
  run "${SUDO} apt-get update -y"
  local pkgs=(
    ca-certificates apt-transport-https software-properties-common gnupg
    curl wget git jq unzip zip xz-utils coreutils moreutils ripgrep fzf gawk
    build-essential pkg-config make gcc g++ libc6-dev
    python3 python3-venv python3-pip python3-setuptools python3-dev pipx
    golang-go
    libssl-dev
    openjdk-11-jdk maven
    exiftool tor torbrowser-launcher
    whiptail zenity
    chromium
    nodejs npm
    sq
  )
  run "${SUDO} apt-get install -y ${^pkgs}"
}

setup_python_envs() {
  log "[*] pip/pipx PATH for target user"
  run "${SUDO} -u \"$TARGET_USER\" bash -lc 'grep -qxF \"export PATH=\\\"\\\$HOME/.local/bin:\\\$PATH\\\"\" \"\\\$HOME/.zprofile\" 2>/dev/null || echo \"export PATH=\\\"\\\$HOME/.local/bin:\\\$PATH\\\"\" >> \"\\\$HOME/.zprofile\"'"
  run "${SUDO} -u \"$TARGET_USER\" bash -lc 'grep -qxF \"export PATH=\\\"\\\$HOME/.local/bin:\\\$PATH\\\"\" \"\\\$HOME/.profile\"  2>/dev/null || echo \"export PATH=\\\"\\\$HOME/.local/bin:\\\$PATH\\\"\" >> \"\\\$HOME/.profile\"'"
  run "${SUDO} -u \"$TARGET_USER\" python3 -m ensurepip --upgrade || true"
  run "${SUDO} -u \"$TARGET_USER\" python3 -m pip install --user -U pip wheel setuptools || true"
  run "${SUDO} -u \"$TARGET_USER\" pipx ensurepath || true"
}

setup_go_env() {
  log "[*] Configure Go env (target user)"
  run "${SUDO} -u \"$TARGET_USER\" bash -lc 'grep -qxF \"export GOPATH=\\\"\\\$HOME/go\\\"\"  \"\\\$HOME/.zprofile\" 2>/dev/null || echo \"export GOPATH=\\\"\\\$HOME/go\\\"\"  >> \"\\\$HOME/.zprofile\"'"
  run "${SUDO} -u \"$TARGET_USER\" bash -lc 'grep -qxF \"export GOBIN=\\\"\\\$GOPATH/bin\\\"\" \"\\\$HOME/.zprofile\" 2>/dev/null || echo \"export GOBIN=\\\"\\\$GOPATH/bin\\\"\" >> \"\\\$HOME/.zprofile\"'"
  run "${SUDO} -u \"$TARGET_USER\" bash -lc 'grep -qxF \"export PATH=\\\"\\\$GOBIN:\\\$PATH\\\"\"   \"\\\$HOME/.zprofile\" 2>/dev/null || echo \"export PATH=\\\"\\\$GOBIN:\\\$PATH\\\"\"   >> \"\\\$HOME/.zprofile\"'"
  run "${SUDO} -u \"$TARGET_USER\" mkdir -p \"$TARGET_HOME/go/bin\" \"$TARGET_HOME/go/src\" \"$TARGET_HOME/go/pkg\""
}

setup_rust_env() {
  log "[*] Install Rust (rustup) for target user (fallback path)"
  run "${SUDO} -u \"$TARGET_USER\" bash -lc 'command -v cargo >/dev/null 2>&1 || (curl --proto \"=https\" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal)'"
  run "${SUDO} -u \"$TARGET_USER\" bash -lc '[ -f \"\\\$HOME/.cargo/env\" ] && (grep -qxF \"source \\\"\\\$HOME/.cargo/env\\\"\" \"\\\$HOME/.zprofile\" || echo \"source \\\"\\\$HOME/.cargo/env\\\"\" >> \"\\\$HOME/.zprofile\")'"
}

# sn0int APT repository
setup_sn0int_repo() {
  log "[*] Setting up apt.vulns.sexy for sn0int"
  run "${SUDO} apt-get install -y curl sq"
  if [[ ! -f /etc/apt/trusted.gpg.d/apt-vulns-sexy.gpg ]]; then
    run "curl -sSf https://apt.vulns.sexy/kpcyrd.pgp | sq dearmor | ${SUDO} tee /etc/apt/trusted.gpg.d/apt-vulns-sexy.gpg > /dev/null"
  else
    log "[*] apt-vulns.sexy key already present"
  fi
  if [[ ! -f /etc/apt/sources.list.d/apt-vulns-sexy.list ]]; then
    run "echo deb http://apt.vulns.sexy stable main | ${SUDO} tee /etc/apt/sources.list.d/apt-vulns-sexy.list"
  else
    log "[*] apt-vulns.sexy.list already exists"
  fi
  run "${SUDO} apt-get update -y"
}

# ---------- helpers ----------
apt_try_install() {
  local pkg="$1"
  if dpkg -s "$pkg" >/dev/null 2>&1; then return 0; fi
  ensure_kali_keyring
  run "${SUDO} apt-get update -y"
  run "${SUDO} apt-get install -y $pkg" || return 1
}

pipx_user_install_or_upgrade() {
  local app="$1" spec="$2"
  run "${SUDO} -u \"$TARGET_USER\" bash -lc 'if pipx list 2>/dev/null | grep -qi \"^${app}\\b\"; then pipx upgrade ${app} || true; else pipx install \"${spec}\"; fi'"
}

go_install_if_missing() {
  local module="$1" ; local bin="${2:-}" ; local name="$bin"
  if [[ -z "$name" ]]; then name="${module##*/}"; name="${name%@*}"; fi
  if ! command -v "$name" >/dev/null 2>&1; then run "env GOBIN=/usr/local/bin go install \"$module\""; fi
}

cargo_install_if_missing() {
  local crate="$1"
  if ! command -v "$crate" >/dev/null 2>&1; then run "${SUDO} -u \"$TARGET_USER\" bash -lc 'cargo install --locked ${crate}'"; fi
}

# PhoneInfoga upstream fallback
phoneinfoga_upstream_fallback() {
  if command -v phoneinfoga >/dev/null 2>&1; then return 0; fi
  log "[*] PhoneInfoga not found after Go install — using upstream fallback"
  local tmp; tmp="$(mktemp -d)"
  (
    cd "$tmp"
    bash <( curl -sSL https://raw.githubusercontent.com/sundowndev/phoneinfoga/master/support/scripts/install )
    if [[ -f "./phoneinfoga" ]]; then
      ${SUDO} install -m 0755 ./phoneinfoga /usr/local/bin/phoneinfoga
    fi
  )
  rm -rf "$tmp" || true
}

# StegOSuite fallback build
build_stegosuite_from_source() {
  local repo="https://github.com/osde8info/stegosuite.git"
  local app="stegosuite"
  local optdir="/opt/${app}"
  local desktop="${HOME}/.local/share/applications/${app}.desktop"
  local tmpdir; tmpdir="$(mktemp -d)"
  log "[*] Building StegOSuite from source (Maven + JDK 11)…"
  run "${SUDO} mkdir -p \"$optdir\""
  (
    cd "$tmpdir"
    run "git clone --depth=1 \"$repo\" src"
    cd src
    if ! mvn -q -DskipTests package; then
      logerr "[stegosuite] Maven build failed — check ${LOG_FILE}"
    fi
    local jar; jar="$(ls -1 target/*stegosuite*.jar 2>/dev/null | head -n1 || true)"
    if [[ -n "$jar" ]]; then
      run "${SUDO} install -m 0644 \"$jar\" \"$optdir/${app}.jar\""
      log "[*] Installed: $optdir/${app}.jar"
    else
      logerr "[stegosuite] Build finished but no JAR found in target/"
    fi
  )
  rm -rf "$tmpdir" || true

  mkdir -p "$(dirname "$desktop")"
  cat > "$desktop" <<EOF
[Desktop Entry]
Type=Application
Name=${app:u}
Comment=Launch ${app}
Exec=sh -c 'java -jar "${optdir}/${app}.jar" || zenity --error --text="Missing ${app}.jar in ${optdir}"'
Icon=utilities-terminal
Terminal=false
Categories=Utility;Security;
StartupNotify=true
EOF
  chmod +x "$desktop"
  log "[*] Desktop entry created: $desktop"
}

# ---------- translate-shell (trans) ----------
install_translate_shell() {
  log "[*] Installing translate-shell (trans) from source…"
  local tmp; tmp="$(mktemp -d)"
  (
    cd "$tmp"
    run "git clone https://github.com/soimort/translate-shell"
    cd translate-shell
    run "make"
    run "${SUDO} make install"
  )
  rm -rf "$tmp" || true
  if command -v trans >/dev/null 2>&1; then
    log "[*] translate-shell installed: $(command -v trans)"
  else
    logerr "translate-shell build/install did not place 'trans' on PATH"
  fi
}

# ---------- install tools ----------
install_tools_from_list() {
  log "[*] Installing OSINT tools"

  # Shodan (pipx user) + ensure pkg_resources + wrapper
  pipx_user_install_or_upgrade "shodan" "shodan"
  run "${SUDO} -u \"$TARGET_USER\" bash -lc 'pipx runpip shodan install -U \"setuptools>=68\" \"pip>=23\" wheel || true'"
  write_wrapper "/usr/local/bin/shodan" "${TARGET_HOME}/.local/bin/shodan"

  # Sherlock (pipx user)
  pipx_user_install_or_upgrade "sherlock" "git+https://github.com/sherlock-project/sherlock.git"

  # PhoneInfoga (Go → fallback)
  if command -v go >/dev/null 2>&1; then
    go_install_if_missing "github.com/sundowndev/phoneinfoga/v2/cmd/phoneinfoga@latest" "phoneinfoga"
  fi
  phoneinfoga_upstream_fallback

  # SpiderFoot (APT → pipx fallback)
  if ! apt_try_install spiderfoot; then
    pipx_user_install_or_upgrade "spiderfoot" "git+https://github.com/smicallef/spiderfoot.git"
    [[ -x "${TARGET_HOME}/.local/bin/sf.py" ]] && write_wrapper "/usr/local/bin/sf.py" "${TARGET_HOME}/.local/bin/sf.py"
  fi

  # sn0int (APT → cargo fallback)
  if ! apt_try_install sn0int; then
    cargo_install_if_missing "sn0int"
  fi

  # Metagoofil (APT → pipx)
  if ! apt_try_install metagoofil; then
    pipx_user_install_or_upgrade "metagoofil" "git+https://github.com/opsdisk/metagoofil.git"
  fi

  # Sublist3r (APT → pipx)
  if ! apt_try_install sublist3r; then
    pipx_user_install_or_upgrade "sublist3r" "git+https://github.com/aboul3la/Sublist3r.git"
  fi

  # StegOSuite (APT → source)
  if ! apt_try_install stegosuite; then
    build_stegosuite_from_source
  fi

  # ExifTool
  apt_try_install exiftool || apt_try_install libimage-exiftool-perl || true

  # translate-shell
  install_translate_shell

  # Ensure global cargo/sn0int visibility & pipx wrappers
  ensure_global_symlinks
  ensure_pipx_wrappers
}

# ---------- Trace Labs PDF ----------
fetch_tracelabs_pdf() {
  local url="https://download2.tracelabs.org/Trace-Labs-OSINT-Search-Party-CTF-Contestant-Guide_v1.pdf"
  local dest_dir="${TARGET_HOME}/Desktop"
  local dest="${dest_dir}/Trace-Labs-OSINT-Search-Party-CTF-Contestant-Guide_v1.pdf"
  log "[*] Downloading Trace Labs Contestant Guide to ${dest}"
  ${SUDO} mkdir -p "${dest_dir}" 2>>"$LOG_FILE" || true
  if command -v curl >/dev/null 2>&1; then
    ${SUDO} curl -fsSL "$url" -o "$dest" || logerr "curl failed to fetch Trace Labs PDF"
  elif command -v wget >/dev/null 2>&1; then
    ${SUDO} wget -q "$url" -O "$dest" || logerr "wget failed to fetch Trace Labs PDF"
  else
    logerr "Neither curl nor wget available to fetch Trace Labs PDF"
  fi
  ${SUDO} chmod 0644 "$dest" 2>>"$LOG_FILE" || true
  if [[ $EUID -eq 0 ]]; then
    ${SUDO} chown "${TARGET_USER}:${TARGET_USER}" "$dest" 2>>"$LOG_FILE" || true
  fi
}

# ---------- Updater ----------
install_osint_updater() {
  log "[*] Installing OSINT updater"
  local UPD="/usr/local/bin/osint-updater"
  ${SUDO} tee "$UPD" >/dev/null <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
LOG_FILE="/var/log/osint-updater.log"
touch "$LOG_FILE" 2>/dev/null || LOG_FILE="/tmp/osint-updater.log"
log()   { printf '%s [INFO] %s\n' "$(date +'%F %T')" "$*" | tee -a "$LOG_FILE" >&2; }
logerr(){ printf '%s [ERR ] %s\n'  "$(date +'%F %T')" "$*" | tee -a "$LOG_FILE" >&2; }
run()   { printf '%s [EXEC] %s\n'  "$(date +'%F %T')" "$*" | tee -a "$LOG_FILE" >&2; eval "$@" 2>>"$LOG_FILE"; }
export DEBIAN_FRONTEND=noninteractive
ensure_kali_keyring() {
  local KR="/usr/share/keyrings/kali-archive-keyring.gpg"
  mkdir -p /usr/share/keyrings 2>>"$LOG_FILE" || true
  log "[*] Forcing Kali archive keyring refresh…"
  if command -v wget >/dev/null 2>&1; then
    wget -q "https://archive.kali.org/archive-keyring.gpg" -O "$KR" || logerr "Kali keyring download failed (wget)"
  elif command -v curl >/dev/null 2>&1; then
    curl -fsSL "https://archive.kali.org/archive-keyring.gpg" -o "$KR" || logerr "Kali keyring download failed (curl)"
  else
    logerr "Neither wget nor curl available to fetch Kali keyring"
  fi
  chmod 0644 "$KR" 2>>"$LOG_FILE" || true
  chown root:root "$KR" 2>>"$LOG_FILE" || true
  mkdir -p /etc/apt/trusted.gpg.d 2>>"$LOG_FILE" || true
  cp -f "$KR" /etc/apt/trusted.gpg.d/kali-archive-keyring.gpg 2>>"$LOG_FILE" || true
}
apt_self_heal_update() {
  ensure_kali_keyring
  run "apt-get update -y"
  run "apt-get -y --allow-downgrades --allow-remove-essential --allow-change-held-packages dist-upgrade"
  run "apt-get -f install -y || true"
  run "dpkg --configure -a || true"
  run "apt-get -y autoremove --purge || true"
  run "apt-get -y clean || true"
}
upgrade_pipx_tools() {
  if command -v pipx >/dev/null 2>&1; then
    log "[*] Upgrading pipx apps"
    run "pipx upgrade-all || true"
    # Ensure Shodan venv has setuptools for pkg_resources
    run "pipx runpip shodan install -U setuptools pip wheel || true"
  fi
}
upgrade_go_tools() {
  if command -v go >/dev/null 2>&1; then
    log "[*] Refreshing PhoneInfoga (Go)"
    run "env GOBIN=/usr/local/bin go install github.com/sundowndev/phoneinfoga/v2/cmd/phoneinfoga@latest"
    chmod 0755 /usr/local/bin/phoneinfoga 2>>"$LOG_FILE" || true
  fi
}
upgrade_rust_tools() {
  if command -v cargo >/dev/null 2>&1; then
    log "[*] Refreshing sn0int (Rust)"
    run "cargo install --locked sn0int"
  fi
}
main(){ log "==== OSINT Updater starting ===="; apt_self_heal_update; upgrade_pipx_tools; upgrade_go_tools; upgrade_rust_tools; log "==== OSINT Updater complete. See $LOG_FILE for details. ===="; }
main "$@"
EOF
  ${SUDO} chmod +x "$UPD"
  ${SUDO} chown root:root "$UPD"

  local DESK="${TARGET_HOME}/Desktop/OSINT-Updater.desktop"
  ${SUDO} mkdir -p "${TARGET_HOME}/Desktop"
  ${SUDO} tee "$DESK" >/dev/null <<'EOF'
[Desktop Entry]
Type=Application
Name=OSINT Updater
Comment=Update Kali & OSINT tools (Trace Labs "grandma mode")
Exec=pkexec /usr/local/bin/osint-updater
Icon=system-software-update
Terminal=true
Categories=System;Utility;Security;
StartupNotify=true
EOF
  ${SUDO} chmod +x "$DESK"
  if [[ $EUID -eq 0 ]]; then
    ${SUDO} chown "${TARGET_USER}:${TARGET_USER}" "$DESK"
  fi
}

post_install_checks() {
  log "[*] Post-install sanity checks"
  local missing=()
  for b in shodan sherlock phoneinfoga sn0int metagoofil sublist3r exiftool tor trans; do
    command -v "$b" >/dev/null 2>&1 || missing+=("$b")
  done
  command -v spiderfoot >/dev/null 2>&1 || command -v sf.py >/dev/null 2>&1 || missing+=("spiderfoot/sf.py")
  command -v stegosuite >/dev/null 2>&1 || [[ -f /opt/stegosuite/stegosuite.jar ]] || missing+=("stegosuite (APT) or /opt/stegosuite/stegosuite.jar")
  command -v torbrowser-launcher >/dev/null 2>&1 || missing+=("torbrowser-launcher")
  if (( ${#missing[@]} )); then
    logerr "Missing or not detected: ${missing[*]}"
    log "Review ${LOG_FILE} for errors."
  else
    log "[*] All requested tools detected."
  fi
}

usage_hints() {
  cat <<'EOF' | tee -a "$LOG_FILE" >/dev/null
----------------------------------------------------------------
Usage:
- Shodan:          shodan init <API_KEY>   (first time)
- Translate:       trans -b :de "Hello, how are you?"
                   trans :es "This is a test"
- StegOSuite:      stegosuite   (APT)   or   java -jar /opt/stegosuite/stegosuite.jar
- SpiderFoot UI:   spiderfoot -l 127.0.0.1:5001  (then open http://127.0.0.1:5001)
- Updater (GUI):   Double-click "OSINT Updater" on Desktop (runs via pkexec)
- Updater (CLI):   pkexec /usr/local/bin/osint-updater
- PATH refresh:    source ~/.profile && source ~/.zprofile  (or open a new terminal)

Workspaces:
- Outputs saved in  ~/osint-workspaces/<target>/<timestamp>/

Docs:
- Trace Labs Contestant Guide on Desktop:
  Trace-Labs-OSINT-Search-Party-CTF-Contestant-Guide_v1.pdf

Logs:
- Setup log:       ~/osint-bootstrap.log
- Updater log:     /var/log/osint-updater.log (or /tmp fallback)
----------------------------------------------------------------
EOF
}

# ===================== BUILT-IN VALIDATOR =====================
validator() {
  local PASSES=0 FAILS=0 WARNINGS=0
  local BLUE='\033[1;34m' GREEN='\033[1;32m' YELLOW='\033[1;33m' RED='\033[1;31m' NC='\033[0m'
  local info ok warn fail
  info(){ printf "${BLUE}[INFO]${NC} %s\n" "$*"; }
  ok(){   printf "${GREEN}[PASS]${NC} %s\n" "$*"; PASSES=$((PASSES+1)); }
  warn(){ printf "${YELLOW}[WARN]${NC} %s\n" "$*"; WARNINGS=$((WARNINGS+1)); }
  fail(){ printf "${RED}[FAIL]${NC} %s\n" "$*"; FAILS=$((FAILS+1)); }

  local REAL_USER REAL_HOME
  if [[ $EUID -eq 0 && -n "${SUDO_USER-}" && "${SUDO_USER}" != "root" ]]; then
    REAL_USER="${SUDO_USER}"
    REAL_HOME="$(getent passwd "${REAL_USER}" | cut -d: -f6)"
  else
    REAL_USER="$(id -un)"
    REAL_HOME="${HOME}"
  fi
  [[ -z "${REAL_HOME}" ]] && REAL_HOME="${HOME}"

  has(){ command -v "$1" >/dev/null 2>&1; }

  show_ver(){
    local bin="$1"; shift || true
    if has "$bin"; then
      if "$bin" "$@" >/dev/null 2>&1; then
        local out; out="$("$bin" "$@" 2>/dev/null | head -n1)"
        ok "$bin $* -> ${out:-OK}"
      else
        for flag in "--version" "-V" "-v" "version" "--help" "-h"; do
          if "$bin" "$flag" >/dev/null 2>&1; then
            local v; v="$("$bin" "$flag" 2>/dev/null | head -n1)"
            ok "$bin $flag -> ${v:-OK}"
            return 0
          fi
        done
        if "$bin" >/dev/null 2>&1; then
          ok "$bin -> OK"
        else
          warn "$bin is present, but no version/help worked."
        fi
      fi
    else
      fail "$bin not found on PATH"
    fi
  }

  check_path_contains(){
    local needle="$1"
    if [[ ":$PATH:" == *":${needle}:"* ]]; then
      ok "PATH contains ${needle}"
    else
      if command -v sudo >/dev/null 2>&1 && [[ -n "${REAL_USER}" ]]; then
        if sudo -u "$REAL_USER" bash -lc "grep -q 'export PATH=\"\\\$HOME/.local/bin:\\\$PATH\"' ~/.zprofile ~/.profile 2>/dev/null"; then
          ok "PATH will include ${needle} for ${REAL_USER} on next login"
          return
        fi
      fi
      warn "PATH missing ${needle}"
    fi
  }

  check_file(){ local f="$1" ; local desc="$2"; [[ -e "$f" ]] && ok "$desc exists: $f" || fail "$desc missing: $f"; }
  check_exec(){ local f="$1" ; local desc="$2"; [[ -x "$f" ]] && ok "$desc is executable: $f" || fail "$desc not executable: $f"; }

  info "Validator starting for user: ${REAL_USER} (home: ${REAL_HOME})"
  info "PATH: $PATH"

  show_ver python3 --version
  show_ver pipx --version || true
  show_ver go version || true
  show_ver cargo --version || true
  show_ver node --version || true
  show_ver npm --version || true
  show_ver java -version || true
  show_ver mvn -v || true

  check_path_contains "${REAL_HOME}/.local/bin"
  [[ -n "${GOBIN-}" ]] && check_path_contains "${GOBIN}"

  # Shodan (robust)
  if has shodan; then
    if shodan --help >/dev/null 2>&1 || shodan version >/dev/null 2>&1 || shodan -h >/dev/null 2>&1 || shodan >/dev/null 2>&1; then
      ok "shodan CLI OK"
    else
      fail "shodan present but unresponsive to version/help"
    fi
    if shodan info >/dev/null 2>&1; then ok "Shodan is initialized"; else warn "Shodan not initialized (run: shodan init <API_KEY>)"; fi
  else
    fail "shodan not found on PATH"
  fi

  if has phoneinfoga; then show_ver phoneinfoga version || ok "phoneinfoga present"; else fail "phoneinfoga not found"; fi
  if has spiderfoot; then ok "spiderfoot present: $(command -v spiderfoot)"
  elif has sf.py; then ok "SpiderFoot present as sf.py: $(command -v sf.py)"
  else fail "SpiderFoot not found (spiderfoot/sf.py)"; fi

  show_ver sn0int -V || true
  show_ver metagoofil -h || true
  show_ver sublist3r -h || true
  show_ver exiftool -ver || true
  show_ver tor --version || true
  show_ver torbrowser-launcher --help || true
  show_ver trans -V || true

  check_exec "/usr/local/bin/osint-updater" "osint-updater"
  check_file "${REAL_HOME}/Desktop/OSINT-Updater.desktop" "OSINT-Updater.desktop"
  check_file "${REAL_HOME}/Desktop/Trace-Labs-OSINT-Search-Party-CTF-Contestant-Guide_v1.pdf" "Trace Labs PDF"

  if command -v stegosuite >/dev/null 2>&1; then ok "StegOSuite available via APT"
  elif [[ -f /opt/stegosuite/stegosuite.jar ]]; then ok "StegOSuite jar present: /opt/stegosuite/stegosuite.jar"
  else warn "StegOSuite not detected (APT or /opt/stegosuite/stegosuite.jar)"; fi

  [[ -f /usr/share/keyrings/kali-archive-keyring.gpg ]] && ok "Kali archive keyring present" || warn "Kali archive keyring missing"
  [[ -f /etc/apt/trusted.gpg.d/apt-vulns-sexy.gpg ]] && ok "apt-vulns.sexy key installed" || warn "apt-vulns.sexy key not found"
  [[ -f /etc/apt/sources.list.d/apt-vulns-sexy.list ]] && ok "apt-vulns.sexy repo listed" || warn "apt-vulns.sexy repo list missing"

  local WS="${REAL_HOME}/osint-workspaces"
  if [[ -d "$WS" ]]; then
    ok "Workspace base exists: $WS"
  else
    if command -v sudo >/dev/null 2>&1; then
      sudo -u "$REAL_USER" mkdir -p "$WS" 2>/dev/null || true
    fi
    [[ -d "$WS" ]] && ok "Workspace base created: $WS" || warn "Workspace base missing (created on first run): $WS"
  fi

  echo
  if (( FAILS == 0 )); then
    printf "\033[1;32mAll good!\033[0m  Passes: %d  Warnings: %d  Fails: %d\n" "$PASSES" "$WARNINGS" "$FAILS"
    return 0
  else
    printf "\033[1;33mValidation finished with issues.\033[0m  Passes: %d  Warnings: %d  Fails: %d\n" "$PASSES" "$WARNINGS" "$FAILS"
    echo "Hints:"
    echo " - PATH: open a new terminal or 'source ~/.profile' and '~/.zprofile'"
    echo " - Shodan: 'shodan init <API_KEY>'"
    echo " - SpiderFoot may be 'spiderfoot' (APT) or 'sf.py' (pipx)"
    echo " - StegOSuite: install via APT or ensure /opt/stegosuite/stegosuite.jar exists"
    return 1
  fi
}

# ===================== MAIN =====================
main() {
  local MODE="${1:-}"  # --no-validate | --validate-only | (default: install+validate)

  if [[ "$MODE" == "--validate-only" ]]; then
    validator
    exit $?
  fi

  log "==== Ultimate OSINT Setup starting ===="
  apt_self_heal
  install_base_packages
  setup_python_envs
  setup_go_env
  setup_rust_env
  setup_sn0int_repo
  install_tools_from_list
  fetch_tracelabs_pdf
  install_osint_updater
  run "${SUDO} -u \"$TARGET_USER\" mkdir -p \"$TARGET_HOME/osint-workspaces\""
  post_install_checks
  usage_hints
  log "==== Completed. See ${LOG_FILE} for details. ===="

  if [[ "$MODE" != "--no-validate" ]]; then
    echo
    log "[*] Running built-in validator…"
    validator || true
  fi
}
main "${1:-}"
