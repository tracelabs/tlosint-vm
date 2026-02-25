# Trace Labs VM Updater

A Parrot OS-style update notification and GUI updater for the Trace Labs OSINT VM (Debian 13 Trixie).

When you log in, a desktop notification appears if updates are available. Click it to open the updater GUI, which shows live output as it updates your system packages and OSINT tools.

![Trace Labs VM Updater GUI](docs/screenshot-gui.png)

## Features

- 🔔 **Desktop notification on login** when updates are available
- 🖥️ **GTK3 GUI** with terminal-style live output
- 🔧 **Updates both** system packages (`apt`) and git-based OSINT tools
- ⏱️ **Systemd timer** checks for updates daily (and 5 min after boot)
- 🔒 **Polkit integration** for clean password prompts via `pkexec`
- 🗑️ **Uninstaller** included

## Requirements

- Debian 13 (Trixie) or compatible
- Python 3
- GTK3 (`python3-gi`, `gir1.2-gtk-3.0`)
- `libnotify-bin` for `notify-send`

The installer will handle missing dependencies automatically.

## Installation

```bash
git clone https://github.com/tracelabs/tl-vm-updater.git
cd tl-vm-updater
sudo ./install.sh
```

## Uninstall

```bash
sudo ./uninstall.sh
```

## Manual Testing

```bash
# Trigger update check immediately
sudo systemctl start tracelabs-update-check.service

# Test the GUI directly
python3 /usr/local/bin/tl-updater-gui

# Test the notification (fakes update availability)
sudo mkdir -p /var/cache/tracelabs
echo "5" | sudo tee /var/cache/tracelabs/update-available
/usr/local/bin/tl-notify-updates
```

## File Structure

```
tl-vm-updater/
├── bin/
│   ├── tl-check-updates        # Systemd service: checks apt for updates
│   ├── tl-notify-updates       # Autostart: fires desktop notification
│   ├── tl-updater-gui          # GTK3 GUI updater (Python)
│   └── tl-run-updates          # Root update script (runs via pkexec)
├── systemd/
│   ├── tracelabs-update-check.service
│   └── tracelabs-update-check.timer
├── desktop/
│   ├── tracelabs-updater-autostart.desktop   # XDG autostart (login trigger)
│   └── tracelabs-updater.desktop             # Desktop shortcut
├── polkit/
│   └── org.tracelabs.vm.update.policy        # pkexec auth policy
├── install.sh
├── uninstall.sh
└── README.md
```

## Adding OSINT Tools for Auto-Update

Clone your git-based tools into `/opt/tracelabs/tools/` and they will be automatically pulled during updates:

```bash
sudo mkdir -p /opt/tracelabs/tools
cd /opt/tracelabs/tools
sudo git clone https://github.com/some-osint/tool.git
```

## Notification Compatibility

The action button ("Open Updater") on the notification requires a notification daemon that supports actions (GNOME, KDE, dunst). If your desktop environment doesn't support action buttons, use the desktop shortcut to launch the updater manually.

## License

MIT — See [LICENSE](LICENSE)

## Contributing

This tool is maintained as part of the Trace Labs VM infrastructure. Issues and PRs welcome.
