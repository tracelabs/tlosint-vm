#!/bin/bash
# OSINT Setup for Debian Trixie on ARM64 (aarch64)
# usage: sudo ./tlosint-tools-debian-arm64.sh [--validate-only | --no-validate]
set -uo pipefail
export DEBIAN_FRONTEND=noninteractive

ARCH=$(dpkg --print-architecture)   # arm64 on Apple Silicon

LOG_FILE="${HOME}/osint-bootstrap.log"
touch "$LOG_FILE" || { echo "Cannot write ${LOG_FILE}"; exit 1; }

# target user
if [[ $EUID -eq 0 && -n "${SUDO_USER-}" && "${SUDO_USER}" != "root" ]]; then
  TARGET_USER="${SUDO_USER}"
  TARGET_HOME="$(getent passwd "${TARGET_USER}" | cut -d: -f6)"
else
  TARGET_USER="$(id -un)"
  TARGET_HOME="${HOME}"
fi
[[ -z "${TARGET_HOME}" ]] && TARGET_HOME="${HOME}"
if [[ $EUID -eq 0 ]]; then SUDO=""; else SUDO="sudo"; fi

log()   { printf '%s\n' "$(date +'%F %T') [INFO] $*" | tee -a "$LOG_FILE" >&2; }
logerr(){ printf '%s\n' "$(date +'%F %T') [ERR ]  $*" | tee -a "$LOG_FILE" >&2; }
# shellcheck disable=SC2294
run()   { printf '%s\n' "$(date +'%F %T') [EXEC] $*" | tee -a "$LOG_FILE" >&2; eval "$@" 2>>"$LOG_FILE"; }

# wrapper
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
  local bins=(shodan sherlock maigret metagoofil sublist3r sf.py)
  for b in "${bins[@]}"; do
    [[ -x "${TARGET_HOME}/.local/bin/${b}" ]] && write_wrapper "/usr/local/bin/${b}" "${TARGET_HOME}/.local/bin/${b}"
  done
}

# APT helpers
enable_contrib_nonfree() {
  log "[*] Enabling contrib and non-free repos (required for some OSINT packages)"
  local DEB822="/etc/apt/sources.list.d/debian.sources"
  if [[ -f "$DEB822" ]]; then
    if grep -q "contrib" "$DEB822" 2>/dev/null; then
      log "[*] contrib/non-free already enabled in ${DEB822}"
      return 0
    fi
    ${SUDO} sed -i 's/^Components: main$/Components: main contrib non-free non-free-firmware/' "$DEB822"
    run "${SUDO} apt-get update -y"
    log "[*] contrib/non-free enabled in ${DEB822}"
    return 0
  fi
  # legacy sources.list path
  local SOURCES="/etc/apt/sources.list"
  if grep -q "contrib" "$SOURCES" 2>/dev/null; then
    log "[*] contrib/non-free already enabled"
    return 0
  fi
  local CODENAME=""
  [[ -r /etc/os-release ]] && CODENAME="$(. /etc/os-release 2>/dev/null; echo "${VERSION_CODENAME:-}")"
  [[ -z "${CODENAME}" ]] && CODENAME="trixie"
  ${SUDO} tee "$SOURCES" >/dev/null <<EOF
deb http://deb.debian.org/debian ${CODENAME} main contrib non-free non-free-firmware
deb http://deb.debian.org/debian ${CODENAME}-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security ${CODENAME}-security main contrib non-free non-free-firmware
EOF
  run "${SUDO} apt-get update -y"
  log "[*] contrib/non-free repos enabled"
}

apt_self_heal() {
  log "[*] APT self-heal & upgrade"
  run "${SUDO} apt-get update -y"
  run "${SUDO} apt-get -y --allow-downgrades --allow-remove-essential --allow-change-held-packages dist-upgrade"
  run "${SUDO} apt-get -f install -y || true"
  run "${SUDO} dpkg --configure -a || true"
  run "${SUDO} apt-get -y autoremove --purge || true"
  run "${SUDO} apt-get -y clean || true"
}

apt_update_once() {
  run "${SUDO} apt-get update -y || ${SUDO} apt-get update"
}

apt_install_one() {
  local pkg="$1"
  run "${SUDO} apt-get install -y ${pkg}" && return 0
  run "${SUDO} apt-get -f install -y || true"
  run "${SUDO} dpkg --configure -a || true"
  run "${SUDO} apt-get install -y ${pkg}"
}

apt_install_with_alternates() {
  local candidate
  for candidate in "$@"; do
    if ${SUDO} apt-get -s install "$candidate" >/dev/null 2>&1; then
      apt_install_one "$candidate" && return 0
    fi
  done
  return 1
}

apt_try_install() {
  local pkg="$1"
  if dpkg -s "$pkg" >/dev/null 2>&1; then return 0; fi
  run "${SUDO} apt-get update -y"
  run "${SUDO} apt-get install -y $pkg" || return 1
}

# base packages + build deps
install_base_packages() {
  log "[*] Base packages & build deps"
  enable_contrib_nonfree
  apt_update_once
  local pkgs=(
    ca-certificates apt-transport-https gnupg
    curl wget git jq unzip zip xz-utils coreutils moreutils ripgrep fzf gawk
    build-essential pkg-config make gcc g++ libc6-dev
    libsqlite3-dev libsodium-dev libseccomp-dev libssl-dev
    python3 python3-venv python3-pip python3-setuptools python3-dev pipx
    golang-go
    default-jdk maven
    libimage-exiftool-perl exifprobe tor
    whiptail zenity chromium nodejs npm firefox-esr
    steghide stegseek stegosuite
    translate-shell
    httrack yt-dlp instaloader
  )
  local p
  for p in "${pkgs[@]}"; do
    apt_install_one "$p" || logerr "Failed to install ${p} (continuing)"
  done
  apt_install_with_alternates pipx python3-pipx || log "[*] pipx not available via apt; will bootstrap later."
}

# sn0int repo (for latest sn0int + sn0int-git)
setup_sn0int_repo() {
  log "[*] Setting up apt.vulns.xyz for sn0int"
  run "${SUDO} apt-get install -y curl"
  if [[ ! -f /etc/apt/trusted.gpg.d/apt-vulns-xyz.gpg ]]; then
    run "curl -sSf https://apt.vulns.xyz/kpcyrd.pgp | gpg --dearmor | ${SUDO} tee /etc/apt/trusted.gpg.d/apt-vulns-xyz.gpg > /dev/null"
  else
    log "[*] apt.vulns.xyz key already present"
  fi
  if [[ ! -f /etc/apt/sources.list.d/apt-vulns-xyz.list ]]; then
    run "echo deb http://apt.vulns.xyz stable main | ${SUDO} tee /etc/apt/sources.list.d/apt-vulns-xyz.list"
  else
    log "[*] apt.vulns.xyz.list already exists"
  fi
  run "${SUDO} apt-get update -y"
}

