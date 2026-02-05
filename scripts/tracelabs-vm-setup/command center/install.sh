#!/usr/bin/env bash
# Trace Labs SEC-HUD - Quick Installer
# Installs dependencies and sets up SEC-HUD

set -euo pipefail

INSTALL_DIR="${HOME}/.local/share/tracelabs-hud"
BIN_DIR="${HOME}/.local/bin"

echo "╔════════════════════════════════════════════╗"
echo "║   TRACE LABS // SEC-HUD INSTALLER          ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "⚠️  WARNING: Do not run this as root"
    echo "   Run as your normal user (installer will request sudo when needed)"
    exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
else
    OS="Unknown"
fi

echo "📋 System Information:"
echo "   OS: $OS"
echo "   User: $USER"
echo "   Home: $HOME"
echo ""

# Check dependencies
echo "🔍 Checking dependencies..."
MISSING_PKGS=()

# Check for package manager commands
if command -v apt &> /dev/null; then
    PKG_MANAGER="apt"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
else
    echo "❌ ERROR: No supported package manager found (apt/dnf/pacman)"
    exit 1
fi

# Check Python
if ! command -v python3 &> /dev/null; then
    MISSING_PKGS+=("python3")
fi

# Check GTK dependencies
if ! python3 -c "import gi" 2>/dev/null; then
    if [ "$PKG_MANAGER" = "apt" ]; then
        MISSING_PKGS+=("python3-gi")
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        MISSING_PKGS+=("python3-gobject")
    elif [ "$PKG_MANAGER" = "pacman" ]; then
        MISSING_PKGS+=("python-gobject")
    fi
fi

if ! python3 -c "import cairo" 2>/dev/null; then
    if [ "$PKG_MANAGER" = "apt" ]; then
        MISSING_PKGS+=("python3-gi-cairo")
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        MISSING_PKGS+=("python3-cairo")
    elif [ "$PKG_MANAGER" = "pacman" ]; then
        MISSING_PKGS+=("python-cairo")
    fi
fi

if ! python3 -c "import gi; gi.require_version('Gtk','4.0'); from gi.repository import Gtk" 2>/dev/null; then
    if [ "$PKG_MANAGER" = "apt" ]; then
        MISSING_PKGS+=("gir1.2-gtk-4.0")
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        MISSING_PKGS+=("gtk4")
    elif [ "$PKG_MANAGER" = "pacman" ]; then
        MISSING_PKGS+=("gtk4")
    fi
fi

# Install missing packages
if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    echo "📦 Missing packages: ${MISSING_PKGS[*]}"
    echo ""
    read -p "Install missing dependencies? [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        echo "🔧 Installing dependencies..."
        if [ "$PKG_MANAGER" = "apt" ]; then
            sudo apt update
            sudo apt install -y "${MISSING_PKGS[@]}"
        elif [ "$PKG_MANAGER" = "dnf" ]; then
            sudo dnf install -y "${MISSING_PKGS[@]}"
        elif [ "$PKG_MANAGER" = "pacman" ]; then
            sudo pacman -S --noconfirm "${MISSING_PKGS[@]}"
        fi
    else
        echo "❌ Installation cancelled"
        exit 1
    fi
else
    echo "✅ All dependencies satisfied"
fi

echo ""
echo "📁 Creating installation directory..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"

# Copy files
echo "📋 Installing SEC-HUD files..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$SCRIPT_DIR/tracelabs-hud.py" ]; then
    cp "$SCRIPT_DIR/tracelabs-hud.py" "$INSTALL_DIR/"
    echo "   ✓ tracelabs-hud.py"
else
    echo "   ❌ tracelabs-hud.py not found"
    exit 1
fi

if [ -f "$SCRIPT_DIR/tracelabs-hud.sh" ]; then
    cp "$SCRIPT_DIR/tracelabs-hud.sh" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/tracelabs-hud.sh"
    echo "   ✓ tracelabs-hud.sh"
else
    echo "   ❌ tracelabs-hud.sh not found"
    exit 1
fi

# Create symlink in bin
if [ ! -L "$BIN_DIR/tracelabs-hud" ]; then
    ln -s "$INSTALL_DIR/tracelabs-hud.sh" "$BIN_DIR/tracelabs-hud"
    echo "   ✓ Created launcher symlink"
fi

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo ""
    echo "⚠️  NOTE: $HOME/.local/bin is not in your PATH"
    echo "   Add this line to your ~/.bashrc or ~/.zshrc:"
    echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
fi

