#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# TL OSINT Debian "All Tools" Installer (single script)
# ============================================================
# Designed for use inside a menu installer:
# - Runs safely as root (sudo)
# - Installs all tools from your lists
# - Creates wrappers for venv-based Python tools
# - Ends with a PASS/WARN/FAIL validation report + final verdict
# ============================================================

export DEBIAN_FRONTEND=noninteractive

TOOLS_DIR="${TOOLS_DIR:-/opt/tlosint-tools}"
BIN_DIR="/usr/local/bin"
TARGET_USER="${TARGET_USER:-}"  # optional: add to docker group

# Toggle groups (menu installer can set these env vars)
DO_APT_UPDATE="${DO_APT_UPDATE:-1}"
INSTALL_DOCKER="${INSTALL_DOCKER:-1}"
INSTALL_BRAVE="${INSTALL_BRAVE:-1}"
FORCE_BRAVE_EXTENSION="${FORCE_BRAVE_EXTENSION:-1}"

# Brave forced extension policy (Chromium policy)
FORENSIC_EXT_ID="jojaomahhndmeienhjihojidkddkahcn"     # from your Chrome Web Store link
CWS_UPDATE_URL="https://clients2.google.com/service/update2/crx"
BRAVE_POLICY_DIR="/etc/brave/policies/managed"
BRAVE_POLICY_FILE="${BRAVE_POLICY_DIR}/tlosint-policy.json"

# -----------------------------
# Logging / helpers
# -----------------------------
log() { echo -e "\n[+] $*\n"; }
warn() { echo -e "\n[!] $*\n" >&2; }

need_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    echo "Run as root: sudo $0" >&2
    exit 1
  fi
}

command_exists() { command -v "$1" >/dev/null 2>&1; }

ensure_dir() {
  mkdir -p "$1"
  chmod 0755 "$1"
}

fetch() {
  local url="$1"
  local out="$2"
  if command_exists curl; then
    curl -LfsS "$url" -o "$out"
  else
    wget -qO "$out" "$url"
  fi
}

# -----------------------------
# Base system + deps
# -----------------------------
apt_update_upgrade() {
  [[ "$DO_APT_UPDATE" == "1" ]] || { log "Skipping apt update/upgrade"; return 0; }
  log "APT update/upgrade"
  apt-get update -y
  apt-get upgrade -y
}

install_base_packages() {
  log "Installing base packages & build dependencies"

  apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    gnupg2 \
    lsb-release \
    apt-transport-https \
    build-essential \
    pkg-config \
    libsodium-dev \
    libseccomp-dev \
    libsqlite3-dev \
    git \
    curl \
    wget \
    jq \
    unzip \
    xz-utils \
    tar \
    make \
    automake \
    autoconf \
    libtool \
    perl \
    python3 \
    python3-pip \
    python3-venv \
    pipx \
    default-jre-headless \
    default-jdk \
    maven \
    golang \
    rustc \
    cargo \
    zlib1g-dev \
    libjpeg-dev \
    libmcrypt-dev \
    libmhash-dev

  # Optional: not required for your tools, but nice to have on some distros.
  # Don’t fail the entire installer if the package isn’t available in this repo set.
  if apt-cache show software-properties-common >/dev/null 2>&1; then
    apt-get install -y --no-install-recommends software-properties-common
  else
    warn "software-properties-common not available in this APT config; skipping."
  fi
}

prep_dirs() {
  log "Preparing directories"
  ensure_dir "$TOOLS_DIR"
  ensure_dir "$BIN_DIR"
}

# -----------------------------
# pipx installer helper (fallback to venv if needed)
# -----------------------------
pipx_install() {
  local pkg="$1"
  if command_exists pipx; then
    # Install pipx apps into /usr/local/bin for system-wide usage in a VM image
    PIPX_HOME="/root/.local/pipx" PIPX_BIN_DIR="/usr/local/bin" pipx install --force "$pkg"
    return 0
  fi

  # Fallback: venv + symlink scripts
  warn "pipx not found; using venv fallback for ${pkg}"
  local venv_dir="/opt/pyapps/${pkg//[^a-zA-Z0-9._-]/_}"
  python3 -m venv "$venv_dir"
  "$venv_dir/bin/pip" install -U pip setuptools wheel
  "$venv_dir/bin/pip" install "$pkg"

  for f in "$venv_dir/bin/"*; do
    [[ -f "$f" && -x "$f" ]] || continue
    local name
    name="$(basename "$f")"
    if [[ "$name" =~ ^(python|python3|pip|pip3|activate)$ ]]; then
      continue
    fi
    ln -sf "$f" "${BIN_DIR}/${name}"
  done
}

