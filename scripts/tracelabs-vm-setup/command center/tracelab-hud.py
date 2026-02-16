#!/usr/bin/env python3
"""Trace Labs Security HUD - Ultimate Edition
A comprehensive, cyberpunk-themed security posture monitor for OSINT operations.
Powered by HowsMyPrivacy.

Compact rectangle when collapsed, comprehensive security dashboard when expanded.
"""

import math
import os
import re
import socket
import subprocess
import threading
import time
from dataclasses import dataclass
from datetime import datetime
from typing import List, Optional, Tuple

import gi
gi.require_version("Gtk", "4.0")
gi.require_version("Gdk", "4.0")
from gi.repository import Gdk, GLib, Gtk

import cairo


# ---------------------------------------------------------------------------
# Version
# ---------------------------------------------------------------------------
VERSION = "2.0.0"
POWERED_BY = "HowsMyPrivacy"


# ---------------------------------------------------------------------------
# Data model
# ---------------------------------------------------------------------------

@dataclass
class SecurityCheck:
    name: str
    status: str  # "green", "yellow", "red"
    detail: str
    section: str  # "Network", "System", "Privacy"
    priority: int = 1  # 1=high, 2=medium, 3=low


@dataclass
class HUDStats:
    total_checks: int = 0
    green_count: int = 0
    yellow_count: int = 0
    red_count: int = 0
    threat_level: str = "UNKNOWN"
    vpn_uptime: str = "N/A"
    last_scan: str = ""
    active_connections: int = 0


# ---------------------------------------------------------------------------
# Trace Labs Cyberpunk Color Palette (Enhanced)
# ---------------------------------------------------------------------------

COLORS = {
    "bg_dark":      (0x0a / 255, 0x0a / 255, 0x0a / 255),    # Pure black
    "bg_panel":     (0x15 / 255, 0x15 / 255, 0x15 / 255),    # Dark panel
    "accent":       (0x00 / 255, 0xff / 255, 0xd9 / 255),    # Trace Labs cyan/teal
    "accent_bright": (0x00 / 255, 0xff / 255, 0xff / 255),   # Bright cyan
    "green":        (0x00 / 255, 0xff / 255, 0x41 / 255),    # Matrix green
    "yellow":       (0xfc / 255, 0xc8 / 255, 0x00 / 255),    # Warning yellow
    "red":          (0xff / 255, 0x00 / 255, 0x40 / 255),    # Alert red
    "dim":          (0.40, 0.40, 0.35),
    "text":         (0.85, 0.85, 0.80),
    "text_bright":  (0.95, 0.95, 0.90),
    "grid":         (0.15, 0.25, 0.25),
}

STATUS_COLORS = {
    "green":  COLORS["green"],
    "yellow": COLORS["yellow"],
    "red":    COLORS["red"],
}


# ---------------------------------------------------------------------------
# Security scanner (Enhanced)
# ---------------------------------------------------------------------------

PRIVACY_DNS = {
    "9.9.9.9", "9.9.9.10", "9.9.9.11", "9.9.9.12",
    "149.112.112.112",
    "1.1.1.1", "1.0.0.1",
    "208.67.222.222", "208.67.220.220",
    "8.8.8.8", "8.8.4.4",
    "45.90.28.0", "45.90.30.0",
    "94.140.14.14", "94.140.15.15",
}

KNOWN_DEFAULT_HOSTNAMES = re.compile(
    r"^(localhost|kali|parrot|ubuntu|debian|raspberrypi|"
    r"tracelabs|pc|desktop|laptop|user)$",
    re.IGNORECASE,
)

IDENTIFIABLE_HOSTNAME = re.compile(
    r"[A-Z][a-z]+[-_ ][A-Z][a-z]+",
)