# Offer to create autostart entry (default YES)
echo ""
echo "════════════════════════════════════════════════"
echo "🚀 AUTOSTART SETUP"
echo "════════════════════════════════════════════════"
echo ""
echo "SEC-HUD can launch automatically when you log in."
echo "This keeps your security posture visible at all times."
echo ""
read -p "Enable autostart? [Y/n] " -n 1 -r
echo
echo "════════════════════════════════════════════════"

if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    AUTOSTART_DIR="$HOME/.config/autostart"
    mkdir -p "$AUTOSTART_DIR"
    
    cat > "$AUTOSTART_DIR/tracelabs-hud.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Trace Labs SEC-HUD
Comment=Security Posture Monitor - Always-on OSINT Security
Exec=$INSTALL_DIR/tracelabs-hud.sh
Terminal=false
StartupNotify=false
X-GNOME-Autostart-enabled=true
Categories=Utility;Security;
Icon=security-high
Hidden=false
NoDisplay=false
EOF
    
    chmod +x "$AUTOSTART_DIR/tracelabs-hud.desktop"
    echo ""
    echo "✅ Autostart ENABLED"
    echo "   SEC-HUD will launch automatically on login"
    echo ""
    echo "   Location: $AUTOSTART_DIR/tracelabs-hud.desktop"
    echo ""
    echo "   To disable later:"
    echo "   rm ~/.config/autostart/tracelabs-hud.desktop"
    AUTOSTART_ENABLED=true
else
    echo ""
    echo "⏩ Autostart DISABLED"
    echo ""
    echo "   To enable later:"
    echo "   ./setup-autostart.sh"
    echo ""
    echo "   Or manually:"
    echo "   mkdir -p ~/.config/autostart"
    echo "   cat > ~/.config/autostart/tracelabs-hud.desktop <<EOF"
    echo "   [Desktop Entry]"
    echo "   Type=Application"
    echo "   Name=Trace Labs SEC-HUD"
    echo "   Exec=$INSTALL_DIR/tracelabs-hud.sh"
    echo "   Terminal=false"
    echo "   X-GNOME-Autostart-enabled=true"
    echo "   EOF"
    AUTOSTART_ENABLED=false
fi

# Offer to create desktop shortcut
echo ""
read -p "Create desktop shortcut? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    DESKTOP_DIR="$HOME/Desktop"
    if [ ! -d "$DESKTOP_DIR" ]; then
        DESKTOP_DIR="$HOME/Escritorio"  # Spanish
    fi
    if [ ! -d "$DESKTOP_DIR" ]; then
        DESKTOP_DIR="$HOME/Bureau"  # French
    fi
    
    if [ -d "$DESKTOP_DIR" ]; then
        cat > "$DESKTOP_DIR/tracelabs-hud.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Trace Labs SEC-HUD
Comment=Security Posture Monitor
Exec=$INSTALL_DIR/tracelabs-hud.sh
Terminal=false
Icon=security-high
Categories=Utility;Security;
EOF
        chmod +x "$DESKTOP_DIR/tracelabs-hud.desktop"
        echo "✅ Desktop shortcut created"
    else
        echo "⚠️  Desktop directory not found"
    fi
fi

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║   ✅ INSTALLATION COMPLETE                 ║"
echo "╚════════════════════════════════════════════╝"
echo ""
echo "📦 Installed Components:"
echo "   • SEC-HUD Application"
echo "   • Launcher Script"
echo "   • Command-line Shortcut"
if [ "$AUTOSTART_ENABLED" = true ]; then
    echo "   • Autostart Entry (ENABLED)"
else
    echo "   • Autostart Entry (disabled)"
fi
echo ""
echo "🚀 Launch SEC-HUD:"
echo ""
echo "   tracelabs-hud"
echo ""
echo "   OR"
echo ""
echo "   $INSTALL_DIR/tracelabs-hud.sh"
echo ""
if [ "$AUTOSTART_ENABLED" = true ]; then
    echo "🔄 Autostart: ENABLED"
    echo "   SEC-HUD will launch automatically on next login"
    echo ""
    echo "   To test now without logging out:"
    echo "   tracelabs-hud"
    echo ""
else
    echo "💡 To enable autostart later:"
    echo "   ./setup-autostart.sh"
    echo ""
fi
echo "🖱️  Controls:"
echo "   • Left-click:      Toggle expand/collapse"
echo "   • Ctrl+Left-drag:  Move window"
echo "   • Right-click:     Quit"
echo ""
echo "🔗 Installed to: $INSTALL_DIR"
echo ""
echo "════════════════════════════════════════════════"
echo ""
echo "🎯 Ready for OSINT Operations!"
echo "   Stay Safe. Stay Anonymous. Find People."
echo ""
echo "════════════════════════════════════════════════"
echo ""