# ============================================================
# Tools
# ============================================================

# sn0int (must): cargo --locked sn0int
install_sn0int() {
  log "Installing sn0int via cargo (--locked) (using /opt build+tmp dirs to avoid /tmp space issues)"

  # Build outside /tmp to avoid "No space left on device" on small /tmp partitions
  ensure_dir "${TOOLS_DIR}/.cargo-target"
  ensure_dir "${TOOLS_DIR}/.tmp"
  export CARGO_TARGET_DIR="${TOOLS_DIR}/.cargo-target"

  # rustc temp files (still default to /tmp unless TMPDIR is set)
  export TMPDIR="${TOOLS_DIR}/.tmp"
  export CARGO_TARGET_TMPDIR="${TOOLS_DIR}/.tmp"

  # Reduce parallel compilation pressure (helps on small disks)
  export CARGO_BUILD_JOBS="${CARGO_BUILD_JOBS:-1}"

  cargo install --locked sn0int

  # Symlink for consistency
  if [[ -x "/root/.cargo/bin/sn0int" ]]; then
    ln -sf "/root/.cargo/bin/sn0int" "${BIN_DIR}/sn0int"
  fi

  # Cleanup build artifacts to recover disk space
  rm -rf "${CARGO_TARGET_DIR}" || true
  rm -rf "${TMPDIR}" || true
  unset CARGO_TARGET_DIR
  unset TMPDIR
  unset CARGO_TARGET_TMPDIR
}

# ExifTool (source build)
install_exiftool() {
  log "Installing ExifTool from source"
  cd "$TOOLS_DIR"

  if [[ ! -d "${TOOLS_DIR}/exiftool" ]]; then
    git clone --depth 1 https://github.com/exiftool/exiftool exiftool
  fi

  cd exiftool
  perl Makefile.PL
  make
  make test || true
  make install
}

# Sherlock (pipx)
install_sherlock() {
  log "Installing sherlock-project (pipx preferred)"
  pipx_install "sherlock-project"
}

# metagoofil (git + venv + reqs) + wrapper
install_metagoofil() {
  log "Installing metagoofil"
  cd "$TOOLS_DIR"

  if [[ ! -d "${TOOLS_DIR}/metagoofil" ]]; then
    git clone https://github.com/opsdisk/metagoofil metagoofil
  fi

  cd metagoofil
  python3 -m venv .venv
  # shellcheck disable=SC1091
  . .venv/bin/activate
  pip install -U pip setuptools wheel
  pip install -r requirements.txt
  deactivate

  cat > "${BIN_DIR}/metagoofil" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cd /opt/tlosint-tools/metagoofil
source .venv/bin/activate
exec python3 metagoofil.py "$@"
EOF
  chmod +x "${BIN_DIR}/metagoofil"
}

# Sublist3r (git + venv + reqs) + wrapper
install_sublist3r() {
  log "Installing Sublist3r"
  cd "$TOOLS_DIR"

  if [[ ! -d "${TOOLS_DIR}/Sublist3r" ]]; then
    git clone https://github.com/aboul3la/Sublist3r.git Sublist3r
  fi

  cd Sublist3r
  python3 -m venv .venv
  # shellcheck disable=SC1091
  . .venv/bin/activate
  pip install -U pip setuptools wheel
  pip install -r requirements.txt
  deactivate

  cat > "${BIN_DIR}/sublist3r" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cd /opt/tlosint-tools/Sublist3r
source .venv/bin/activate
exec python3 sublist3r.py "$@"
EOF
  chmod +x "${BIN_DIR}/sublist3r"
}

# steghide (apt)
install_steghide() {
  log "Installing steghide via apt"
  apt-get install -y steghide
}