# python / pipx env setup / go env / rustup
setup_python_envs() {
  log "[*] pip/pipx PATH for target user"
  run "sudo -u \"$TARGET_USER\" bash -lc 'for f in \"\$HOME/.profile\" \"\$HOME/.bashrc\"; do grep -qxF \"export PATH=\\\"\\\$HOME/.local/bin:\\\$PATH\\\"\" \"\$f\" 2>/dev/null || echo \"export PATH=\\\"\\\$HOME/.local/bin:\\\$PATH\\\"\" >> \"\$f\"; done'"
  run "sudo -u \"$TARGET_USER\" python3 -m ensurepip --upgrade || true"
  run "sudo -u \"$TARGET_USER\" python3 -m pip install --user -U pip wheel setuptools || true"
  run "sudo -u \"$TARGET_USER\" pipx ensurepath || true"
}

setup_go_env() {
  log "[*] Configure Go env (target user)"
  run "sudo -u \"$TARGET_USER\" bash -lc 'grep -qxF \"export GOPATH=\\\"\\\$HOME/go\\\"\" \"\$HOME/.profile\" 2>/dev/null || echo \"export GOPATH=\\\"\\\$HOME/go\\\"\" >> \"\$HOME/.profile\"'"
  run "sudo -u \"$TARGET_USER\" bash -lc 'grep -qxF \"export GOBIN=\\\"\\\$GOPATH/bin\\\"\" \"\$HOME/.profile\" 2>/dev/null || echo \"export GOBIN=\\\"\\\$GOPATH/bin\\\"\" >> \"\$HOME/.profile\"'"
  run "sudo -u \"$TARGET_USER\" bash -lc 'grep -qxF \"export PATH=\\\"\\\$GOBIN:\\\$PATH\\\"\" \"\$HOME/.profile\" 2>/dev/null || echo \"export PATH=\\\"\\\$GOBIN:\\\$PATH\\\"\" >> \"\$HOME/.profile\"'"
  run "sudo -u \"$TARGET_USER\" mkdir -p \"$TARGET_HOME/go/bin\" \"$TARGET_HOME/go/src\" \"$TARGET_HOME/go/pkg\""
}

setup_rust_env() {
  log "[*] Install Rust (rustup) for target user"
  run "sudo -u \"$TARGET_USER\" bash -lc 'command -v cargo >/dev/null 2>&1 || (curl --proto \"=https\" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal)'"
  run "sudo -u \"$TARGET_USER\" bash -lc '[ -f \"\$HOME/.cargo/env\" ] && (grep -qxF \"source \\\"\\\$HOME/.cargo/env\\\"\" \"\$HOME/.profile\" || echo \"source \\\"\\\$HOME/.cargo/env\\\"\" >> \"\$HOME/.profile\")'"
}

# tool install helpers
pipx_user_install_or_upgrade() {
  local app="$1" spec="$2"
  run "sudo -u \"$TARGET_USER\" bash -lc 'if pipx list 2>/dev/null | grep -qi \"^${app}\\b\"; then pipx upgrade ${app} || true; else pipx install \"${spec}\"; fi'"
}

go_install_if_missing() {
  local module="$1"; local bin="${2:-}"; local name="$bin"
  if [[ -z "$name" ]]; then name="${module##*/}"; name="${name%@*}"; fi
  if ! command -v "$name" >/dev/null 2>&1; then
    run "env GOBIN=/usr/local/bin go install \"$module\""
  fi
}

cargo_install_if_missing() {
  local crate="$1"
  if ! command -v "$crate" >/dev/null 2>&1; then
    run "sudo -u \"$TARGET_USER\" bash -lc 'cargo install --locked ${crate}'"
  fi
}

