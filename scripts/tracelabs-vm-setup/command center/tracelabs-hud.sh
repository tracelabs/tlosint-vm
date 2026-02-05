#!/usr/bin/env bash
# Trace Labs SEC-HUD Launcher
# Checks dependencies and starts the security monitor

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "╔════════════════════════════════════════════╗"
echo "║   TRACE LABS // SEC-HUD                    ║"
echo "║   Security Posture Monitor                 ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Check for display server
if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
    echo "❌ ERROR: No display server detected"
    echo "   SEC-HUD requires a graphical environment"
    exit 1
fi

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ ERROR: python3 not found"
    echo ""
    echo "Install with:"
    echo "  sudo apt install python3"
    exit 1
fi

# Check Python GTK dependencies
echo "🔍 Checking dependencies..."
MISSING=()

python3 -c "import gi" 2>/dev/null || MISSING+=("python3-gi")
python3 -c "import cairo" 2>/dev/null || MISSING+=("python3-gi-cairo")

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "❌ ERROR: Missing Python dependencies: ${MISSING[*]}"
    echo ""
    echo "Install with:"
    echo "  sudo apt install python3-gi python3-gi-cairo gir1.2-gtk-4.0"
    exit 1
fi

# Check GTK 4.0
if ! python3 -c "import gi; gi.require_version('Gtk','4.0'); from gi.repository import Gtk" 2>/dev/null; then
    echo "❌ ERROR: GTK 4.0 not found"
    echo ""
    echo "Install with:"
    echo "  sudo apt install gir1.2-gtk-4.0"
    exit 1
fi

echo "✅ All dependencies satisfied"
echo ""
echo "🚀 Launching SEC-HUD..."
echo ""
echo "Controls:"
echo "  • Left-click:   Toggle expand/collapse"
echo "  • Right-click:  Drag to move"
echo "  • Middle-click: Quit"
echo ""

# Launch SEC-HUD
exec python3 "$SCRIPT_DIR/tracelabs-hud.py" "$@"