# stegseek (prefer Debian apt; fallback to GitHub .deb)
install_stegseek() {
  log "Installing stegseek (prefer Debian apt; fallback to GitHub .deb)"

  # Prefer distro package if available
  if apt-cache show stegseek >/dev/null 2>&1; then
    apt-get install -y stegseek
    return 0
  fi

  # Fallback: GitHub .deb if not available in apt repos
  local api="https://api.github.com/repos/RickdeJager/stegseek/releases/latest"
  local tmpdir
  tmpdir="$(mktemp -d)"

  local deb_url
  deb_url="$(curl -fsS "$api" \
    | jq -r '.assets[] | select(.name | endswith(".deb")) | .browser_download_url' \
    | head -n 1)"

  if [[ -z "${deb_url}" || "${deb_url}" == "null" ]]; then
    warn "Could not find a .deb asset for stegseek latest release."
    rm -rf "$tmpdir"
    return 1
  fi

  local deb_path="${tmpdir}/stegseek.deb"
  fetch "$deb_url" "$deb_path"
  apt-get install -y "$deb_path"
  rm -rf "$tmpdir"
}

# stegosuite (best-effort): build jar then jdeb, but DO NOT fail whole install if Maven deps break
install_stegosuite() {
  log "Installing stegosuite (best-effort: build jar then build .deb via maven jdeb:jdeb)"
  cd "$TOOLS_DIR"

  if [[ ! -d "${TOOLS_DIR}/stegosuite" ]]; then
    git clone https://github.com/osde8info/stegosuite stegosuite
  fi

  cd stegosuite

  # Maven 3.8+ blocks HTTP repos. Stegosuite references an HTTP SWT repo.
  # Provide a minimal settings.xml that forces HTTPS for that repo id.
  ensure_dir "/root/.m2"
  cat > "/root/.m2/settings.xml" <<'EOF'
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">
  <mirrors>
    <!-- Force the SWT repo to HTTPS (Maven blocks plain HTTP by default) -->
    <mirror>
      <id>swt-maven-repo</id>
      <mirrorOf>swt-maven-repo</mirrorOf>
      <url>https://maven-eclipse.github.io/maven</url>
    </mirror>
  </mirrors>
</settings>
EOF

  # Build attempts should NOT break the whole VM build
  set +e
  mvn -q -DskipTests clean package
  local pkg_rc=$?
  set -e

  if [[ $pkg_rc -ne 0 ]]; then
    warn "stegosuite: mvn package failed (best-effort). Repo is present; continuing."
    return 0
  fi

  local jar_file=""
  jar_file="$(find target -maxdepth 1 -type f -name "*.jar" ! -name "*sources.jar" ! -name "*javadoc.jar" | head -n 1 || true)"
  if [[ -z "$jar_file" ]]; then
    warn "stegosuite: jar not found after mvn package (best-effort). Continuing."
    return 0
  fi

  # Ensure the jar name jdeb expects exists
  local expected="target/stegosuite-0.8.0.jar"
  if [[ ! -f "$expected" ]]; then
    cp -f "$jar_file" "$expected"
  fi

  set +e
  mvn -q -DskipTests jdeb:jdeb
  local jdeb_rc=$?
  set -e

  if [[ $jdeb_rc -ne 0 ]]; then
    warn "stegosuite: mvn jdeb:jdeb failed (best-effort). Jar exists; continuing."
    return 0
  fi

  local deb_file
  deb_file="$(find target -maxdepth 3 -type f -name "*.deb" | head -n 1 || true)"
  if [[ -n "$deb_file" ]]; then
    apt-get install -y "./${deb_file}" || true
  else
    warn "stegosuite: no .deb produced (best-effort). Jar exists; continuing."
  fi
}