class SecurityScanner:
    """Runs all security checks with comprehensive monitoring."""

    def __init__(self):
        self.checks: List[SecurityCheck] = []
        self.score: int = 0
        self.scan_time: str = ""
        self.stats: HUDStats = HUDStats()
        self.vpn_start_time: Optional[float] = None

    @staticmethod
    def _run(cmd: str, timeout: int = 5) -> Optional[str]:
        try:
            r = subprocess.run(
                cmd, shell=True, capture_output=True, text=True, timeout=timeout
            )
            return r.stdout.strip()
        except Exception:
            return None

    @staticmethod
    def _read(path: str) -> Optional[str]:
        try:
            with open(path) as f:
                return f.read()
        except Exception:
            return None

    def check_vpn(self) -> SecurityCheck:
        try:
            net_dir = "/sys/class/net"
            if not os.path.isdir(net_dir):
                return SecurityCheck("VPN Status", "yellow", "Cannot read net info", "Network", 1)
            ifaces = os.listdir(net_dir)
            vpn_ifaces = [i for i in ifaces if i.startswith(("tun", "wg", "tap"))]
            if vpn_ifaces:
                for vi in vpn_ifaces:
                    operstate = self._read(f"{net_dir}/{vi}/operstate")
                    if operstate and operstate.strip() == "up":
                        # Track VPN uptime
                        if self.vpn_start_time is None:
                            self.vpn_start_time = time.time()
                        return SecurityCheck("VPN Status", "green", f"{vi} UP", "Network", 1)
                self.vpn_start_time = None
                return SecurityCheck("VPN Status", "yellow", f"{', '.join(vpn_ifaces)} down", "Network", 1)
            self.vpn_start_time = None
            return SecurityCheck("VPN Status", "red", "No VPN found", "Network", 1)
        except Exception:
            return SecurityCheck("VPN Status", "yellow", "Error", "Network", 1)

    def check_tor(self) -> SecurityCheck:
        try:
            active = self._run("systemctl is-active tor 2>/dev/null")
            if active == "active":
                s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                s.settimeout(2)
                try:
                    s.connect(("127.0.0.1", 9050))
                    s.close()
                    return SecurityCheck("Tor Status", "green", "Running :9050", "Network", 1)
                except Exception:
                    s.close()
                    return SecurityCheck("Tor Status", "green", "Active (port N/A)", "Network", 1)
            which = self._run("which tor 2>/dev/null")
            if which:
                return SecurityCheck("Tor Status", "yellow", "Installed, stopped", "Network", 1)
            return SecurityCheck("Tor Status", "red", "Not found", "Network", 1)
        except Exception:
            return SecurityCheck("Tor Status", "yellow", "Error", "Network", 1)

    def check_dns(self) -> SecurityCheck:
        try:
            resolv = self._read("/etc/resolv.conf")
            if not resolv:
                return SecurityCheck("DNS Leak", "yellow", "Cannot read resolv.conf", "Network", 1)
            nameservers = re.findall(r"nameserver\s+(\S+)", resolv)
            if not nameservers:
                return SecurityCheck("DNS Leak", "yellow", "No nameservers", "Network", 1)
            ns_display = ", ".join(nameservers[:2])
            if len(nameservers) > 2:
                ns_display += "..."
            if any(ns in PRIVACY_DNS for ns in nameservers):
                return SecurityCheck("DNS Leak", "green", ns_display, "Network", 1)
            wsl_pattern = re.compile(r"^(172\.(1[6-9]|2\d|3[01])|10\.|192\.168\.)")
            if any(wsl_pattern.match(ns) for ns in nameservers):
                return SecurityCheck("DNS Leak", "yellow", f"WSL proxy {ns_display}", "Network", 1)
            return SecurityCheck("DNS Leak", "red", f"ISP DNS {ns_display}", "Network", 1)
        except Exception:
            return SecurityCheck("DNS Leak", "yellow", "Error", "Network", 1)

    def check_webrtc_leak(self) -> SecurityCheck:
        """Check for potential WebRTC leaks by examining network interfaces."""
        try:
            # Check if there are non-VPN interfaces with public IPs
            interfaces = self._run("ip -4 addr show | grep 'inet ' | awk '{print $2}'")
            if interfaces:
                lines = interfaces.split('\n')
                public_ips = []
                for line in lines:
                    ip = line.split('/')[0]
                    # Skip localhost, private IPs, and VPN ranges
                    if not ip.startswith(('127.', '10.', '172.16.', '172.17.', '172.18.', 
                                         '172.19.', '172.20.', '172.21.', '172.22.', '172.23.',
                                         '172.24.', '172.25.', '172.26.', '172.27.', '172.28.',
                                         '172.29.', '172.30.', '172.31.', '192.168.')):
                        if ip != '':
                            public_ips.append(ip)
                
                if public_ips:
                    return SecurityCheck("WebRTC Leak", "yellow", "Possible leak", "Network", 1)
            return SecurityCheck("WebRTC Leak", "green", "Protected", "Network", 1)
        except Exception:
            return SecurityCheck("WebRTC Leak", "yellow", "Unable to check", "Network", 2)

    def check_public_ip(self) -> SecurityCheck:
        try:
            import urllib.request
            req = urllib.request.Request(
                "https://ifconfig.me", headers={"User-Agent": "curl/7.88"}
            )
            with urllib.request.urlopen(req, timeout=5) as resp:
                ip = resp.read().decode().strip()
            return SecurityCheck("Public IP", "yellow", ip, "Network", 2)
        except Exception:
            return SecurityCheck("Public IP", "yellow", "Unavailable", "Network", 2)

    def check_open_ports(self) -> SecurityCheck:
        try:
            out = self._run("ss -tlnp 2>/dev/null")
            if out is None:
                return SecurityCheck("Open Ports", "yellow", "ss unavailable", "Network", 2)
            lines = [l for l in out.splitlines()[1:] if l.strip()]
            n = len(lines)
            detail = f"{n} listening"
            if n <= 3:
                return SecurityCheck("Open Ports", "green", detail, "Network", 2)
            if n <= 5:
                return SecurityCheck("Open Ports", "yellow", detail, "Network", 2)
            return SecurityCheck("Open Ports", "red", detail, "Network", 2)
        except Exception:
            return SecurityCheck("Open Ports", "yellow", "Error", "Network", 2)

    def check_active_connections(self) -> SecurityCheck:
        """Count active network connections."""
        try:
            out = self._run("ss -tn state established 2>/dev/null | wc -l")
            if out:
                count = int(out) - 1  # Subtract header line
                self.stats.active_connections = max(0, count)
                if count <= 5:
                    return SecurityCheck("Active Connections", "green", f"{count} established", "Network", 2)
                if count <= 15:
                    return SecurityCheck("Active Connections", "yellow", f"{count} established", "Network", 2)
                return SecurityCheck("Active Connections", "red", f"{count} established", "Network", 2)
            return SecurityCheck("Active Connections", "yellow", "Unknown", "Network", 2)
        except Exception:
            return SecurityCheck("Active Connections", "yellow", "Error", "Network", 2)

    def check_firewall(self) -> SecurityCheck:
        try:
            ufw = self._run("ufw status 2>/dev/null")
            if ufw and "active" in ufw.lower() and "inactive" not in ufw.lower():
                return SecurityCheck("Firewall", "green", "UFW Active", "Network", 2)
            iptables = self._run("iptables -L -n 2>/dev/null | wc -l")
            if iptables and int(iptables) > 8:
                return SecurityCheck("Firewall", "green", "iptables active", "Network", 2)
            return SecurityCheck("Firewall", "red", "No firewall", "Network", 1)
        except Exception:
            return SecurityCheck("Firewall", "yellow", "Error", "Network", 2)

    def check_bluetooth(self) -> SecurityCheck:
        """Check Bluetooth status."""
        try:
            # Check if Bluetooth is powered on
            bt_status = self._run("rfkill list bluetooth 2>/dev/null | grep -i 'soft blocked: no'")
            if bt_status:
                return SecurityCheck("Bluetooth", "yellow", "Enabled", "Privacy", 1)
            return SecurityCheck("Bluetooth", "green", "Disabled", "Privacy", 1)
        except Exception:
            return SecurityCheck("Bluetooth", "green", "N/A", "Privacy", 3)

    def check_mac_randomization(self) -> SecurityCheck:
        """Check if MAC address randomization is enabled."""
        try:
            # Check NetworkManager MAC randomization
            nm_conf = self._read("/etc/NetworkManager/NetworkManager.conf")
            if nm_conf and "wifi.scan-rand-mac-address=yes" in nm_conf:
                return SecurityCheck("MAC Randomization", "green", "Enabled (NM)", "Privacy", 2)
            
            # Check for macchanger
            macchanger = self._run("which macchanger 2>/dev/null")
            if macchanger:
                return SecurityCheck("MAC Randomization", "yellow", "Tool installed", "Privacy", 2)
            
            return SecurityCheck("MAC Randomization", "yellow", "Not configured", "Privacy", 2)
        except Exception:
            return SecurityCheck("MAC Randomization", "yellow", "Unknown", "Privacy", 2)

    def check_ssh(self) -> SecurityCheck:
        try:
            active = self._run("systemctl is-active ssh 2>/dev/null")
            if active == "active":
                return SecurityCheck("SSH", "yellow", "Running", "System", 2)
            return SecurityCheck("SSH", "green", "Stopped", "System", 2)
        except Exception:
            return SecurityCheck("SSH", "green", "N/A", "System", 3)

    def check_updates(self) -> SecurityCheck:
        try:
            out = self._run("apt list --upgradable 2>/dev/null | wc -l")
            if out:
                count = int(out) - 1
                if count <= 0:
                    return SecurityCheck("Updates", "green", "Up to date", "System", 2)
                if count <= 5:
                    return SecurityCheck("Updates", "yellow", f"{count} available", "System", 2)
                return SecurityCheck("Updates", "red", f"{count} available", "System", 1)
            return SecurityCheck("Updates", "yellow", "Unknown", "System", 2)
        except Exception:
            return SecurityCheck("Updates", "yellow", "Error", "System", 2)

    def check_auto_updates(self) -> SecurityCheck:
        """Check if automatic security updates are enabled."""
        try:
            apt_conf = self._read("/etc/apt/apt.conf.d/20auto-upgrades")
            if apt_conf and "APT::Periodic::Unattended-Upgrade" in apt_conf:
                return SecurityCheck("Auto-Updates", "green", "Enabled", "System", 2)
            return SecurityCheck("Auto-Updates", "yellow", "Disabled", "System", 2)
        except Exception:
            return SecurityCheck("Auto-Updates", "yellow", "Unknown", "System", 3)

    def check_disk_encryption(self) -> SecurityCheck:
        try:
            dmsetup = self._run("dmsetup status 2>/dev/null")
            if dmsetup and "crypt" in dmsetup:
                return SecurityCheck("Disk Encryption", "green", "LUKS detected", "System", 2)
            return SecurityCheck("Disk Encryption", "yellow", "Not encrypted", "System", 2)
        except Exception:
            return SecurityCheck("Disk Encryption", "yellow", "Unknown", "System", 3)

    def check_selinux(self) -> SecurityCheck:
        try:
            sestatus = self._run("getenforce 2>/dev/null")
            if sestatus and sestatus.lower() == "enforcing":
                return SecurityCheck("SELinux/AppArmor", "green", "Enforcing", "System", 2)
            apparmor = self._run("aa-status 2>/dev/null | grep -c profiles")
            if apparmor and int(apparmor) > 0:
                return SecurityCheck("SELinux/AppArmor", "green", f"{apparmor} profiles", "System", 2)
            return SecurityCheck("SELinux/AppArmor", "yellow", "Not active", "System", 3)
        except Exception:
            return SecurityCheck("SELinux/AppArmor", "yellow", "Unknown", "System", 3)

    def check_suspicious_processes(self) -> SecurityCheck:
        """Check for commonly suspicious process names."""
        try:
            suspicious = ['keylogger', 'rootkit', 'backdoor', 'rat', 'trojan']
            processes = self._run("ps aux | awk '{print $11}' | sort -u")
            if processes:
                found = []
                for proc in processes.lower().split('\n'):
                    for sus in suspicious:
                        if sus in proc:
                            found.append(proc)
                if found:
                    return SecurityCheck("Suspicious Processes", "red", f"{len(found)} found", "System", 1)
            return SecurityCheck("Suspicious Processes", "green", "None detected", "System", 2)
        except Exception:
            return SecurityCheck("Suspicious Processes", "yellow", "Unable to check", "System", 3)

    def check_hostname(self) -> SecurityCheck:
        try:
            hostname = socket.gethostname()
            if KNOWN_DEFAULT_HOSTNAMES.match(hostname):
                return SecurityCheck("Hostname", "yellow", "Default name", "Privacy", 2)
            if IDENTIFIABLE_HOSTNAME.search(hostname):
                return SecurityCheck("Hostname", "red", "Identifiable", "Privacy", 1)
            return SecurityCheck("Hostname", "green", "Custom", "Privacy", 2)
        except Exception:
            return SecurityCheck("Hostname", "yellow", "Error", "Privacy", 2)

    def check_history(self) -> SecurityCheck:
        try:
            home = os.path.expanduser("~")
            bash_history = os.path.join(home, ".bash_history")
            if os.path.isfile(bash_history):
                size = os.path.getsize(bash_history)
                if size > 10000:
                    return SecurityCheck("History", "yellow", "Not cleared", "Privacy", 2)
            return SecurityCheck("History", "green", "Cleared/small", "Privacy", 2)
        except Exception:
            return SecurityCheck("History", "yellow", "Error", "Privacy", 3)

    def check_webcam(self) -> SecurityCheck:
        try:
            lsmod = self._run("lsmod | grep -E 'uvcvideo|videodev'")
            if lsmod:
                fuser = self._run("fuser /dev/video0 2>/dev/null")
                if fuser:
                    return SecurityCheck("Webcam", "yellow", "In use", "Privacy", 2)
                return SecurityCheck("Webcam", "green", "Not in use", "Privacy", 2)
            return SecurityCheck("Webcam", "green", "Driver unloaded", "Privacy", 2)
        except Exception:
            return SecurityCheck("Webcam", "yellow", "Error", "Privacy", 3)

    def check_screen_sharing(self) -> SecurityCheck:
        """Check if screen sharing/recording apps are running."""
        try:
            sharing_procs = self._run("ps aux | grep -E 'vnc|x11vnc|teamviewer|anydesk|zoom|obs' | grep -v grep | wc -l")
            if sharing_procs and int(sharing_procs) > 0:
                return SecurityCheck("Screen Sharing", "yellow", f"{sharing_procs} apps active", "Privacy", 1)
            return SecurityCheck("Screen Sharing", "green", "None active", "Privacy", 2)
        except Exception:
            return SecurityCheck("Screen Sharing", "yellow", "Unable to check", "Privacy", 3)

    def check_browser_privacy(self) -> SecurityCheck:
        try:
            home = os.path.expanduser("~")
            firefox = os.path.join(home, ".mozilla/firefox")
            chrome = os.path.join(home, ".config/google-chrome")
            chromium = os.path.join(home, ".config/chromium")
            
            browsers_found = 0
            if os.path.isdir(firefox):
                browsers_found += 1
            if os.path.isdir(chrome):
                browsers_found += 1
            if os.path.isdir(chromium):
                browsers_found += 1
            
            if browsers_found == 0:
                return SecurityCheck("Browser Data", "green", "No profiles", "Privacy", 3)
            if browsers_found <= 1:
                return SecurityCheck("Browser Data", "yellow", f"{browsers_found} browser", "Privacy", 3)
            return SecurityCheck("Browser Data", "yellow", f"{browsers_found} browsers", "Privacy", 3)
        except Exception:
            return SecurityCheck("Browser Data", "yellow", "Error", "Privacy", 3)

    def check_geolocation(self) -> SecurityCheck:
        try:
            geoclue = self._run("systemctl is-active geoclue.service 2>/dev/null")
            if geoclue == "active":
                return SecurityCheck("Geolocation", "yellow", "Service active", "Privacy", 2)
            return SecurityCheck("Geolocation", "green", "Disabled", "Privacy", 2)
        except Exception:
            return SecurityCheck("Geolocation", "green", "N/A", "Privacy", 3)

    def check_clipboard_monitor(self) -> SecurityCheck:
        """Check for clipboard monitoring applications."""
        try:
            clipboard_procs = self._run("ps aux | grep -E 'clipman|clipboard|parcellite' | grep -v grep | wc -l")
            if clipboard_procs and int(clipboard_procs) > 0:
                return SecurityCheck("Clipboard Monitor", "yellow", "Active", "Privacy", 2)
            return SecurityCheck("Clipboard Monitor", "green", "None active", "Privacy", 3)
        except Exception:
            return SecurityCheck("Clipboard Monitor", "green", "N/A", "Privacy", 3)

    def run_local_checks(self) -> List[SecurityCheck]:
        return [
            # Network - Priority 1 (Critical)
            self.check_vpn(),
            self.check_tor(),
            self.check_dns(),
            self.check_webrtc_leak(),
            self.check_firewall(),
            # Network - Priority 2 (Important)
            self.check_open_ports(),
            self.check_active_connections(),
            # System - Priority 1
            self.check_updates(),
            self.check_suspicious_processes(),
            # System - Priority 2
            self.check_ssh(),
            self.check_auto_updates(),
            self.check_disk_encryption(),
            self.check_selinux(),
            # Privacy - Priority 1
            self.check_bluetooth(),
            self.check_screen_sharing(),
            # Privacy - Priority 2
            self.check_mac_randomization(),
            self.check_hostname(),
            self.check_history(),
            self.check_webcam(),
            self.check_geolocation(),
            self.check_clipboard_monitor(),
            self.check_browser_privacy(),
        ]

    def run_network_checks(self) -> List[SecurityCheck]:
        return [self.check_public_ip()]

    def calculate_score(self) -> int:
        if not self.checks:
            return 0
        weights = {"green": 100, "yellow": 50, "red": 0}
        
        # Priority weighting: priority 1 = 2x weight, priority 2 = 1.5x, priority 3 = 1x
        total_weighted = 0
        total_weight = 0
        
        for check in self.checks:
            weight_multiplier = {1: 2.0, 2: 1.5, 3: 1.0}.get(check.priority, 1.0)
            check_score = weights.get(check.status, 0)
            total_weighted += check_score * weight_multiplier
            total_weight += 100 * weight_multiplier
        
        return round(total_weighted / total_weight * 100) if total_weight > 0 else 0

    def calculate_stats(self):
        """Calculate comprehensive statistics."""
        self.stats.total_checks = len(self.checks)
        self.stats.green_count = sum(1 for c in self.checks if c.status == "green")
        self.stats.yellow_count = sum(1 for c in self.checks if c.status == "yellow")
        self.stats.red_count = sum(1 for c in self.checks if c.status == "red")
        
        # Threat level
        score = self.score
        if score >= 80:
            self.stats.threat_level = "SECURE"
        elif score >= 50:
            self.stats.threat_level = "CAUTION"
        else:
            self.stats.threat_level = "COMPROMISED"
        
        # VPN uptime
        if self.vpn_start_time:
            uptime_seconds = int(time.time() - self.vpn_start_time)
            hours = uptime_seconds // 3600
            minutes = (uptime_seconds % 3600) // 60
            if hours > 0:
                self.stats.vpn_uptime = f"{hours}h {minutes}m"
            else:
                self.stats.vpn_uptime = f"{minutes}m"
        else:
            self.stats.vpn_uptime = "N/A"

    def get_weakest_category(self) -> str:
        if not self.checks:
            return "None"
        
        sections = {}
        for check in self.checks:
            if check.section not in sections:
                sections[check.section] = []
            sections[check.section].append(check.status)
        
        worst_section = None
        worst_score = 101
        weights = {"green": 100, "yellow": 50, "red": 0}
        
        for section, statuses in sections.items():
            avg = sum(weights.get(s, 0) for s in statuses) / len(statuses)
            if avg < worst_score:
                worst_score = avg
                worst_section = section
        
        return worst_section or "None"