# phoneinfoga go install fallback 
phoneinfoga_upstream_fallback() {
  if command -v phoneinfoga >/dev/null 2>&1; then return 0; fi
  log "[*] PhoneInfoga not found after Go install — using upstream fallback"
  local tmp; tmp="$(mktemp -d)"
  (
    cd "$tmp" || exit
    bash <( curl -sSL https://raw.githubusercontent.com/sundowndev/phoneinfoga/master/support/scripts/install )
    if [[ -f "./phoneinfoga" ]]; then
      ${SUDO} install -m 0755 ./phoneinfoga /usr/local/bin/phoneinfoga
    fi
  )
  rm -rf "$tmp" || true
}

# spiderfoot git clone + venv
install_spiderfoot_from_source() {
  local dest="/opt/spiderfoot"
  local venv="${dest}/venv"
  log "[*] Installing SpiderFoot from source into ${dest}"
  run "${SUDO} rm -rf \"${dest}\""
  run "${SUDO} git clone --depth=1 https://github.com/smicallef/spiderfoot.git \"${dest}\""
  run "${SUDO} python3 -m venv \"${venv}\""
  run "${SUDO} \"${venv}/bin/pip\" -q install --upgrade pip wheel 'setuptools<72'"
  if [[ -f "${dest}/requirements.txt" ]]; then
    run "${SUDO} sed -i 's/^lxml.*/lxml>=5.0.0/' \"${dest}/requirements.txt\" || true"
    run "${SUDO} \"${venv}/bin/pip\" -q install -r \"${dest}/requirements.txt\""
  fi

  ${SUDO} tee /usr/local/bin/spiderfoot >/dev/null <<EOF
#!/usr/bin/env bash
cd "${dest}" && exec "${venv}/bin/python3" "${dest}/sf.py" "\$@"
EOF
  ${SUDO} chmod 0755 /usr/local/bin/spiderfoot

  ${SUDO} tee /usr/local/bin/sf.py >/dev/null <<EOF
#!/usr/bin/env bash
cd "${dest}" && exec "${venv}/bin/python3" "${dest}/sf.py" "\$@"
EOF
  ${SUDO} chmod 0755 /usr/local/bin/sf.py
  log "[*] SpiderFoot installed (wrappers: /usr/local/bin/spiderfoot, /usr/local/bin/sf.py)"
}

# tor browser launcher 
install_tor_browser_launcher() {
  if command -v torbrowser-launcher >/dev/null 2>&1; then
    log "[*] torbrowser-launcher already present"
    return 0
  fi
  log "[*] torbrowser-launcher not in Trixie repos; installing via pipx"
  run "sudo -u \"$TARGET_USER\" bash -lc 'pipx install torbrowser-launcher || true'"
  if [[ -x "${TARGET_HOME}/.local/bin/torbrowser-launcher" ]]; then
    write_wrapper "/usr/local/bin/torbrowser-launcher" "${TARGET_HOME}/.local/bin/torbrowser-launcher"
    log "[*] torbrowser-launcher installed via pipx"
  else
    logerr "torbrowser-launcher install failed; download Tor Browser manually from https://www.torproject.org/download/"
  fi
}

# translate shell 
install_translate_shell() {
  if apt_try_install translate-shell && command -v trans >/dev/null 2>&1; then
    log "[*] translate-shell installed via APT: $(command -v trans)"
    return 0
  fi
  log "[*] Installing translate-shell from source…"
  local tmp; tmp="$(mktemp -d)"
  (
    cd "$tmp" || exit
    run "git clone https://github.com/soimort/translate-shell"
    cd translate-shell || exit
    run "make"
    run "${SUDO} make install"
  )
  rm -rf "$tmp" || true
  command -v trans >/dev/null 2>&1 && log "[*] translate-shell installed: $(command -v trans)" || logerr "translate-shell build failed"
}

# brave browser + OSINT extension
install_brave_browser() {
  if command -v brave-browser >/dev/null 2>&1; then
    log "[*] Brave Browser already installed"
    return 0
  fi
  log "[*] Installing Brave Browser (arch: ${ARCH})"
  run "${SUDO} curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg"
  run "echo \"deb [arch=${ARCH} signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] \
    https://brave-browser-apt-release.s3.brave.com/ stable main\" \
    | ${SUDO} tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null"
  run "${SUDO} apt-get update -y"
  run "${SUDO} apt-get install -y brave-browser"
  command -v brave-browser >/dev/null 2>&1 && log "[*] Brave installed successfully" || logerr "Brave installation failed"
}

# brave extension and force OSINT extension install via policy
install_brave_forced_extension_forensic_osint() {
  local EXT_ID="jojaomahhndmeienhjihojidkddkahcn"
  local POLICY_DIR="/etc/brave/policies/managed"
  local POLICY_FILE="${POLICY_DIR}/forensic-osint-extension.json"
  log "[*] Forcing Brave extension install: ${EXT_ID}"
  ${SUDO} mkdir -p "${POLICY_DIR}" 2>>"$LOG_FILE" || true
  ${SUDO} tee "${POLICY_FILE}" >/dev/null <<EOF
{
  "ExtensionInstallForcelist": [
    "${EXT_ID};https://clients2.google.com/service/update2/crx"
  ]
}
EOF
  ${SUDO} chmod 0644 "${POLICY_FILE}" 2>>"$LOG_FILE" || true
  ${SUDO} chown root:root "${POLICY_FILE}" 2>>"$LOG_FILE" || true
  log "[*] Brave policy written: ${POLICY_FILE}"
}

# docker engine + compose
install_docker_and_compose_if_missing() {
  if command -v docker >/dev/null 2>&1; then
    log "[*] Docker already installed: $(docker --version 2>/dev/null || echo OK)"
  else
    log "[*] Installing Docker Engine (arch: ${ARCH})"
    apt_update_once
    apt_install_one curl || true
    apt_install_one gnupg2 || true
    apt_install_one apt-transport-https || true
    apt_install_one ca-certificates || true

    run "${SUDO} mkdir -p /etc/apt/trusted.gpg.d"
    run "curl -fsSL https://download.docker.com/linux/debian/gpg | ${SUDO} gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive-keyring.gpg"

    local CODENAME=""
    [[ -r /etc/os-release ]] && CODENAME="$(. /etc/os-release 2>/dev/null; echo "${VERSION_CODENAME:-}")"
    [[ -z "${CODENAME}" ]] && CODENAME="trixie"

    run "echo \"deb [arch=${ARCH}] https://download.docker.com/linux/debian ${CODENAME} stable\" | ${SUDO} tee /etc/apt/sources.list.d/docker.list >/dev/null"
    run "${SUDO} apt-get update -y"
    run "${SUDO} apt-get install -y docker-ce docker-ce-cli containerd.io"
  fi

  if getent group docker >/dev/null 2>&1; then
    run "${SUDO} usermod -aG docker \"${TARGET_USER}\" || true"
    log "[*] Added ${TARGET_USER} to docker group (relogin required)."
  fi

  if docker compose version >/dev/null 2>&1; then
    log "[*] Docker Compose plugin present: $(docker compose version 2>/dev/null | head -n1 || echo OK)"
  elif command -v docker-compose >/dev/null 2>&1; then
    log "[*] docker-compose already present"
  else
    log "[*] Installing docker-compose standalone (latest GitHub release)"
    local COMPOSE_ARCH; COMPOSE_ARCH="$(uname -m)"   
    local tmp; tmp="$(mktemp -d)"
    (
      cd "$tmp" || exit 0
      run "curl -s https://api.github.com/repos/docker/compose/releases/latest \
        | grep browser_download_url \
        | grep \"docker-compose-linux-${COMPOSE_ARCH}\" \
        | cut -d '\"' -f 4 \
        | wget -qi -"
      run "chmod +x docker-compose-linux-${COMPOSE_ARCH}"
      run "${SUDO} mv docker-compose-linux-${COMPOSE_ARCH} /usr/local/bin/docker-compose"
    )
    rm -rf "$tmp" || true
    command -v docker-compose >/dev/null 2>&1 && log "[*] docker-compose installed" || logerr "docker-compose install failed"
  fi
}

# owlculus docker setup + wrapper
install_owlculus() {
  log "[*] Installing Owlculus (no auto-launch; no Desktop launcher)"
  install_docker_and_compose_if_missing

  local dest="/opt/owlculus"
  if [[ -d "${dest}/.git" ]]; then
    log "[*] Owlculus repo already present; pulling updates"
    run "${SUDO} git -C \"${dest}\" pull --ff-only || true"
  else
    run "${SUDO} rm -rf \"${dest}\""
    run "${SUDO} git clone https://github.com/be0vlk/owlculus.git \"${dest}\""
  fi

  if [[ ! -f "${dest}/.env" ]]; then
    ${SUDO} tee "${dest}/.env" >/dev/null <<'ENVEOF'
ADMIN_EMAIL=admin@example.com
ENVEOF
  fi

  ${SUDO} tee /usr/local/bin/owlculus >/dev/null <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cd /opt/owlculus
# Use sg to activate docker group without requiring re-login
if docker compose version >/dev/null 2>&1; then
  sg docker -c 'docker compose up -d'
else
  sg docker -c 'docker-compose up -d'
fi
echo
echo "[Owlculus] Started."
echo "Open http://localhost in your browser."
echo "Default credentials: admin / admin123" 
echo
EOF
  ${SUDO} chmod 0755 /usr/local/bin/owlculus
  ${SUDO} chown root:root /usr/local/bin/owlculus
  log "[*] Owlculus installed: /usr/local/bin/owlculus"
}

# runtime PATH adjustments (for cargo, pipx, etc)
ensure_runtime_path_now() {
  [[ ":$PATH:" == *":${TARGET_HOME}/.local/bin:"* ]] || export PATH="${TARGET_HOME}/.local/bin:$PATH"
  hash -r
}

ensure_runtime_path_now_plus() {
  local CARGO_BIN="${TARGET_HOME}/.cargo/bin"
  [[ -d "$CARGO_BIN" ]] && [[ ":$PATH:" != *":${CARGO_BIN}:"* ]] && export PATH="${CARGO_BIN}:$PATH"
  [[ ":$PATH:" != *":/usr/local/bin:"* ]] && export PATH="/usr/local/bin:$PATH"
  [[ ":$PATH:" != *":/usr/local/sbin:"* ]] && export PATH="/usr/local/sbin:$PATH"
  hash -r
}

ensure_rust_cargo_available() {
  log "[*] Ensuring Rust cargo is available + on PATH"
  run "sudo -u \"$TARGET_USER\" bash -lc 'for f in \"\$HOME/.profile\" \"\$HOME/.bashrc\"; do grep -qxF \"export PATH=\\\"\\\$HOME/.cargo/bin:\\\$PATH\\\"\" \"\$f\" 2>/dev/null || echo \"export PATH=\\\"\\\$HOME/.cargo/bin:\\\$PATH\\\"\" >> \"\$f\"; done'"
  if ! command -v cargo >/dev/null 2>&1; then
    run "sudo -u \"$TARGET_USER\" bash -lc '[ -f \"\$HOME/.cargo/env\" ] && source \"\$HOME/.cargo/env\" || true'"
  fi
  if ! command -v cargo >/dev/null 2>&1; then
    log "[*] cargo missing; attempting APT install"
    apt_install_one cargo || true
    apt_install_one rustc || true
  fi
  ensure_global_symlinks
  ensure_runtime_path_now_plus
}

# shodan installation
install_shodan_venv() {
  local dest="/opt/shodan-venv"
  log "[*] Installing shodan in dedicated venv at ${dest}"
  run "${SUDO} rm -rf \"${dest}\""
  run "${SUDO} python3 -m venv \"${dest}\""
  run "${SUDO} \"${dest}/bin/pip\" install --upgrade pip 'setuptools<72' wheel"
  run "${SUDO} \"${dest}/bin/pip\" install 'setuptools<72' shodan"
  ${SUDO} ln -sf "${dest}/bin/shodan" /usr/local/bin/shodan
  command -v shodan >/dev/null 2>&1 && log "[*] shodan installed: $(command -v shodan)" || logerr "shodan install failed"
}

ensure_shodan_available() {
  log "[*] Ensuring shodan is available"
  command -v shodan >/dev/null 2>&1 && { log "[*] shodan already present: $(command -v shodan)"; return 0; }
  install_shodan_venv
  command -v shodan >/dev/null 2>&1 && log "[*] shodan present: $(command -v shodan)" || logerr "shodan still missing after all attempts"
}

ensure_docker_engine_available() {
  if command -v docker >/dev/null 2>&1; then
    log "[*] docker present: $(docker --version 2>/dev/null || echo OK)"
    return 0
  fi
  log "[*] docker not found; falling back to docker.io"
  apt_try_install docker.io || true
  apt_try_install docker-compose-plugin || true
  if command -v systemctl >/dev/null 2>&1; then
    run "${SUDO} systemctl enable --now docker || true"
  fi
  if getent group docker >/dev/null 2>&1; then
    run "${SUDO} usermod -aG docker \"${TARGET_USER}\" || true"
  fi
  ensure_runtime_path_now_plus
  command -v docker >/dev/null 2>&1 && log "[*] docker present" || logerr "docker still missing after fallback"
}

maybe_init_shodan() {
  if [[ -n "${SHODAN_API_KEY-}" ]]; then
    run "sudo -u \"$TARGET_USER\" env SHODAN_API_KEY=\"${SHODAN_API_KEY}\" sh -lc 'shodan init \"$SHODAN_API_KEY\" || true'"
  else
    ${SUDO} mkdir -p /etc/osint 2>>"$LOG_FILE" || true
    ${SUDO} bash -lc 'echo "no-api" > /etc/osint/skip-shodan-init' 2>>"$LOG_FILE" || true
  fi
}

# theHarvester git clone + venv + pip install
install_theharvester() {
  local dest="/opt/theHarvester"
  local venv="${dest}/venv"
  log "[*] Installing theHarvester"
  run "${SUDO} rm -rf \"${dest}\""
  run "${SUDO} git clone --depth=1 https://github.com/laramies/theHarvester.git \"${dest}/src\"" || {
    logerr "theHarvester git clone failed — skipping"
    return 0
  }
  run "${SUDO} python3 -m venv \"${venv}\""
  run "${SUDO} \"${venv}/bin/pip\" install --upgrade pip 'setuptools<72' wheel"
  local req
  for req in "${dest}/src/requirements/base.txt" "${dest}/src/requirements.txt"; do
    [[ -f "$req" ]] && { run "${SUDO} \"${venv}/bin/pip\" install -r \"$req\"" || true; break; }
  done
  run "${SUDO} \"${venv}/bin/pip\" install -e \"${dest}/src\""
  ${SUDO} tee /usr/local/bin/theHarvester >/dev/null <<EOF
#!/usr/bin/env bash
if [[ -x "${venv}/bin/theHarvester" ]]; then
  exec "${venv}/bin/theHarvester" "\$@"
fi
exec "${venv}/bin/python3" -m theHarvester "\$@"
EOF
  ${SUDO} chmod 0755 /usr/local/bin/theHarvester
  command -v theHarvester >/dev/null 2>&1 && log "[*] theHarvester installed" || logerr "theHarvester install failed"
}

# photon git clone + venv + pip install
install_photon_from_source() {
  local dest="/opt/photon"
  local venv="${dest}/venv"
  log "[*] Installing Photon from source"
  run "${SUDO} rm -rf \"${dest}\""
  run "${SUDO} git clone --depth=1 https://github.com/s0md3v/Photon.git \"${dest}\""
  run "${SUDO} python3 -m venv \"${venv}\""
  run "${SUDO} \"${venv}/bin/pip\" install --upgrade pip 'setuptools<72' wheel"
  [[ -f "${dest}/requirements.txt" ]] && run "${SUDO} \"${venv}/bin/pip\" install -r \"${dest}/requirements.txt\""
  ${SUDO} tee /usr/local/bin/photon >/dev/null <<EOF
#!/usr/bin/env bash
cd "${dest}" && exec "${venv}/bin/python3" "${dest}/photon.py" "\$@"
EOF
  ${SUDO} chmod 0755 /usr/local/bin/photon
  command -v photon >/dev/null 2>&1 && log "[*] Photon installed" || logerr "Photon install failed"
}

# dumpsterdiver git clone + venv + pip install
install_dumpsterdiver() {
  local dest="/opt/DumpsterDiver"
  local venv="${dest}/venv"
  log "[*] Installing DumpsterDiver"
  run "${SUDO} rm -rf \"${dest}\""
  run "${SUDO} git clone --depth=1 https://github.com/securing/DumpsterDiver.git \"${dest}\""
  run "${SUDO} python3 -m venv \"${venv}\""
  run "${SUDO} \"${venv}/bin/pip\" install --upgrade pip 'setuptools<72' wheel"
  run "${SUDO} \"${venv}/bin/pip\" install termcolor colorama 'PyYAML>=6.0' passwordmeter 'setuptools<72'"
  ${SUDO} touch "${dest}/errors.log" && ${SUDO} chmod 666 "${dest}/errors.log"
  ${SUDO} tee /usr/local/bin/DumpsterDiver >/dev/null <<EOF
#!/usr/bin/env bash
cd "${dest}" && exec "${venv}/bin/python3" "${dest}/DumpsterDiver.py" "\$@"
EOF
  ${SUDO} chmod 0755 /usr/local/bin/DumpsterDiver
  command -v DumpsterDiver >/dev/null 2>&1 && log "[*] DumpsterDiver installed" || logerr "DumpsterDiver install failed"
}

# twayback git clone + venv + pip install via pipx (no entry point)
install_twayback() {
  log "[*] Installing Twayback"
  pipx_user_install_or_upgrade "twayback" "git+https://github.com/humandecoded/twayback.git" || true
  if [[ -x "${TARGET_HOME}/.local/bin/twayback" ]]; then
    write_wrapper "/usr/local/bin/twayback" "${TARGET_HOME}/.local/bin/twayback"
    log "[*] Twayback installed"
  else
    logerr "Twayback install failed"
  fi
}

# maltego installation skipped due to no ARM64 package. Added for consistency 
install_maltego() {
  log "[*] Maltego: ARM64 Linux package not available — skipping"
  log "[*] Maltego is amd64-only. Check https://www.maltego.com/downloads/ for ARM64 support."
}

# metagoofil git clone + venv + pip install
install_metagoofil() {
  local dest="/opt/metagoofil"
  local venv="${dest}/venv"
  log "[*] Installing metagoofil"
  if apt_try_install metagoofil; then
    log "[*] metagoofil installed via apt"
    return 0
  fi
  run "${SUDO} rm -rf \"${dest}\""
  run "${SUDO} git clone --depth=1 https://github.com/opsdisk/metagoofil.git \"${dest}\""
  run "${SUDO} python3 -m venv \"${venv}\""
  run "${SUDO} \"${venv}/bin/pip\" install --upgrade pip 'setuptools<72' wheel"
  [[ -f "${dest}/requirements.txt" ]] && run "${SUDO} \"${venv}/bin/pip\" install -r \"${dest}/requirements.txt\""
  ([[ -f "${dest}/pyproject.toml" ]] || [[ -f "${dest}/setup.py" ]]) && \
    run "${SUDO} \"${venv}/bin/pip\" install -e \"${dest}\"" || true
  if [[ -x "${venv}/bin/metagoofil" ]]; then
    ${SUDO} ln -sf "${venv}/bin/metagoofil" /usr/local/bin/metagoofil
  else
    local main="${dest}/metagoofil.py"
    [[ -f "$main" ]] || main="${dest}/metagoofil/metagoofil.py"
    ${SUDO} tee /usr/local/bin/metagoofil >/dev/null <<EOF
#!/usr/bin/env bash
cd "${dest}" && exec "${venv}/bin/python3" "${main}" "\$@"
EOF
    ${SUDO} chmod 0755 /usr/local/bin/metagoofil
  fi
  command -v metagoofil >/dev/null 2>&1 && log "[*] metagoofil installed" || logerr "metagoofil install failed"
}

# infoga depreciated but added for consistency 
install_infoga() {
  local dest="/opt/infoga"
  local venv="${dest}/venv"
  log "[*] Installing Infoga (unmaintained — may not work)"
  run "${SUDO} rm -rf \"${dest}\""
  run "${SUDO} env GIT_TERMINAL_PROMPT=0 git clone --depth=1 https://github.com/m4ll0k/Infoga.git \"${dest}\"" || {
    logerr "Infoga repo unavailable — skipping"
    return 0
  }
  run "${SUDO} python3 -m venv \"${venv}\""
  run "${SUDO} \"${venv}/bin/pip\" install --upgrade pip 'setuptools<72' wheel"
  [[ -f "${dest}/requirements.txt" ]] && run "${SUDO} \"${venv}/bin/pip\" install -r \"${dest}/requirements.txt\"" || true
  ${SUDO} tee /usr/local/bin/infoga >/dev/null <<EOF
#!/usr/bin/env bash
cd "${dest}" && exec "${venv}/bin/python3" "${dest}/infoga.py" "\$@"
EOF
  ${SUDO} chmod 0755 /usr/local/bin/infoga
  command -v infoga >/dev/null 2>&1 && log "[*] Infoga installed (unmaintained — use at own risk)" || logerr "Infoga install failed"
}

# Joplin has no ARM64 release, added for consistency but will skip install on ARM64
install_joplin() {
  log "[*] Installing Joplin for ${TARGET_USER}"
  local joplin_bin="${TARGET_HOME}/.joplin/Joplin.AppImage"
  run "sudo -u \"$TARGET_USER\" mkdir -p \"${TARGET_HOME}/.joplin\""

  if [[ "${ARCH}" == "arm64" ]]; then
    log "[WARN] Joplin desktop has no Linux ARM64 AppImage release — skipping"
    return 0
  else
    run "sudo -u \"$TARGET_USER\" bash -lc 'wget -qO - https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash' || true"
  fi

  if [[ -f "$joplin_bin" ]]; then
    ${SUDO} tee /usr/local/bin/joplin >/dev/null <<EOF
#!/usr/bin/env bash
exec env APPIMAGE_EXTRACT_AND_RUN=1 "${joplin_bin}" "\$@"
EOF
    ${SUDO} chmod 0755 /usr/local/bin/joplin
    log "[*] Joplin installed: ${joplin_bin}"
  else
    logerr "Joplin AppImage not found after install attempt"
  fi
}

# little brother git clone + venv + pip install
install_little_brother() {
  local dest="/opt/little-brother"
  local venv="${dest}/venv"
  log "[*] Installing Little Brother (archived — may not work)"
  run "${SUDO} rm -rf \"${dest}\""
  run "${SUDO} git clone --depth=1 https://github.com/lulz3xploit/LittleBrother.git \"${dest}\"" || {
    logerr "Little Brother repo unavailable (archived/deleted) — skipping"
    return 0
  }
  run "${SUDO} python3 -m venv \"${venv}\""
  run "${SUDO} \"${venv}/bin/pip\" install --upgrade pip 'setuptools<72' wheel"
  [[ -f "${dest}/requirements.txt" ]] && run "${SUDO} \"${venv}/bin/pip\" install -r \"${dest}/requirements.txt\"" || true
  ${SUDO} tee /usr/local/bin/littlebrother >/dev/null <<EOF
#!/usr/bin/env bash
cd "${dest}" && exec "${venv}/bin/python3" "${dest}/LittleBrother.py" "\$@"
EOF
  ${SUDO} chmod 0755 /usr/local/bin/littlebrother
  command -v littlebrother >/dev/null 2>&1 && log "[*] Little Brother installed (archived)" || logerr "Little Brother install failed"
}

# twint git clone + venv + pip install via pipx
install_twint() {
  log "[*] Installing Twint (archived — will not work with current Twitter/X API)"
  pipx_user_install_or_upgrade "twint" "git+https://github.com/twintproject/twint.git@origin/master#egg=twint" || \
    pipx_user_install_or_upgrade "twint" "twint" || true
  [[ -x "${TARGET_HOME}/.local/bin/twint" ]] && \
    write_wrapper "/usr/local/bin/twint" "${TARGET_HOME}/.local/bin/twint" || \
    logerr "Twint install failed (archived)"
}

# stweet git clone + venv + pip install via pipx
install_stweet() {
  log "[*] Installing Stweet (archived — may not work)"
  pipx_user_install_or_upgrade "stweet" "stweet" || true
  [[ -x "${TARGET_HOME}/.local/bin/stweet" ]] && \
    write_wrapper "/usr/local/bin/stweet" "${TARGET_HOME}/.local/bin/stweet" || \
    logerr "Stweet install failed (archived)"
}

# install all OSINT tools
install_tools_from_list() {
  log "[*] Installing OSINT tools"

  # shodan 
  install_shodan_venv

  # sherlock
  pipx_user_install_or_upgrade "sherlock" "git+https://github.com/sherlock-project/sherlock.git"

  # maigret
  pipx_user_install_or_upgrade "maigret" "maigret"

  # PhoneInfoga (Go)
  if command -v go >/dev/null 2>&1; then
    go_install_if_missing "github.com/sundowndev/phoneinfoga/v2/cmd/phoneinfoga@latest" "phoneinfoga"
  fi
  phoneinfoga_upstream_fallback

  # spiderfoot
  if ! apt_try_install spiderfoot; then
    pipx_user_install_or_upgrade "spiderfoot" "git+https://github.com/smicallef/spiderfoot.git" || true
    if [[ -x "${TARGET_HOME}/.local/bin/sf.py" ]]; then
      write_wrapper "/usr/local/bin/sf.py" "${TARGET_HOME}/.local/bin/sf.py"
    else
      install_spiderfoot_from_source
    fi
  fi

  # sn0int
  if ! apt_try_install sn0int; then
    log "[*] sn0int not in apt (apt.vulns.xyz does not support Trixie yet); building via cargo"
    ensure_rust_cargo_available
    run "sudo -u \"$TARGET_USER\" bash -lc 'source \"\$HOME/.cargo/env\" 2>/dev/null || true; cargo install --locked sn0int'"
    symlink_if_exists "${TARGET_HOME}/.cargo/bin/sn0int" "sn0int"
    ensure_runtime_path_now_plus
  fi

  # Metagoofil (git clone + venv)
  install_metagoofil
  if ! apt_try_install sublist3r; then
    pipx_user_install_or_upgrade "sublist3r" "git+https://github.com/aboul3la/Sublist3r.git"
  fi

  # theHarvester (dedicated venv)
  install_theharvester

  # h8mail
  pipx_user_install_or_upgrade "h8mail" "h8mail" || true
  [[ -x "${TARGET_HOME}/.local/bin/h8mail" ]] && write_wrapper "/usr/local/bin/h8mail" "${TARGET_HOME}/.local/bin/h8mail"

  # OSRFramework (provides domainfy, mailfy, usufy, searchfy, phonefy)
  pipx_user_install_or_upgrade "osrframework" "osrframework" || true
  for osrbin in domainfy mailfy usufy searchfy phonefy checkfy; do
    [[ -x "${TARGET_HOME}/.local/bin/${osrbin}" ]] && write_wrapper "/usr/local/bin/${osrbin}" "${TARGET_HOME}/.local/bin/${osrbin}"
  done

  # OnionSearch
  pipx_user_install_or_upgrade "onionsearch" "onionsearch" || true
  [[ -x "${TARGET_HOME}/.local/bin/onionsearch" ]] && write_wrapper "/usr/local/bin/onionsearch" "${TARGET_HOME}/.local/bin/onionsearch"

  # Photon (git clone + venv — no pyproject.toml)
  install_photon_from_source

  # DumpsterDiver
  install_dumpsterdiver

  # Twayback
  install_twayback

  # Tiktok Scraper 
  if command -v npm >/dev/null 2>&1; then
    run "${SUDO} npm install -g tiktok-scraper" || logerr "tiktok-scraper install failed (tool may be deprecated)"
  fi

  # Maltego 
  install_maltego

  # Infoga 
  install_infoga

  # Little Brother 
  install_little_brother

  # Twint 
  install_twint

  # Stweet 
  install_stweet

  # Joplin (not availble for ARM64)
  install_joplin

  # Stego tools 
  apt_try_install stegosuite || log "[*] StegOSuite not available; skipping."
  apt_try_install steghide || true
  apt_try_install stegseek || true

  # translate-shell
  install_translate_shell

  # Tor Browser launcher
  install_tor_browser_launcher

  # Brave Browser + forced OSINT extension
  install_brave_browser
  install_brave_forced_extension_forensic_osint

  # ensure wrappers and symlinks
  ensure_global_symlinks
  ensure_pipx_wrappers

  # guarantee shodan is reachable
  ensure_shodan_available

  # Shodan init 
  maybe_init_shodan
}

# OSINT updater script
install_osint_updater() {
  log "[*] Installing OSINT updater"
  local UPD="/usr/local/bin/osint-updater"
  ${SUDO} tee "$UPD" >/dev/null <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
LOG_FILE="/var/log/osint-updater.log"
touch "$LOG_FILE" 2>/dev/null || LOG_FILE="/tmp/osint-updater.log"
log()   { printf '%s [INFO] %s\n' "$(date +'%F %T')" "$*" | tee -a "$LOG_FILE" >&2; }
logerr(){ printf '%s [ERR ] %s\n' "$(date +'%F %T')" "$*" | tee -a "$LOG_FILE" >&2; }
run()   { printf '%s [EXEC] %s\n' "$(date +'%F %T')" "$*" | tee -a "$LOG_FILE" >&2; eval "$@" 2>>"$LOG_FILE"; }
export DEBIAN_FRONTEND=noninteractive

apt_self_heal_update() {
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
  fi
  if [[ -x /opt/shodan-venv/bin/pip ]]; then
    log "[*] Upgrading shodan venv"
    run "/opt/shodan-venv/bin/pip install -U 'setuptools<72' shodan || true"
  fi
}
upgrade_go_tools() {
  if command -v go >/dev/null 2>&1; then
    log "[*] Refreshing PhoneInfoga (Go)"
    run "env GOBIN=/usr/local/bin go install github.com/sundowndev/phoneinfoga/v2/cmd/phoneinfoga@latest || true"
    chmod 0755 /usr/local/bin/phoneinfoga 2>>"$LOG_FILE" || true
  fi
}
upgrade_rust_tools() {
  if command -v cargo >/dev/null 2>&1; then
    log "[*] Refreshing sn0int (Rust)"
    run "cargo install --locked sn0int"
  fi
}
main() {
  log "==== OSINT Updater starting ===="
  apt_self_heal_update
  upgrade_pipx_tools
  upgrade_go_tools
  upgrade_rust_tools
  log "==== OSINT Updater complete. See $LOG_FILE for details. ===="
}
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
Comment=Update Debian & OSINT tools
Exec=pkexec /usr/local/bin/osint-updater
Icon=system-software-update
Terminal=true
Categories=System;Utility;Security;
StartupNotify=true
EOF
  ${SUDO} chmod +x "$DESK"
  if [[ $EUID -eq 0 ]]; then ${SUDO} chown "${TARGET_USER}:${TARGET_USER}" "$DESK"; fi
}

# Firefox hardening
harden_firefox() {
  log "[*] Hardening Firefox via enterprise policies"
  apt_try_install firefox-esr || true
  local policy_tmp; policy_tmp="$(mktemp)"
  cat > "$policy_tmp" <<'JSON'
{
  "policies": {
    "DisableTelemetry": true,
    "DisableFirefoxStudies": true,
    "DisablePocket": true,
    "SanitizeOnShutdown": {
      "Cache": true, "Cookies": true, "Downloads": true, "FormData": true,
      "History": true, "Sessions": true, "SiteSettings": false, "OfflineApps": true,
      "Locked": true
    },
    "Permissions": {
      "Camera": { "Default": "block" },
      "Microphone": { "Default": "block" },
      "Location": { "Default": "block" }
    },
    "Preferences": {
      "browser.contentblocking.category": { "Value": "strict", "Status": "locked" },
      "privacy.trackingprotection.enabled": { "Value": true, "Status": "locked" },
      "privacy.trackingprotection.socialtracking.enabled": { "Value": true, "Status": "locked" },
      "privacy.resistFingerprinting": { "Value": true, "Status": "locked" },
      "toolkit.telemetry.enabled": { "Value": false, "Status": "locked" },
      "toolkit.telemetry.unified": { "Value": false, "Status": "locked" },
      "datareporting.healthreport.uploadEnabled": { "Value": false, "Status": "locked" },
      "app.shield.optoutstudies.enabled": { "Value": false, "Status": "locked" },
      "permissions.default.geo": { "Value": 2, "Status": "locked" },
      "permissions.default.microphone": { "Value": 2, "Status": "locked" },
      "permissions.default.camera": { "Value": 2, "Status": "locked" },
      "geo.enabled": { "Value": false, "Status": "locked" },
      "media.navigator.enabled": { "Value": false, "Status": "locked" }
    },
    "DisplayBookmarksToolbar": "always",
    "ManagedBookmarks": [
      { "toplevel_name": "OSINT" },
      { "name": "SpiderFoot (local)", "url": "http://127.0.0.1:5001" },
      { "name": "Shodan", "url": "https://www.shodan.io/" },
      { "name": "Censys", "url": "https://search.censys.io/" },
      { "name": "crt.sh (CT)", "url": "https://crt.sh/" },
      { "name": "urlscan.io", "url": "https://urlscan.io/" },
      { "name": "VirusTotal", "url": "https://www.virustotal.com/gui/home/search" },
      { "name": "Wayback Machine", "url": "https://web.archive.org/" },
      { "name": "HaveIBeenPwned", "url": "https://haveibeenpwned.com/" },
      { "name": "BuiltWith", "url": "https://builtwith.com/" },
      { "name": "WHOIS", "url": "https://who.is/" },
      { "name": "GreyNoise Viz", "url": "https://viz.greynoise.io/" },
      { "name": "OSINT Framework", "url": "https://osintframework.com/" },
      { "name": "Trace Labs CTF", "url": "https://www.tracelabs.org/initiatives/search-party-ctf" }
    ]
  }
}
JSON
  local targets=(
    "/etc/firefox/policies/policies.json"
    "/usr/lib/firefox-esr/distribution/policies.json"
    "/usr/lib/firefox/distribution/policies.json"
  )
  for t in "${targets[@]}"; do
    ${SUDO} mkdir -p "$(dirname "$t")"
    [[ -f "$t" && ! -f "${t}.bak" ]] && ${SUDO} cp -f "$t" "${t}.bak" 2>>"$LOG_FILE" || true
    ${SUDO} install -m 0644 "$policy_tmp" "$t"
  done
  rm -f "$policy_tmp" || true
  log "[*] Firefox policies deployed (check about:policies)."
}

# post-install checks for all tools.
post_install_checks() {
  log "[*] Post-install sanity checks"
  local missing=()
  for b in shodan sherlock maigret phoneinfoga sn0int metagoofil sublist3r exiftool tor trans steghide theHarvester h8mail httrack yt-dlp instaloader; do
    command -v "$b" >/dev/null 2>&1 || missing+=("$b")
  done
  command -v spiderfoot >/dev/null 2>&1 || command -v sf.py >/dev/null 2>&1 || missing+=("spiderfoot/sf.py")
  command -v stegseek >/dev/null 2>&1 || true
  command -v stegosuite >/dev/null 2>&1 || true
  command -v torbrowser-launcher >/dev/null 2>&1 || log "[*] torbrowser-launcher not found (optional; install manually from torproject.org)"

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
- Shodan:          shodan init <API_KEY>   (or set SHODAN_API_KEY before running)
- SpiderFoot UI:   spiderfoot -l 127.0.0.1:5001  (open http://127.0.0.1:5001)
- Maigret:         maigret <username> --html   (reports land in ./reports)
- StegHide:        steghide embed -cf cover.jpg -ef secret.txt -sf out.jpg
                   steghide extract -sf out.jpg
- StegSeek:        stegseek out.jpg /usr/share/wordlists/rockyou.txt
- Translate:       trans -b :de "Hello, how are you?"

Firefox:
- about:policies shows hardened settings; OSINT bookmarks on toolbar.
- Cookies/history cleared on exit; geo/mic/camera blocked; telemetry disabled.

Updater:
- GUI:   Double-click "OSINT Updater" on Desktop (pkexec)
- CLI:   pkexec /usr/local/bin/osint-updater

Owlculus:
- CLI:   owlculus   (starts Docker stack; open browser manually)
         Check /opt/owlculus/docker-compose.yml for the port.

Logs:
- Setup:  ~/osint-bootstrap.log
- Update: /var/log/osint-updater.log (or /tmp fallback)
----------------------------------------------------------------
EOF
}

# validator 
validator() {
  local PASSES=0 FAILS=0 WARNINGS=0
  local BLUE='\033[1;34m' GREEN='\033[1;32m' YELLOW='\033[1;33m' RED='\033[1;31m' NC='\033[0m'
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
        local flag
        for flag in "--version" "-V" "-v" "version" "--help" "-h"; do
          if "$bin" "$flag" >/dev/null 2>&1; then
            local v; v="$("$bin" "$flag" 2>/dev/null | head -n1)"
            ok "$bin $flag -> ${v:-OK}"
            return 0
          fi
        done
        "$bin" >/dev/null 2>&1 && ok "$bin -> OK" || warn "$bin present but no version/help flag worked."
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
      warn "PATH missing ${needle} (run: source ~/.profile or open a new terminal)"
    fi
  }

  check_file(){ [[ -e "$1" ]] && ok "$2 exists: $1" || fail "$2 missing: $1"; }
  check_exec(){ [[ -x "$1" ]] && ok "$2 is executable: $1" || fail "$2 not executable: $1"; }

  info "Validator starting — user: ${REAL_USER} (home: ${REAL_HOME})"
  info "Architecture: ${ARCH}"
  info "PATH: $PATH"

  show_ver python3 --version
  show_ver pipx --version || true
  show_ver go version || true
  show_ver cargo --version || true
  show_ver node --version || true
  show_ver npm --version || true
  show_ver java -version || true
  show_ver mvn -v || true
  show_ver firefox-esr --version || show_ver firefox --version || true

  check_path_contains "${REAL_HOME}/.local/bin"
  [[ -n "${GOBIN-}" ]] && check_path_contains "${GOBIN}"

  # Shodan
  if has shodan; then
    if shodan info >/dev/null 2>&1; then
      ok "Shodan is initialized"
    elif [[ -f /etc/osint/skip-shodan-init ]]; then
      ok "Shodan init deferred (no API key provided)"
    else
      warn "Shodan not initialized (run: shodan init <API_KEY>)"
    fi
  else
    fail "shodan not found on PATH"
  fi

  has phoneinfoga && (show_ver phoneinfoga version || ok "phoneinfoga present") || fail "phoneinfoga not found"

  if has spiderfoot; then ok "spiderfoot present: $(command -v spiderfoot)"
  elif has sf.py; then ok "SpiderFoot present as sf.py: $(command -v sf.py)"
  else fail "SpiderFoot not found (spiderfoot/sf.py)"; fi

  show_ver sn0int -V || true
  show_ver metagoofil -h || true
  show_ver sublist3r -h || true
  show_ver theHarvester -h || true
  show_ver h8mail -h || true
  show_ver httrack --version || true
  show_ver yt-dlp --version || true
  show_ver instaloader --version || true
  has domainfy && ok "osrframework present (domainfy: $(command -v domainfy))" || warn "osrframework not found"
  has onionsearch && ok "onionsearch present" || warn "onionsearch not found"
  has photon && ok "photon present" || warn "photon not found"
  has DumpsterDiver && ok "DumpsterDiver present" || warn "DumpsterDiver not found"
  has twayback && ok "twayback present" || warn "twayback not found"
  has tiktok-scraper && ok "tiktok-scraper present" || warn "tiktok-scraper not found (tool may be deprecated)"
  warn "Maltego not available for ARM64 (amd64-only) — check https://www.maltego.com/downloads/"
  has infoga && ok "infoga present" || warn "infoga not found (unmaintained)"
  has littlebrother && ok "Little Brother present" || warn "Little Brother not found (archived)"
  has twint && ok "twint present" || warn "twint not found (archived)"
  has stweet && ok "stweet present" || warn "stweet not found (archived)"
  has joplin && ok "Joplin present: $(command -v joplin)" || warn "Joplin not found"
  show_ver exiftool -ver || true
  has exifprobe && ok "exifprobe present" || warn "exifprobe not found"
  show_ver steghide --version || true
  show_ver stegseek --version || true
  show_ver tor --version || true
  has torbrowser-launcher && (show_ver torbrowser-launcher --help || ok "torbrowser-launcher present") || warn "torbrowser-launcher not found (not in Trixie repos; install via pipx or from torproject.org)"
  show_ver trans -V || true

  check_exec "/usr/local/bin/osint-updater" "osint-updater"
  check_file "${REAL_HOME}/Desktop/OSINT-Updater.desktop" "OSINT-Updater.desktop"

  # StegOSuite (optional on Trixie)
  if has stegosuite; then ok "StegOSuite available"
  else ok "StegOSuite optional: not installed"; fi

  # Firefox policies
  local ff_pol_etc="/etc/firefox/policies/policies.json"
  local ff_pol_sys=""
  [[ -f /usr/lib/firefox-esr/distribution/policies.json ]] && ff_pol_sys="/usr/lib/firefox-esr/distribution/policies.json"
  [[ -z "$ff_pol_sys" && -f /usr/lib/firefox/distribution/policies.json ]] && ff_pol_sys="/usr/lib/firefox/distribution/policies.json"
  if [[ -f "$ff_pol_etc" || -n "$ff_pol_sys" ]]; then ok "Firefox policies present"
  else warn "Firefox policies not found"; fi

  # Brave Browser
  local brave_pol="/etc/brave/policies/managed/forensic-osint-extension.json"
  [[ -f "$brave_pol" ]] && ok "Brave forced-extension policy present: $brave_pol" || warn "Brave forced-extension policy missing"
  has brave-browser && ok "Brave present: $(command -v brave-browser)" || warn "Brave not found (extension policy will apply once installed)"

  # Docker
  if has docker; then
    show_ver docker --version || ok "docker present"
    docker info >/dev/null 2>&1 && ok "Docker daemon reachable" || warn "Docker installed but daemon not reachable (not running or user not in docker group yet)"
  else
    warn "docker not found on PATH"
  fi

  if has docker-compose; then
    show_ver docker-compose --version || ok "docker-compose present"
  elif has docker && docker compose version >/dev/null 2>&1; then
    ok "Docker Compose plugin present: $(docker compose version 2>/dev/null | head -n1 || echo OK)"
  else
    warn "Docker Compose not found (docker compose / docker-compose missing)"
  fi

  check_exec "/usr/local/bin/owlculus" "owlculus launcher"

  local WS="${REAL_HOME}/osint-workspaces"
  if [[ -d "$WS" ]]; then ok "Workspace base exists: $WS"
  else
    [[ -n "${REAL_USER}" ]] && sudo -u "$REAL_USER" mkdir -p "$WS" 2>/dev/null || true
    [[ -d "$WS" ]] && ok "Workspace base created: $WS" || warn "Workspace base missing (will be created on first run)"
  fi

  echo
  if (( FAILS == 0 )); then
    printf "\033[1;32mAll good!\033[0m  Passes: %d  Warnings: %d  Fails: %d\n" "$PASSES" "$WARNINGS" "$FAILS"
    return 0
  else
    printf "\033[1;33mValidation finished with issues.\033[0m  Passes: %d  Warnings: %d  Fails: %d\n" "$PASSES" "$WARNINGS" "$FAILS"
    echo "Hints:"
    echo " - PATH: open a new terminal or: source ~/.profile"
    echo " - Shodan: shodan init <API_KEY>  (or rerun with SHODAN_API_KEY set)"
    echo " - SpiderFoot may be 'spiderfoot' (APT) or 'sf.py' (source/venv)"
    return 1
  fi
}

# main
main() {
  local MODE="${1:-}"

  if [[ "$MODE" == "--validate-only" ]]; then
    ensure_runtime_path_now
    ensure_runtime_path_now_plus
    validator
    exit $?
  fi

  log "==== Trace Labs OSINT Setup — Debian Trixie ARM64 (arch: ${ARCH}) ===="
  apt_self_heal
  install_base_packages

  install_docker_and_compose_if_missing
  ensure_docker_engine_available
  install_owlculus

  setup_python_envs
  setup_go_env
  setup_rust_env
  ensure_rust_cargo_available
  setup_sn0int_repo

  ensure_runtime_path_now
  ensure_runtime_path_now_plus
  install_tools_from_list
  install_osint_updater
  harden_firefox

  run "sudo -u \"$TARGET_USER\" mkdir -p \"$TARGET_HOME/osint-workspaces\""
  post_install_checks
  usage_hints
  log "==== Completed. See ${LOG_FILE} for details. ===="

  if [[ "$MODE" != "--no-validate" ]]; then
    echo
    log "[*] Running built-in validator…"
    ensure_runtime_path_now
    ensure_runtime_path_now_plus
    validator || true
  fi
}
main "${1:-}"