# PhoneInfoga (install script + install binary to /usr/local/bin)
install_phoneinfoga() {
  log "Installing PhoneInfoga via official install script"
  bash <( curl -sSL https://raw.githubusercontent.com/sundowndev/phoneinfoga/master/support/scripts/install )

  # Locate produced binary and install to /usr/local/bin/phoneinfoga
  local found=""
  for p in "./phoneinfoga" "/tmp/phoneinfoga" "${TOOLS_DIR}/phoneinfoga/phoneinfoga"; do
    if [[ -x "$p" ]]; then found="$p"; break; fi
  done
  if [[ -z "$found" ]]; then
    found="$(find / -maxdepth 5 -type f -name phoneinfoga -perm -111 2>/dev/null | head -n 1 || true)"
  fi
  if [[ -z "$found" ]]; then
    warn "Could not find phoneinfoga binary after install script."
    return 1
  fi

  install -m 0755 "$found" /usr/local/bin/phoneinfoga
}

# Docker CE + docker-compose latest
install_docker_and_compose() {
  [[ "$INSTALL_DOCKER" == "1" ]] || { log "Skipping Docker install"; return 0; }
  log "Installing Docker CE + Docker Compose (latest x86_64)"

  # Docker GPG
  curl -fsSL https://download.docker.com/linux/debian/gpg \
    | gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive-keyring.gpg

  # Repo
  local codename
  # shellcheck disable=SC1091
  codename="$(. /etc/os-release && echo "${VERSION_CODENAME}")"
  echo "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/debian ${codename} stable" \
    > /etc/apt/sources.list.d/docker.list

  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io

  # Optional: add a user to docker group
  if [[ -n "$TARGET_USER" ]] && id "$TARGET_USER" >/dev/null 2>&1; then
    usermod -aG docker "$TARGET_USER" || true
  fi

  # docker-compose latest
  local tmpdir
  tmpdir="$(mktemp -d)"
  local compose_url
  compose_url="$(curl -fsS https://api.github.com/repos/docker/compose/releases/latest \
    | jq -r '.assets[] | select(.name=="docker-compose-linux-x86_64") | .browser_download_url' \
    | head -n 1)"

  if [[ -z "${compose_url}" || "${compose_url}" == "null" ]]; then
    warn "Could not find docker-compose-linux-x86_64 in latest release assets."
    rm -rf "$tmpdir"
    return 1
  fi

  fetch "$compose_url" "${tmpdir}/docker-compose"
  chmod +x "${tmpdir}/docker-compose"
  mv "${tmpdir}/docker-compose" /usr/local/bin/docker-compose
  rm -rf "$tmpdir"
}

# owlculus (clone only; chmod setup.sh; do not run)
install_owlculus() {
  log "Cloning owlculus (do not run setup.sh automatically)"
  cd "$TOOLS_DIR"

  if [[ ! -d "${TOOLS_DIR}/owlculus" ]]; then
    git clone https://github.com/be0vlk/owlculus.git
  fi

  chmod +x "${TOOLS_DIR}/owlculus/setup.sh" || true

  cat > "${TOOLS_DIR}/owlculus/README.TLOSINT" <<'EOF'
This repo was cloned for TL OSINT tooling.
Per build requirements: do NOT run ./setup.sh automatically.
The user can run it later if desired.
EOF
}

# Brave browser (official install.sh)
install_brave() {
  [[ "$INSTALL_BRAVE" == "1" ]] || { log "Skipping Brave install"; return 0; }
  log "Installing Brave Browser"
  curl -fsS https://dl.brave.com/install.sh | sh
}

# Force Brave extension via managed policy
force_brave_extension() {
  [[ "$FORCE_BRAVE_EXTENSION" == "1" ]] || { log "Skipping Brave forced extension policy"; return 0; }

  log "Setting Brave managed policy to force-install extension ${FORENSIC_EXT_ID}"
  ensure_dir "$BRAVE_POLICY_DIR"

  cat > "$BRAVE_POLICY_FILE" <<EOF
{
  "ExtensionInstallForcelist": [
    "${FORENSIC_EXT_ID};${CWS_UPDATE_URL}"
  ]
}
EOF

  chmod 0644 "$BRAVE_POLICY_FILE"
}

# ============================================================
# Validators / Test Report (PASS/WARN/FAIL)
# ============================================================

pass_count=0
warn_count=0
fail_count=0

inc_pass() { pass_count=$((pass_count + 1)); }
inc_warn() { warn_count=$((warn_count + 1)); }
inc_fail() { fail_count=$((fail_count + 1)); }

check_cmd() {
  local label="$1"
  local cmd="$2"
  if command_exists "$cmd"; then
    echo "[PASS] ${label}: $(command -v "$cmd")"
    inc_pass
  else
    echo "[FAIL] ${label}: command not found (${cmd})"
    inc_fail
  fi
}

check_file() {
  local label="$1"
  local path="$2"
  if [[ -e "$path" ]]; then
    echo "[PASS] ${label}: ${path}"
    inc_pass
  else
    echo "[FAIL] ${label}: missing (${path})"
    inc_fail
  fi
}

check_dir() {
  local label="$1"
  local path="$2"
  if [[ -d "$path" ]]; then
    echo "[PASS] ${label}: ${path}"
    inc_pass
  else
    echo "[FAIL] ${label}: missing (${path})"
    inc_fail
  fi
}

check_warn_file() {
  local label="$1"
  local path="$2"
  if [[ -e "$path" ]]; then
    echo "[PASS] ${label}: ${path}"
    inc_pass
  else
    echo "[WARN] ${label}: missing (${path})"
    inc_warn
  fi
}

check_brave_policy_contains_ext() {
  local label="$1"
  if [[ -f "$BRAVE_POLICY_FILE" ]] && grep -q "$FORENSIC_EXT_ID" "$BRAVE_POLICY_FILE"; then
    echo "[PASS] ${label}: policy contains extension id"
    inc_pass
  else
    echo "[FAIL] ${label}: policy missing or extension id not present"
    inc_fail
  fi
}

validate_install() {
  log "Validation report (PASS/WARN/FAIL)"

  # Core deps / language runtimes (useful sanity)
  check_cmd "python3" "python3"
  check_cmd "pip" "pip3"
  check_cmd "java" "java"
  check_cmd "mvn" "mvn"
  check_cmd "git" "git"
  check_cmd "curl" "curl"
  check_cmd "wget" "wget"
  check_cmd "jq" "jq"
  check_cmd "cargo" "cargo"
  check_cmd "go" "go"

  # Tools
  check_cmd "sn0int" "sn0int"
  check_cmd "ExifTool" "exiftool"
  check_cmd "sherlock" "sherlock"
  check_cmd "metagoofil wrapper" "metagoofil"
  check_cmd "sublist3r wrapper" "sublist3r"
  check_cmd "steghide" "steghide"
  check_cmd "stegseek" "stegseek"

  check_dir "stegosuite repo" "${TOOLS_DIR}/stegosuite"
  # Best-effort: WARN if jar missing (repo exists means installer did its part)
  check_warn_file "stegosuite jar (best-effort)" "${TOOLS_DIR}/stegosuite/target/stegosuite-0.8.0.jar"

  check_cmd "phoneinfoga" "phoneinfoga"

  if [[ "$INSTALL_DOCKER" == "1" ]]; then
    check_cmd "docker" "docker"
    check_cmd "docker-compose" "docker-compose"
  else
    echo "[SKIP] Docker checks (INSTALL_DOCKER=0)"
  fi

  check_dir "owlculus repo" "${TOOLS_DIR}/owlculus"
  check_file "owlculus setup.sh" "${TOOLS_DIR}/owlculus/setup.sh"

  if [[ "$INSTALL_BRAVE" == "1" ]]; then
    # Brave binary can be brave-browser or brave depending on channel; check both
    if command_exists brave-browser; then
      echo "[PASS] Brave Browser: $(command -v brave-browser)"; inc_pass
    elif command_exists brave; then
      echo "[PASS] Brave Browser: $(command -v brave)"; inc_pass
    else
      echo "[FAIL] Brave Browser: command not found (brave-browser/brave)"; inc_fail
    fi
  else
    echo "[SKIP] Brave checks (INSTALL_BRAVE=0)"
  fi

  if [[ "$FORCE_BRAVE_EXTENSION" == "1" ]]; then
    check_file "Brave managed policy file" "$BRAVE_POLICY_FILE"
    check_brave_policy_contains_ext "Brave forced extension configured"
    echo "      Note: the extension actually downloads/installs the first time Brave runs with network access."
  else
    echo "[SKIP] Brave extension policy checks (FORCE_BRAVE_EXTENSION=0)"
  fi

  echo
  echo "========================================"
  echo "Validation summary: PASS=${pass_count} WARN=${warn_count} FAIL=${fail_count}"
  echo "========================================"

  # Final verdict line (what your menu installer / humans want)
  if [[ "$fail_count" -ne 0 ]]; then
    echo "[✗] INSTALLATION FAILED: one or more required tools are missing."
    return 1
  fi

  if [[ "$warn_count" -ne 0 ]]; then
    echo "[!] INSTALLATION COMPLETED WITH WARNINGS: best-effort components may need manual attention."
    return 0
  fi

  echo "[✓] INSTALLATION SUCCESS: all tools validated."
  return 0
}

# ============================================================
# Main
# ============================================================
main() {
  need_root
  apt_update_upgrade
  install_base_packages
  prep_dirs

  # Install all tools
  install_sn0int
  install_exiftool
  install_sherlock
  install_metagoofil
  install_sublist3r
  install_steghide
  install_stegseek
  install_stegosuite
  install_phoneinfoga
  install_docker_and_compose
  install_owlculus
  install_brave
  force_brave_extension

  # Validators at the end
  validate_install
}

main "$@"
