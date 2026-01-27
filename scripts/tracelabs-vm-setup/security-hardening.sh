#!/usr/bin/env bash
# Trace Labs VM Security Hardening Script
# Complements the privacy.sexy script with actual security hardening
# Run AFTER privacy.sexy cleanup

set -e  # Exit on error

echo "========================================="
echo "Trace Labs VM Security Hardening"
echo "========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
   script_path=$([[ "$0" = /* ]] && echo "$0" || echo "$PWD/${0#./}")
   sudo "$script_path" || (
    echo 'Administrator privileges are required.'
    exit 1
  )
  exit 0
fi

export HOME="/home/${SUDO_USER:-${USER}}"
USERNAME="${SUDO_USER:-${USER}}"

echo "Hardening VM for user: $USERNAME"
echo ""

# ----------------------------------------------------------
# ----------------Install UFW Firewall----------------------
# ----------------------------------------------------------
echo "=== Installing and Configuring UFW Firewall ==="

if ! command -v ufw &> /dev/null; then
    echo "Installing UFW..."
    apt-get update
    apt-get install -y ufw
else
    echo "UFW already installed"
fi

# Refresh command hash to find newly installed ufw
hash -r

# Reset UFW to defaults
echo "Configuring UFW rules..."
/usr/sbin/ufw --force reset

# Default policies: deny incoming, allow outgoing
/usr/sbin/ufw default deny incoming
/usr/sbin/ufw default allow outgoing

# Allow loopback
/usr/sbin/ufw allow in on lo
/usr/sbin/ufw allow out on lo

# Enable UFW
/usr/sbin/ufw --force enable

echo "✓ Firewall configured (deny incoming, allow outgoing)"
echo ""

# ----------------------------------------------------------
# -------- Optional OPSEC Network Killswitch (Tor-only) ----
# ----------------------------------------------------------
echo "=== Optional OPSEC Network Mode (Tor Killswitch) ==="
echo "NOTE: This is OFF by default to avoid breaking onboarding/apt installs."
echo "      Enable by running this script with: TL_OPSEC=1 ./security-hardening.sh"
echo ""

if [ "${TL_OPSEC:-0}" = "1" ]; then
    echo "[!] TL_OPSEC=1 enabled: installing Tor + creating killswitch helpers"

    # Ensure Tor is present (AnonSurf may be installed via tools script; keep this idempotent)
    apt-get update
    apt-get install -y tor torsocks iptables

    # Helper: enable Tor-only outbound (allow debian-tor user, drop other outbound)
    cat > /usr/local/bin/tl-opsec-enable << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

TOR_USER="debian-tor"
if ! id -u "$TOR_USER" >/dev/null 2>&1; then
  echo "[FAIL] Tor user '$TOR_USER' not found. Is tor installed?"
  exit 1
fi
TOR_UID="$(id -u "$TOR_USER")"

echo "[+] Enabling Tor-only outbound killswitch (allows only $TOR_USER to reach the network)"
# Create a dedicated chain (idempotent)
iptables -N TL_OPSEC_OUT 2>/dev/null || true

# Ensure OUTPUT jumps to our chain early (idempotent)
iptables -C OUTPUT -j TL_OPSEC_OUT 2>/dev/null || iptables -I OUTPUT 1 -j TL_OPSEC_OUT

# Flush chain and rebuild rules
iptables -F TL_OPSEC_OUT

# Allow loopback + local traffic
iptables -A TL_OPSEC_OUT -o lo -j ACCEPT

# Allow established/related
iptables -A TL_OPSEC_OUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow Tor daemon user outbound anywhere (Tor builds circuits)
iptables -A TL_OPSEC_OUT -m owner --uid-owner "$TOR_UID" -j ACCEPT

# Allow local apps to talk to Tor on localhost (9050/9051 typical)
iptables -A TL_OPSEC_OUT -d 127.0.0.1 -p tcp -m multiport --dports 9050,9051 -j ACCEPT

# Drop everything else outbound
iptables -A TL_OPSEC_OUT -j REJECT

echo "[✓] Killswitch enabled."
echo "    To disable: sudo /usr/local/bin/tl-opsec-disable"
EOF

    # Helper: disable Tor-only outbound rules
    cat > /usr/local/bin/tl-opsec-disable << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Remove OUTPUT jump if present
iptables -D OUTPUT -j TL_OPSEC_OUT 2>/dev/null || true

# Flush and delete chain
iptables -F TL_OPSEC_OUT 2>/dev/null || true
iptables -X TL_OPSEC_OUT 2>/dev/null || true

echo "[✓] Killswitch disabled."
EOF

    chmod +x /usr/local/bin/tl-opsec-enable /usr/local/bin/tl-opsec-disable

    echo "[+] NOTE: Killswitch is not automatically activated here."
    echo "    Activate when needed with: sudo tl-opsec-enable"
    echo "    Disable with: sudo tl-opsec-disable"
else
    echo "Skipping OPSEC killswitch setup (TL_OPSEC not enabled)."
fi
echo ""

# ----------------------------------------------------------
# ------------------Disable SSH or Harden-------------------
# ----------------------------------------------------------
echo "=== Checking SSH Configuration ==="

if systemctl is-active --quiet ssh || systemctl is-active --quiet sshd; then
    echo "SSH is running."
    read -p "Do you want to DISABLE SSH entirely? (recommended for distributed VM) [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Disabling and stopping SSH..."
        systemctl stop ssh 2>/dev/null || systemctl stop sshd 2>/dev/null || true
        systemctl disable ssh 2>/dev/null || systemctl disable sshd 2>/dev/null || true
        echo "✓ SSH disabled"
    else
        echo "Hardening SSH configuration..."
        
        # Backup original config
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
        
        # Harden SSH
        sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
        sed -i 's/PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
        
        sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
        sed -i 's/PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
        
        sed -i 's/#PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
        sed -i 's/PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
        
        # Restart SSH
        systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null || true
        
        echo "✓ SSH hardened (root login disabled, password auth disabled)"
        echo "  NOTE: You'll need SSH keys to access remotely now!"
    fi
else
    echo "SSH is not running (good for distributed VM)"
fi
echo ""

# ----------------------------------------------------------
# ------------Set Up Automatic Security Updates-------------
# ----------------------------------------------------------
echo "=== Configuring Automatic Security Updates ==="

if ! command -v unattended-upgrade &> /dev/null; then
    echo "Installing unattended-upgrades..."
    apt-get install -y unattended-upgrades apt-listchanges
else
    echo "unattended-upgrades already installed"
fi

# Configure automatic updates
cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
EOF

# Enable automatic updates
cat > /etc/apt/apt.conf.d/20auto-upgrades << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

echo "✓ Automatic security updates enabled"
echo ""

# ----------------------------------------------------------
# ---------------Disable Unnecessary Services---------------
# ----------------------------------------------------------
echo "=== Disabling Unnecessary Services ==="

# List of services to disable (common but not needed for OSINT VM)
SERVICES_TO_DISABLE=(
    "bluetooth.service"
    "cups.service"
    "cups-browsed.service"
    "avahi-daemon.service"
    "ModemManager.service"
)

for service in "${SERVICES_TO_DISABLE[@]}"; do
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        echo "Disabling $service..."
        systemctl stop "$service" 2>/dev/null || true
        systemctl disable "$service" 2>/dev/null || true
    fi
done

echo "✓ Unnecessary services disabled"
echo ""

# ----------------------------------------------------------
# ----------------Kernel Hardening (sysctl)------------------
# ----------------------------------------------------------
echo "=== Applying Kernel Hardening (sysctl) ==="

# Backup existing sysctl config
if [ -f /etc/sysctl.conf ]; then
    cp /etc/sysctl.conf /etc/sysctl.conf.backup
fi

# Create hardening configuration
cat > /etc/sysctl.d/99-hardening.conf << 'EOF'
# Trace Labs VM Security Hardening (OSINT-safe defaults)
#
# NOTE:
# - These defaults aim to keep Firefox/Electron/Chromium + common OSINT tools working.
# - If you want stricter "paranoid" settings, set TL_PARANOID=1 before running.

# IP Forwarding (disable - not a router)
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# SYN Flood Protection
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 5

# Ignore ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# Ignore send redirects
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Disable source packet routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# Log Martians (packets with impossible addresses)
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# Protect against TCP time-wait assassination
net.ipv4.tcp_rfc1337 = 1

# Enable IP spoofing protection
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Disable IPv6 if not needed (optional)
# net.ipv6.conf.all.disable_ipv6 = 1
# net.ipv6.conf.default.disable_ipv6 = 1

# Kernel hardening (OSINT-safe)
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2

# ptrace_scope=2 can break debugging/analysis tools; 1 is a safer desktop default
kernel.yama.ptrace_scope = 1

# Some browsers/tools rely on unprivileged user namespaces (sandboxing)
kernel.unprivileged_userns_clone = 1

# Paranoid extras (may break browsers/tools)
# - Unprivileged BPF can break tracing/network tooling; keep off by default
# kernel.unprivileged_bpf_disabled = 1

# Restrict core dumps
kernel.core_uses_pid = 1
fs.suid_dumpable = 0

# If TL_PARANOID=1, apply stricter options at runtime (see script).

EOF

# Apply sysctl settings
/usr/sbin/sysctl -p /etc/sysctl.d/99-hardening.conf

# Optional paranoid toggles (may break browsers/tools)
if [ "${TL_PARANOID:-0}" = "1" ]; then
  echo "[!] TL_PARANOID=1 enabled: applying stricter kernel toggles"
  /usr/sbin/sysctl -w kernel.yama.ptrace_scope=2 >/dev/null || true
  /usr/sbin/sysctl -w kernel.unprivileged_bpf_disabled=1 >/dev/null || true
  /usr/sbin/sysctl -w kernel.unprivileged_userns_clone=0 >/dev/null || true
fi

echo "✓ Kernel hardening applied"
echo ""

# ----------------------------------------------------------
# -----------------Enable AppArmor Profiles-----------------
# ----------------------------------------------------------
echo "=== Enabling AppArmor ==="

if ! command -v aa-status &> /dev/null; then
    echo "Installing AppArmor..."
    apt-get install -y apparmor apparmor-utils
else
    echo "AppArmor already installed"
fi

# Enable AppArmor service (do NOT force-enforce every profile; distro defaults are safer for desktop apps)
systemctl enable apparmor
systemctl start apparmor

# If a Firefox profile exists, keep it permissive to avoid breaking the browser on some Debian builds
aa-complain /etc/apparmor.d/usr.bin.firefox* 2>/dev/null || true

echo "✓ AppArmor enabled (OSINT-safe: no global enforce)"
echo ""

# ----------------------------------------------------------
# ---------------Strong Password Policy---------------------
# ----------------------------------------------------------
echo "=== Configuring Password Policy ==="

# Install password quality library
apt-get install -y libpam-pwquality

# Configure password quality requirements
cat > /etc/security/pwquality.conf << 'EOF'
# Trace Labs Password Policy
minlen = 12
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
maxrepeat = 3
EOF

echo "✓ Password policy configured (12+ chars, mixed case, numbers, symbols)"
echo ""

# ----------------------------------------------------------
# ----------------Set Sudo Timeout--------------------------
# ----------------------------------------------------------
echo "=== Configuring Sudo Timeout ==="

# Create sudoers.d file for timeout
cat > /etc/sudoers.d/timeout << 'EOF'
# Sudo timeout: 15 minutes
Defaults timestamp_timeout=15
EOF

chmod 440 /etc/sudoers.d/timeout

echo "✓ Sudo timeout set to 15 minutes"
echo ""

# ----------------------------------------------------------
# ---------------Disable Core Dumps-------------------------
# ----------------------------------------------------------
echo "=== Disabling Core Dumps ==="

# Disable core dumps system-wide
cat > /etc/security/limits.d/disable-coredumps.conf << 'EOF'
* hard core 0
* soft core 0
EOF

# Disable automatic crash reporting
if systemctl is-active --quiet apport; then
    systemctl stop apport
    systemctl disable apport
fi

echo "✓ Core dumps disabled"
echo ""

# ----------------------------------------------------------
# ---------------Harden Shared Memory-----------------------
# ----------------------------------------------------------
echo "=== Hardening Shared Memory (/run/shm) ==="

# This can break some desktop apps/browsers (shared memory / JIT / sandboxing).
# Keep it OFF by default for an OSINT desktop VM.
# Enable only if you explicitly want it:
#   TL_HARDEN_SHM=1 ./security-hardening.sh
if [ "${TL_HARDEN_SHM:-0}" = "1" ]; then
    # Add to fstab if not already present
    if ! grep -q "tmpfs.*\/run\/shm" /etc/fstab; then
        echo "tmpfs /run/shm tmpfs defaults,noexec,nodev,nosuid 0 0" >> /etc/fstab
    fi
    mount -o remount /run/shm 2>/dev/null || true
    echo "✓ Shared memory hardened (TL_HARDEN_SHM=1)"
else
    echo "Skipping /run/shm hardening (OSINT-safe default)."
fi
echo ""

# ----------------------------------------------------------
# ---------------Check File Permissions---------------------
# ----------------------------------------------------------
echo "=== Securing File Permissions ==="

# Secure sensitive files
chmod 600 /etc/ssh/sshd_config 2>/dev/null || true
chmod 644 /etc/passwd
chmod 644 /etc/group
chmod 600 /etc/shadow
chmod 600 /etc/gshadow

echo "✓ Critical file permissions secured"
echo ""

# ----------------------------------------------------------
# ---------------Audit Logging Setup------------------------
# ----------------------------------------------------------
echo "=== Installing Audit Logging ==="

if ! command -v auditd &> /dev/null; then
    echo "Installing auditd..."
    apt-get install -y auditd
    systemctl enable auditd
    systemctl start auditd
    echo "✓ Audit logging installed and started"
else
    echo "auditd already installed"
fi
echo ""
echo ""

# ----------------------------------------------------------
# --------------MAC Address Randomization (Boot)------------
# ----------------------------------------------------------
echo "=== Configuring MAC Randomization (Boot) ==="

# Install macchanger (idempotent)
if ! command -v macchanger &> /dev/null; then
    echo "Installing macchanger..."
    apt-get install -y macchanger
else
    echo "macchanger already installed"
fi

# Script that randomizes MAC for common non-loopback interfaces
cat > /usr/local/bin/tl-macspoof << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

if ! command -v macchanger >/dev/null 2>&1; then
  echo "[FAIL] macchanger not found"
  exit 1
fi

# Enumerate interfaces; skip lo + common virtual/bridge interfaces
mapfile -t ifaces < <(ip -o link show | awk -F': ' '{print $2}')
for iface in "${ifaces[@]}"; do
  case "$iface" in
    lo|docker*|br-*|veth*|virbr*|vboxnet*|vmnet*|tun*|tap*|wg*|tailscale* )
      continue
      ;;
  esac

  # Only attempt on interfaces that exist and are not loopback
  if ip link show "$iface" >/dev/null 2>&1; then
    echo "[+] Randomizing MAC on: $iface"
    macchanger -r "$iface" >/dev/null || true
  fi
done
EOF
chmod +x /usr/local/bin/tl-macspoof

# systemd unit to run before networking
cat > /etc/systemd/system/tl-macspoof.service << 'EOF'
[Unit]
Description=Trace Labs VM - Randomize MAC addresses at boot
Before=network-pre.target
Wants=network-pre.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/tl-macspoof
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable tl-macspoof.service
echo "✓ MAC spoof service enabled (runs each boot)"
echo ""

# ----------------------------------------------------------
# ---------------Final Security Checks----------------------
# ----------------------------------------------------------
echo "=== Running Final Security Checks ==="

# Check for world-writable files in /home
echo "Checking for insecure file permissions..."
WRITABLE=$(find /home -type f -perm -002 2>/dev/null | wc -l)
if [ "$WRITABLE" -gt 0 ]; then
    echo "⚠ Warning: Found $WRITABLE world-writable files in /home"
    echo "  Consider reviewing with: find /home -type f -perm -002"
else
    echo "✓ No world-writable files in /home"
fi

# Check UFW status
if /usr/sbin/ufw status | grep -q "Status: active"; then
    echo "✓ Firewall is active"
else
    echo "⚠ Warning: Firewall is not active"
fi

# Check if automatic updates are enabled
if systemctl is-enabled unattended-upgrades &>/dev/null; then
    echo "✓ Automatic updates enabled"
else
    echo "⚠ Warning: Automatic updates not enabled"
fi

echo ""
echo "========================================="
echo "✓ Security Hardening Complete!"
echo "========================================="
echo ""
echo "Summary of hardening applied:"
echo "  ✓ UFW firewall enabled (deny incoming)"
echo "  ✓ SSH disabled/hardened"
echo "  ✓ Automatic security updates enabled"
echo "  ✓ Unnecessary services disabled"
echo "  ✓ Kernel hardening (sysctl, OSINT-safe defaults)"
echo "  ✓ AppArmor enabled (no global enforce)"
echo "  ✓ Strong password policy"
echo "  ✓ Sudo timeout configured"
echo "  ✓ Core dumps disabled"
echo "  ✓ Shared memory hardening: optional (TL_HARDEN_SHM=1)"
echo "  ✓ Critical file permissions secured"
echo "  ✓ Audit logging enabled"
echo ""
echo "IMPORTANT NOTES:"
echo "  - SSH may be disabled (good for distributed VM)"
echo "  - Firewall blocks all incoming connections"
echo "  - System will auto-update security patches"
echo "  - Optional strict mode: TL_PARANOID=1 (may break browsers/tools)"
echo ""
echo "Press any key to exit."
read -n 1 -s