# ---------------------------------------------------------------------------
# Enhanced Cyberpunk Frame Renderer
# ---------------------------------------------------------------------------

class CyberpunkFrame:
    """Handles all Cairo drawing with advanced cyberpunk aesthetics."""
    
    CORNER_CUT = 18
    PADDING = 14
    LINE_HEIGHT = 20
    HEADER_FONT_SIZE = 15
    BODY_FONT_SIZE = 11.5
    SCORE_FONT_SIZE = 42
    COMPACT_WIDTH = 280
    COMPACT_HEIGHT = 90  # Reduced height for horizontal layout
    EXPANDED_WIDTH = 320
    
    def __init__(self):
        self.width = self.EXPANDED_WIDTH
        self._cached_height = 600
        self.scan_line_offset = 0  # For animated scan effect
    
    def measure_height(self, checks: List[SecurityCheck], expanded: bool = True) -> int:
        """Calculate total height needed."""
        if not expanded:
            return self.COMPACT_HEIGHT
        
        y = self.PADDING + 40  # header
        y += 70  # score area
        y += 30  # stats bar
        y += 10  # spacing
        
        sections_seen = set()
        for c in checks:
            if c.section not in sections_seen:
                sections_seen.add(c.section)
                y += 30  # section header
            y += self.LINE_HEIGHT
        
        y += 50  # footer + powered by
        y += self.PADDING
        self._cached_height = max(y, 200)
        return self._cached_height
    
    @property
    def height(self):
        return self._cached_height
    
    # -- drawing primitives -----------------------------------------------
    
    @staticmethod
    def _set_color(cr, color, alpha=1.0):
        cr.set_source_rgba(*color, alpha)
    
    def _draw_beveled_rect(self, cr, x, y, w, h, cut=None):
        """Draw rectangle with 45-degree cut corners."""
        if cut is None:
            cut = self.CORNER_CUT
        cr.new_path()
        cr.move_to(x + cut, y)
        cr.line_to(x + w - cut, y)
        cr.line_to(x + w, y + cut)
        cr.line_to(x + w, y + h - cut)
        cr.line_to(x + w - cut, y + h)
        cr.line_to(x + cut, y + h)
        cr.line_to(x, y + h - cut)
        cr.line_to(x, y + cut)
        cr.close_path()
    
    def _draw_hex_grid(self, cr, w, h):
        """Draw hexagonal grid background pattern."""
        hex_size = 20
        self._set_color(cr, COLORS["grid"], 0.08)
        cr.set_line_width(0.5)
        
        for y in range(0, h + hex_size, int(hex_size * 1.732)):
            for x in range(0, w + hex_size * 2, hex_size * 3):
                offset = (hex_size * 1.5) if (y // int(hex_size * 1.732)) % 2 else 0
                cx = x + offset
                cy = y
                
                # Draw hexagon
                for i in range(6):
                    angle = math.pi / 3 * i
                    px = cx + hex_size * 0.4 * math.cos(angle)
                    py = cy + hex_size * 0.4 * math.sin(angle)
                    if i == 0:
                        cr.move_to(px, py)
                    else:
                        cr.line_to(px, py)
                cr.close_path()
                cr.stroke()
    
    def _draw_scanlines(self, cr, w, h):
        """Draw horizontal scanline overlay."""
        self._set_color(cr, (0, 0, 0), 0.03)
        for sy in range(0, h, 3):
            cr.rectangle(0, sy, w, 1)
        cr.fill()
    
    def _draw_corner_lights(self, cr, x, y, w, h, cut):
        """Draw glowing accent dots at corners."""
        corners = [
            (x + cut/2, y + cut/2),          # Top-left
            (x + w - cut/2, y + cut/2),      # Top-right
            (x + cut/2, y + h - cut/2),      # Bottom-left
            (x + w - cut/2, y + h - cut/2),  # Bottom-right
        ]
        
        for cx, cy in corners:
            # Glow
            gradient = cairo.RadialGradient(cx, cy, 0, cx, cy, 8)
            gradient.add_color_stop_rgba(0, COLORS["accent"][0], COLORS["accent"][1], COLORS["accent"][2], 0.6)
            gradient.add_color_stop_rgba(1, COLORS["accent"][0], COLORS["accent"][1], COLORS["accent"][2], 0)
            cr.set_source(gradient)
            cr.arc(cx, cy, 8, 0, 2 * math.pi)
            cr.fill()
            
            # Core
            self._set_color(cr, COLORS["accent_bright"], 0.9)
            cr.arc(cx, cy, 2.5, 0, 2 * math.pi)
            cr.fill()
    
    def _draw_glow_frame(self, cr, x, y, w, h):
        """Draw beveled frame with 3-layer glow."""
        for i, alpha in enumerate([0.06, 0.12, 0.25]):
            offset = 3 - i
            self._draw_beveled_rect(cr, x - offset, y - offset,
                                    w + 2 * offset, h + 2 * offset)
            self._set_color(cr, COLORS["accent"], alpha)
            cr.set_line_width(2)
            cr.stroke()
        
        # main border
        self._draw_beveled_rect(cr, x, y, w, h)
        self._set_color(cr, COLORS["accent"], 0.7)
        cr.set_line_width(1.5)
        cr.stroke()
    
    def _draw_diamond(self, cr, cx, cy, size=4):
        """Draw a small diamond shape."""
        cr.new_path()
        cr.move_to(cx, cy - size)
        cr.line_to(cx + size, cy)
        cr.line_to(cx, cy + size)
        cr.line_to(cx - size, cy)
        cr.close_path()
        cr.fill()
    
    def _draw_pcb_divider(self, cr, x, y, w):
        """Draw PCB-trace style divider line."""
        self._set_color(cr, COLORS["accent"], 0.25)
        cr.set_line_width(1)
        mid = w / 2
        cr.move_to(x + 10, y)
        cr.line_to(x + mid - 20, y)
        cr.line_to(x + mid - 14, y - 4)
        cr.line_to(x + mid + 14, y - 4)
        cr.line_to(x + mid + 20, y)
        cr.line_to(x + w - 10, y)
        cr.stroke()
    
    def _draw_dot(self, cr, cx, cy, status, radius=4, priority=1):
        """Draw colored status dot with glow (enhanced for priority)."""
        color = STATUS_COLORS.get(status, COLORS["accent"])
        
        # Larger glow for priority 1 items
        glow_radius = radius + (5 if priority == 1 else 3)
        glow_alpha = 0.3 if priority == 1 else 0.2
        
        # glow
        self._set_color(cr, color, glow_alpha)
        cr.arc(cx, cy, glow_radius, 0, 2 * math.pi)
        cr.fill()
        
        # dot
        self._set_color(cr, color, 0.95 if priority == 1 else 0.9)
        cr.arc(cx, cy, radius, 0, 2 * math.pi)
        cr.fill()
        
        # Extra bright center for priority 1
        if priority == 1:
            self._set_color(cr, (1, 1, 1), 0.4)
            cr.arc(cx, cy, radius * 0.5, 0, 2 * math.pi)
            cr.fill()
    
    def _draw_progress_bar(self, cr, x, y, w, h, pct, color):
        """Draw progress bar with segments."""
        # background
        self._set_color(cr, COLORS["bg_dark"], 0.9)
        cr.rectangle(x, y, w, h)
        cr.fill()
        
        # border
        self._set_color(cr, COLORS["accent"], 0.4)
        cr.set_line_width(1)
        cr.rectangle(x, y, w, h)
        cr.stroke()
        
        # fill - solid style for compact mode
        fill_w = w * (pct / 100)
        
        # Gradient fill
        gradient = cairo.LinearGradient(x, y, x, y + h)
        gradient.add_color_stop_rgba(0, color[0], color[1], color[2], 0.9)
        gradient.add_color_stop_rgba(1, color[0], color[1], color[2], 0.7)
        cr.set_source(gradient)
        cr.rectangle(x, y, fill_w, h)
        cr.fill()
        
        # sheen
        self._set_color(cr, (1, 1, 1), 0.15)
        cr.rectangle(x, y, fill_w, h * 0.4)
        cr.fill()
    
    def _draw_stats_bar(self, cr, x, y, w, stats: HUDStats):
        """Draw compact stats summary bar."""
        bar_h = 20
        
        # Background
        self._set_color(cr, COLORS["bg_panel"], 0.5)
        cr.rectangle(x, y, w, bar_h)
        cr.fill()
        
        # Border
        self._set_color(cr, COLORS["accent"], 0.2)
        cr.set_line_width(1)
        cr.rectangle(x, y, w, bar_h)
        cr.stroke()
        
        # Content
        cr.set_font_size(9)
        text_y = y + 13
        
        # Left: Threat level
        threat_color = COLORS["green"]
        if stats.threat_level == "CAUTION":
            threat_color = COLORS["yellow"]
        elif stats.threat_level == "COMPROMISED":
            threat_color = COLORS["red"]
        
        self._set_color(cr, threat_color, 0.9)
        cr.move_to(x + 5, text_y)
        cr.show_text(stats.threat_level)
        
        # Middle: Status counts
        mid_x = x + w/2 - 40
        self._set_color(cr, COLORS["green"], 0.8)
        cr.move_to(mid_x, text_y)
        cr.show_text(f"{stats.green_count}")
        
        self._set_color(cr, COLORS["yellow"], 0.8)
        cr.move_to(mid_x + 20, text_y)
        cr.show_text(f"{stats.yellow_count}")
        
        self._set_color(cr, COLORS["red"], 0.8)
        cr.move_to(mid_x + 40, text_y)
        cr.show_text(f"{stats.red_count}")
        
        # Right: VPN uptime
        if stats.vpn_uptime != "N/A":
            self._set_color(cr, COLORS["text"], 0.7)
            uptime_text = f"VPN {stats.vpn_uptime}"
            extents = cr.text_extents(uptime_text)
            cr.move_to(x + w - extents.width - 5, text_y)
            cr.show_text(uptime_text)
    
    def _draw_digital_number(self, cr, x, y, number, size, color):
        """Draw number with digital display effect."""
        # Shadow/glow
        self._set_color(cr, color, 0.3)
        cr.move_to(x + 2, y + 2)
        cr.show_text(str(number))
        
        # Main number
        self._set_color(cr, color, 1.0)
        cr.move_to(x, y)
        cr.show_text(str(number))
    
    # -- main draw methods ------------------------------------------------
    
    def draw_compact(self, cr, score: int, stats: HUDStats, scan_time: str, checks: List[SecurityCheck]):
        """Draw compact view - actionable info showing what to fix."""
        w = self.COMPACT_WIDTH
        h = self.COMPACT_HEIGHT
        
        # clear
        cr.set_operator(cairo.OPERATOR_SOURCE)
        cr.set_source_rgba(0, 0, 0, 0)
        cr.paint()
        cr.set_operator(cairo.OPERATOR_OVER)
        
        # background fill
        self._draw_beveled_rect(cr, 2, 2, w - 4, h - 4)
        self._set_color(cr, COLORS["bg_dark"], 0.95)
        cr.fill()
        
        # hex grid
        cr.save()
        self._draw_beveled_rect(cr, 2, 2, w - 4, h - 4)
        cr.clip()
        self._draw_hex_grid(cr, w, h)
        cr.restore()
        
        # inner panel
        self._draw_beveled_rect(cr, 6, 6, w - 12, h - 12, cut=self.CORNER_CUT - 4)
        self._set_color(cr, COLORS["bg_panel"], 0.6)
        cr.fill()
        
        # glow frame
        self._draw_glow_frame(cr, 2, 2, w - 4, h - 4)
        
        # corner lights
        self._draw_corner_lights(cr, 2, 2, w - 4, h - 4, self.CORNER_CUT)
        
        # scanlines
        cr.save()
        self._draw_beveled_rect(cr, 2, 2, w - 4, h - 4)
        cr.clip()
        self._draw_scanlines(cr, w, h)
        cr.restore()
        
        # --- content - ACTIONABLE LAYOUT ---
        cr.select_font_face("monospace", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
        
        # Left side: Title
        pad = 15
        y = h / 2
        
        cr.set_font_size(10)
        self._set_color(cr, COLORS["accent"], 0.9)
        text = "TRACE"
        cr.move_to(pad, y - 8)
        cr.show_text(text)
        
        text2 = "LABS"
        cr.move_to(pad, y + 6)
        cr.show_text(text2)
        
        # Center: Score (nice and balanced)
        score_color = COLORS["green"]
        if score < 70:
            score_color = COLORS["yellow"]
        if score < 40:
            score_color = COLORS["red"]
        
        center_x = w / 2
        
        # Score number
        cr.set_font_size(32)
        score_text = str(score)
        extents = cr.text_extents(score_text)
        score_x = center_x - extents.width / 2 - 10
        score_y = h / 2 + 10
        self._draw_digital_number(cr, score_x, score_y, score, 32, score_color)
        
        # /100
        cr.set_font_size(11)
        self._set_color(cr, COLORS["text"], 0.5)
        cr.move_to(score_x + extents.width + 2, score_y)
        cr.show_text("/100")
        
        # Progress bar under score
        bar_y = score_y + 8
        bar_w = 100
        bar_h = 4
        bar_x = center_x - bar_w / 2
        self._draw_progress_bar(cr, bar_x, bar_y, bar_w, bar_h, score, score_color)
        
        # Right side: ACTIONABLE STATUS
        right_x = w - pad - 75
        
        # Threat level icon + name
        threat_color = COLORS["green"]
        threat_icon = "✓"
        if stats.threat_level == "CAUTION":
            threat_color = COLORS["yellow"]
            threat_icon = "⚠"
        elif stats.threat_level == "COMPROMISED":
            threat_color = COLORS["red"]
            threat_icon = "✖"
        
        cr.set_font_size(9)
        self._set_color(cr, threat_color, 0.9)
        threat_text = f"{threat_icon} {stats.threat_level}"
        cr.move_to(right_x, y - 10)
        cr.show_text(threat_text)
        
        # Find worst issue to display (Priority 1 red/yellow, or first red)
        worst_issue = None
        
        # First, look for Priority 1 reds
        for check in checks:
            if check.priority == 1 and check.status == "red":
                worst_issue = check
                break
        
        # If no P1 reds, look for P1 yellows
        if not worst_issue:
            for check in checks:
                if check.priority == 1 and check.status == "yellow":
                    worst_issue = check
                    break
        
        # If still nothing, just find first red
        if not worst_issue:
            for check in checks:
                if check.status == "red":
                    worst_issue = check
                    break
        
        # If still nothing, find first yellow
        if not worst_issue:
            for check in checks:
                if check.status == "yellow":
                    worst_issue = check
                    break
        
        # Display the issue (or "ALL GOOD")
        cr.set_font_size(8)
        if worst_issue:
            issue_color = STATUS_COLORS.get(worst_issue.status, COLORS["text"])
            self._set_color(cr, issue_color, 0.85)
            
            # Shorten name if needed
            issue_name = worst_issue.name
            if len(issue_name) > 12:
                issue_name = issue_name[:12]
            
            # Show name and brief detail
            cr.move_to(right_x, y + 2)
            cr.show_text(issue_name)
            
            # Detail on second line (shortened)
            detail = worst_issue.detail
            if len(detail) > 10:
                detail = detail[:10] + "..."
            
            cr.set_font_size(7)
            self._set_color(cr, issue_color, 0.7)
            cr.move_to(right_x, y + 11)
            cr.show_text(detail)
        else:
            # All good!
            self._set_color(cr, COLORS["green"], 0.85)
            cr.move_to(right_x, y + 6)
            cr.show_text("ALL SECURE")
        
        # Bottom: Powered by (very small)
        y = h - 8
        cr.set_font_size(6)
        self._set_color(cr, COLORS["accent"], 0.3)
        powered = f"powered by {POWERED_BY}"
        extents = cr.text_extents(powered)
        cr.move_to((w - extents.width) / 2, y)
        cr.show_text(powered)
    
    def draw_expanded(self, cr, checks: List[SecurityCheck], score: int, stats: HUDStats, scan_time: str):
        """Draw expanded view - comprehensive dashboard."""
        w = self.width
        h = self.height
        
        # clear
        cr.set_operator(cairo.OPERATOR_SOURCE)
        cr.set_source_rgba(0, 0, 0, 0)
        cr.paint()
        cr.set_operator(cairo.OPERATOR_OVER)
        
        # background fill
        self._draw_beveled_rect(cr, 2, 2, w - 4, h - 4)
        self._set_color(cr, COLORS["bg_dark"], 0.94)
        cr.fill()
        
        # hex grid
        cr.save()
        self._draw_beveled_rect(cr, 2, 2, w - 4, h - 4)
        cr.clip()
        self._draw_hex_grid(cr, w, h)
        cr.restore()
        
        # inner panel
        self._draw_beveled_rect(cr, 6, 6, w - 12, h - 12, cut=self.CORNER_CUT - 4)
        self._set_color(cr, COLORS["bg_panel"], 0.6)
        cr.fill()
        
        # glow frame
        self._draw_glow_frame(cr, 2, 2, w - 4, h - 4)
        
        # corner lights
        self._draw_corner_lights(cr, 2, 2, w - 4, h - 4, self.CORNER_CUT)
        
        # scanlines
        cr.save()
        self._draw_beveled_rect(cr, 2, 2, w - 4, h - 4)
        cr.clip()
        self._draw_scanlines(cr, w, h)
        cr.restore()
        
        # --- content ---
        cr.select_font_face("monospace", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
        pad = self.PADDING
        y = pad
        
        # header: TRACE LABS
        cr.set_font_size(self.HEADER_FONT_SIZE)
        self._set_color(cr, COLORS["accent"], 0.9)
        text = "TRACE LABS"
        extents = cr.text_extents(text)
        tx = (w - extents.width) / 2
        y += 18
        cr.move_to(tx, y)
        cr.show_text(text)
        
        # decorative line + diamonds
        y += 8
        self._set_color(cr, COLORS["accent"], 0.4)
        cr.set_line_width(1)
        cr.move_to(pad + 10, y)
        cr.line_to(w / 2 - 12, y)
        cr.stroke()
        cr.move_to(w / 2 + 12, y)
        cr.line_to(w - pad - 10, y)
        cr.stroke()
        self._set_color(cr, COLORS["accent"], 0.6)
        self._draw_diamond(cr, w / 2, y, 5)
        
        y += 12
        
        # --- score ---
        score_color = COLORS["green"]
        if score < 70:
            score_color = COLORS["yellow"]
        if score < 40:
            score_color = COLORS["red"]
        
        cr.set_font_size(self.SCORE_FONT_SIZE)
        score_text = str(score)
        extents = cr.text_extents(score_text)
        sx = (w - extents.width) / 2
        y += 42
        self._draw_digital_number(cr, sx, y, score, self.SCORE_FONT_SIZE, score_color)
        
        # "/100" subtitle
        cr.set_font_size(14)
        self._set_color(cr, COLORS["text"], 0.5)
        sub = "/100"
        extents_sub = cr.text_extents(sub)
        cr.move_to(sx + extents.width + 4, y)
        cr.show_text(sub)
        
        y += 12
        
        # progress bar
        bar_w = w - 2 * pad - 30
        bar_h = 8
        bar_x = pad + 15
        self._draw_progress_bar(cr, bar_x, y, bar_w, bar_h, score, score_color)
        
        y += 16
        
        # Stats bar
        stats_w = w - 2 * pad
        self._draw_stats_bar(cr, pad, y, stats_w, stats)
        
        y += 30
        
        # --- checks by section ---
        cr.set_font_size(self.BODY_FONT_SIZE)
        sections_seen = set()
        content_width = w - 2 * pad
        
        for check in checks:
            if check.section not in sections_seen:
                sections_seen.add(check.section)
                y += 8
                self._draw_pcb_divider(cr, pad, y, content_width)
                y += 14
                # section label
                cr.set_font_size(10)
                self._set_color(cr, COLORS["accent"], 0.6)
                section_label = f"// {check.section.upper()}"
                cr.move_to(pad + 8, y)
                cr.show_text(section_label)
                y += 10
                cr.set_font_size(self.BODY_FONT_SIZE)
            
            # draw check item
            dot_x = pad + 10
            dot_y = y + 6
            self._draw_dot(cr, dot_x, dot_y, check.status, radius=3.5, priority=check.priority)
            
            # name (brighter for priority 1)
            name_x = dot_x + 12
            text_alpha = 0.95 if check.priority == 1 else 0.85
            self._set_color(cr, COLORS["text"], text_alpha)
            cr.move_to(name_x, y + 10)
            cr.show_text(check.name)
            
            # detail (right-aligned with dot fill)
            detail = check.detail
            extents = cr.text_extents(detail)
            max_detail_w = w - pad - 8
            detail_x = max_detail_w - extents.width
            
            # dot fill between name and detail
            name_ext = cr.text_extents(check.name)
            fill_start = name_x + name_ext.width + 6
            fill_end = detail_x - 6
            if fill_end > fill_start + 10:
                self._set_color(cr, COLORS["dim"], 0.3)
                dots = ""
                dot_ext = cr.text_extents(".")
                ndots = int((fill_end - fill_start) / (dot_ext.width + 1.5))
                dots = " ".join(["." for _ in range(min(ndots, 30))])
                cr.move_to(fill_start, y + 10)
                cr.show_text(dots)
            
            # detail text
            detail_color = STATUS_COLORS.get(check.status, COLORS["text"])
            self._set_color(cr, detail_color, 0.85 if check.priority == 1 else 0.75)
            cr.move_to(detail_x, y + 10)
            cr.show_text(detail)
            
            y += self.LINE_HEIGHT
        
        # --- footer ---
        y += 10
        self._set_color(cr, COLORS["accent"], 0.2)
        cr.set_line_width(1)
        cr.move_to(pad + 20, y)
        cr.line_to(w - pad - 20, y)
        cr.stroke()
        
        y += 14
        cr.set_font_size(9)
        self._set_color(cr, COLORS["dim"], 0.7)
        ts_text = f"LAST SCAN: {scan_time}" if scan_time else "SCANNING..."
        extents = cr.text_extents(ts_text)
        cr.move_to((w - extents.width) / 2, y)
        cr.show_text(ts_text)
        
        # Connections count
        if stats.active_connections > 0:
            y += 10
            cr.set_font_size(8)
            self._set_color(cr, COLORS["text"], 0.5)
            conn_text = f"{stats.active_connections} active connections"
            extents = cr.text_extents(conn_text)
            cr.move_to((w - extents.width) / 2, y)
            cr.show_text(conn_text)
        
        # Powered by HowsMyPrivacy
        y += 12
        cr.set_font_size(8)
        self._set_color(cr, COLORS["accent"], 0.4)
        powered_text = f"powered by {POWERED_BY}"
        extents = cr.text_extents(powered_text)
        cr.move_to((w - extents.width) / 2, y)
        cr.show_text(powered_text)
        
        # Click to collapse hint
        y += 10
        cr.set_font_size(7)
        self._set_color(cr, COLORS["dim"], 0.5)
        hint = "click:collapse • ctrl+drag:move • right:quit"
        extents = cr.text_extents(hint)
        cr.move_to((w - extents.width) / 2, y)
        cr.show_text(hint)


# ---------------------------------------------------------------------------
# GTK4 Window
# ---------------------------------------------------------------------------

class TraceLabsHUD(Gtk.ApplicationWindow):
    """Main HUD window with compact/expanded modes."""
    
    def __init__(self, app):
        super().__init__(application=app, title="Trace Labs SEC-HUD")
        
        self.scanner = SecurityScanner()
        self.frame = CyberpunkFrame()
        self.expanded = False
        
        # window properties
        self.set_decorated(False)
        
        # sizing
        self.set_default_size(self.frame.COMPACT_WIDTH, self.frame.COMPACT_HEIGHT)
        
        # drawing area
        self.darea = Gtk.DrawingArea()
        self.darea.set_draw_func(self._on_draw)
        self.set_child(self.darea)
        
        # Mouse controls
        # Left-click to toggle
        left_click = Gtk.GestureClick.new()
        left_click.set_button(1)
        left_click.connect("pressed", self._on_left_click)
        self.add_controller(left_click)
        
        # Ctrl+Left-drag OR Middle-drag to move window
        drag_gesture = Gtk.GestureDrag.new()
        drag_gesture.set_button(0)  # Any button
        drag_gesture.connect("drag-begin", self._on_drag_begin)
        self.add_controller(drag_gesture)
        
        # Right-click to quit
        right_click = Gtk.GestureClick.new()
        right_click.set_button(3)
        right_click.connect("pressed", self._on_right_click)
        self.add_controller(right_click)
        
        # initial scan
        self._run_scan()
        
        # auto-refresh every 60s
        GLib.timeout_add_seconds(60, self._on_refresh)
    
    def _on_left_click(self, gesture, n_press, x, y):
        """Left-click to toggle expand/collapse."""
        self.expanded = not self.expanded
        self._update_size()
        self.darea.queue_draw()
    
    def _on_drag_begin(self, gesture, start_x, start_y):
        """Ctrl+Left-drag OR Middle-drag to move window."""
        event = gesture.get_current_event()
        if not event:
            return
        
        # Get button and modifiers
        button = gesture.get_current_button()
        state = event.get_modifier_state()
        
        # Allow middle-click (button 2) OR ctrl+left-click (button 1 with ctrl)
        should_move = False
        if button == 2:  # Middle button
            should_move = True
        elif button == 1 and (state & Gdk.ModifierType.CONTROL_MASK):  # Ctrl+Left
            should_move = True
        
        if not should_move:
            return
        
        # Start window move
        native = self.get_native()
        if native:
            surface = native.get_surface()
            if surface and hasattr(surface, 'begin_move'):
                device = gesture.get_device()
                try:
                    # Get root coordinates for move
                    root_x, root_y = event.get_root_coords() if hasattr(event, 'get_root_coords') else (start_x, start_y)
                    surface.begin_move(device, button, root_x, root_y, event.get_time())
                except:
                    pass
    
    def _on_right_click(self, gesture, n_press, x, y):
        """Right-click to quit."""
        self.get_application().quit()
    
    def _on_draw(self, area, cr, width, height, user_data=None):
        """Draw callback."""
        if self.expanded:
            self.frame.draw_expanded(cr, self.scanner.checks, self.scanner.score, 
                                    self.scanner.stats, self.scanner.scan_time)
        else:
            self.frame.draw_compact(cr, self.scanner.score, self.scanner.stats, 
                                   self.scanner.scan_time, self.scanner.checks)
    
    def _on_refresh(self):
        """Refresh timer."""
        self._run_scan()
        return True
    
    def _run_scan(self):
        """Run security scan."""
        self.scanner.checks = self.scanner.run_local_checks()
        self.scanner.score = self.scanner.calculate_score()
        self.scanner.calculate_stats()
        self.scanner.scan_time = time.strftime("%H:%M:%S")
        self._update_size()
        self.darea.queue_draw()
        
        # network checks in background
        thread = threading.Thread(target=self._run_network_thread, daemon=True)
        thread.start()
    
    def _run_network_thread(self):
        """Background network checks."""
        net_checks = self.scanner.run_network_checks()
        GLib.idle_add(self._merge_network_checks, net_checks)
    
    def _merge_network_checks(self, net_checks):
        """Merge network results."""
        insert_idx = 0
        for i, c in enumerate(self.scanner.checks):
            if c.section == "Network":
                insert_idx = i + 1
        for nc in net_checks:
            self.scanner.checks.insert(insert_idx, nc)
            insert_idx += 1
        self.scanner.score = self.scanner.calculate_score()
        self.scanner.calculate_stats()
        self._update_size()
        self.darea.queue_draw()
        return False
    
    def _update_size(self):
        """Update window size based on view mode."""
        if self.expanded:
            h = self.frame.measure_height(self.scanner.checks, expanded=True)
            w = self.frame.EXPANDED_WIDTH
        else:
            w = self.frame.COMPACT_WIDTH
            h = self.frame.COMPACT_HEIGHT
        
        self.set_default_size(w, h)
        self.darea.set_size_request(w, h)


# ---------------------------------------------------------------------------
# Application
# ---------------------------------------------------------------------------

class TraceLabsApp(Gtk.Application):
    """GTK4 Application."""
    
    def __init__(self):
        super().__init__(application_id="org.tracelabs.sechud")
    
    def do_activate(self):
        """Create and show window."""
        win = TraceLabsHUD(self)
        win.present()


def main():
    app = TraceLabsApp()
    app.run(None)


if __name__ == "__main__":
    main()