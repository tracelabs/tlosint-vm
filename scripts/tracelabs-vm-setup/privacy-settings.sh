#!/usr/bin/env bash
if [ "$EUID" -ne 0 ]; then
  script_path=$([[ "$0" = /* ]] && echo "$0" || echo "$PWD/${0#./}")
  sudo "$script_path" || (
    echo 'Administrator privileges are required.'
    exit 1
  )
  exit 0
fi
export HOME="/home/${SUDO_USER:-${USER}}" # Keep `~` and `$HOME` for user not `/root`.


# ----------------------------------------------------------
# --------------------Clear bash history--------------------
# ----------------------------------------------------------
echo '--- Clear bash history'
rm -fv ~/.bash_history
sudo rm -fv /root/.bash_history
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Clear Zsh history---------------------
# ----------------------------------------------------------
echo '--- Clear Zsh history'
rm -fv ~/.zsh_history
sudo rm -fv /root/.zsh_history
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Clear tcsh history--------------------
# ----------------------------------------------------------
echo '--- Clear tcsh history'
rm -fv ~/.history
sudo rm -fv /root/.history
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Clear fish history--------------------
# ----------------------------------------------------------
echo '--- Clear fish history'
rm -fv ~/.local/share/fish/fish_history
sudo rm -fv /root/.local/share/fish/fish_history
rm -fv ~/.config/fish/fish_history
sudo rm -fv /root/.config/fish/fish_history
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Clear KornShell (ksh) history---------------
# ----------------------------------------------------------
echo '--- Clear KornShell (ksh) history'
rm -fv ~/.sh_history
sudo rm -fv /root/.sh_history
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Clear ash history---------------------
# ----------------------------------------------------------
echo '--- Clear ash history'
rm -fv ~/.ash_history
sudo rm -fv /root/.ash_history
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------------Clear crosh history--------------------
# ----------------------------------------------------------
echo '--- Clear crosh history'
rm -fv ~/.crosh_history
sudo rm -fv /root/.crosh_history
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------------Clear GNOME Web cache-------------------
# ----------------------------------------------------------
echo '--- Clear GNOME Web cache'
# Global installation
rm -rfv /.cache/epiphany/*
# Flatpak installation
rm -rfv ~/.var/app/org.gnome.Epiphany/cache/*
# Snap installation
rm -rfv ~/~/snap/epiphany/common/.cache/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Clear GNOME Web browsing history-------------
# ----------------------------------------------------------
echo '--- Clear GNOME Web browsing history'
# ephy-history.db: Global installation
rm -fv ~/.local/share/epiphany/ephy-history.db
# ephy-history.db: Flatpak installation
rm -fv ~/.var/app/org.gnome.Epiphany/data/epiphany/ephy-history.db
# ephy-history.db: Snap installation
rm -fv ~/snap/epiphany/*/.local/share/epiphany/ephy-history.db
# ephy-history.db-shm: Global installation
rm -fv ~/.local/share/epiphany/ephy-history.db-shm
# ephy-history.db-shm: Flatpak installation
rm -fv ~/.var/app/org.gnome.Epiphany/data/epiphany/ephy-history.db-shm
# ephy-history.db-shm: Snap installation
rm -fv ~/snap/epiphany/*/.local/share/epiphany/ephy-history.db-shm
# ephy-history.db-wal: Global installation
rm -fv ~/.local/share/epiphany/ephy-history.db-wal
# ephy-history.db-wal: Flatpak installation
rm -fv ~/.var/app/org.gnome.Epiphany/data/epiphany/ephy-history.db-wal
# ephy-history.db-wal: Snap installation
rm -fv ~/snap/epiphany/*/.local/share/epiphany/ephy-history.db-wal
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------------Clear GNOME Web cookies------------------
# ----------------------------------------------------------
echo '--- Clear GNOME Web cookies'
# cookies.sqlite: Global installation
rm -fv ~/.local/share/epiphany/cookies.sqlite
# cookies.sqlite: Flatpak installation
rm -fv ~/.var/app/org.gnome.Epiphany/data/epiphany/cookies.sqlite
# cookies.sqlite: Snap installation
rm -fv ~/snap/epiphany/*/.local/share/epiphany/cookies.sqlite
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------------Clear GNOME Web bookmarks-----------------
# ----------------------------------------------------------
echo '--- Clear GNOME Web bookmarks'
# bookmarks.gvdb: Global installation
rm -fv ~/.local/share/epiphany/bookmarks.gvdb
# bookmarks.gvdb: Flatpak installation
rm -fv ~/.var/app/org.gnome.Epiphany/data/epiphany/bookmarks.gvdb
# bookmarks.gvdb: Snap installation
rm -fv ~/snap/epiphany/*/.local/share/epiphany/bookmarks.gvdb
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------------Clear Firefox cache--------------------
# ----------------------------------------------------------
echo '--- Clear Firefox cache'
# Global installation
rm -rfv ~/.cache/mozilla/*
# Flatpak installation
rm -rfv ~/.var/app/org.mozilla.firefox/cache/*
# Snap installation
rm -rfv ~/snap/firefox/common/.cache/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------Clear Firefox crash reports----------------
# ----------------------------------------------------------
echo '--- Clear Firefox crash reports'
# Global installation
rm -fv ~/.mozilla/firefox/Crash\ Reports/*
# Flatpak installation
rm -rfv ~/.var/app/org.mozilla.firefox/.mozilla/firefox/Crash\ Reports/*
# Snap installation
rm -rfv ~/snap/firefox/common/.mozilla/firefox/Crash\ Reports/*
# Delete files matching pattern: "~/.mozilla/firefox/*/crashes/*"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.mozilla/firefox/*/crashes/*'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/crashes/*"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/crashes/*'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/snap/firefox/common/.mozilla/firefox/*/crashes/*"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/snap/firefox/common/.mozilla/firefox/*/crashes/*'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/.mozilla/firefox/*/crashes/events/*"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.mozilla/firefox/*/crashes/events/*'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/crashes/events/*"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/crashes/events/*'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/snap/firefox/common/.mozilla/firefox/*/crashes/events/*"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/snap/firefox/common/.mozilla/firefox/*/crashes/events/*'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------------Clear Firefox cookies-------------------
# ----------------------------------------------------------
echo '--- Clear Firefox cookies'
# Delete files matching pattern: "~/.mozilla/firefox/*/cookies.sqlite"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.mozilla/firefox/*/cookies.sqlite'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/cookies.sqlite"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/cookies.sqlite'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/snap/firefox/common/.mozilla/firefox/*/cookies.sqlite"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/snap/firefox/common/.mozilla/firefox/*/cookies.sqlite'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# ----------------------------------------------------------


# Clear Firefox browsing history (URLs, downloads, bookmarks, visits, etc.)
echo '--- Clear Firefox browsing history (URLs, downloads, bookmarks, visits, etc.)'
# Delete files matching pattern: "~/.mozilla/firefox/*/downloads.rdf"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.mozilla/firefox/*/downloads.rdf'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/downloads.rdf"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/downloads.rdf'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/snap/firefox/common/.mozilla/firefox/*/downloads.rdf"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/snap/firefox/common/.mozilla/firefox/*/downloads.rdf'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/.mozilla/firefox/*/downloads.sqlite"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.mozilla/firefox/*/downloads.sqlite'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/downloads.sqlite"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/downloads.sqlite'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/snap/firefox/common/.mozilla/firefox/*/downloads.sqlite"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/snap/firefox/common/.mozilla/firefox/*/downloads.sqlite'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/.mozilla/firefox/*/places.sqlite"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.mozilla/firefox/*/places.sqlite'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/places.sqlite"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/places.sqlite'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/snap/firefox/common/.mozilla/firefox/*/places.sqlite"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/snap/firefox/common/.mozilla/firefox/*/places.sqlite'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/.mozilla/firefox/*/favicons.sqlite"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.mozilla/firefox/*/favicons.sqlite'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/favicons.sqlite"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/favicons.sqlite'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/snap/firefox/common/.mozilla/firefox/*/favicons.sqlite"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/snap/firefox/common/.mozilla/firefox/*/favicons.sqlite'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------------Clear Firefox logins-------------------
# ----------------------------------------------------------
echo '--- Clear Firefox logins'
# Delete files matching pattern: "~/.mozilla/firefox/*/logins.json"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.mozilla/firefox/*/logins.json'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/logins.json"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/logins.json'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/snap/firefox/common/.mozilla/firefox/*/logins.json"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/snap/firefox/common/.mozilla/firefox/*/logins.json'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/.mozilla/firefox/*/logins-backup.json"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.mozilla/firefox/*/logins-backup.json'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/logins-backup.json"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/logins-backup.json'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/snap/firefox/common/.mozilla/firefox/*/logins-backup.json"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/snap/firefox/common/.mozilla/firefox/*/logins-backup.json'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/.mozilla/firefox/*/signons.sqlite"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.mozilla/firefox/*/signons.sqlite'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/signons.sqlite"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/signons.sqlite'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/snap/firefox/common/.mozilla/firefox/*/signons.sqlite"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/snap/firefox/common/.mozilla/firefox/*/signons.sqlite'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------Clear Firefox autocomplete history------------
# ----------------------------------------------------------
echo '--- Clear Firefox autocomplete history'
# Delete files matching pattern: "~/.mozilla/firefox/*/formhistory.sqlite"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.mozilla/firefox/*/formhistory.sqlite'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/formhistory.sqlite"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/formhistory.sqlite'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/snap/firefox/common/.mozilla/firefox/*/formhistory.sqlite"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/snap/firefox/common/.mozilla/firefox/*/formhistory.sqlite'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------Clear Firefox "Multi-Account Containers" data-------
# ----------------------------------------------------------
echo '--- Clear Firefox "Multi-Account Containers" data'
# Delete files matching pattern: "~/.mozilla/firefox/*/containers.json"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.mozilla/firefox/*/containers.json'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/containers.json"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/containers.json'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/snap/firefox/common/.mozilla/firefox/*/containers.json"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/snap/firefox/common/.mozilla/firefox/*/containers.json'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------Clear Firefox open tabs and windows data---------
# ----------------------------------------------------------
echo '--- Clear Firefox open tabs and windows data'
# Delete files matching pattern: "~/.mozilla/firefox/*/sessionstore.jsonlz4"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.mozilla/firefox/*/sessionstore.jsonlz4'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/sessionstore.jsonlz4"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/sessionstore.jsonlz4'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/snap/firefox/common/.mozilla/firefox/*/sessionstore.jsonlz4"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/snap/firefox/common/.mozilla/firefox/*/sessionstore.jsonlz4'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------------Clear Snap cache---------------------
# ----------------------------------------------------------
echo '--- Clear Snap cache'
sudo rm -rfv /var/lib/snapd/cache/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------------Remove old Snap packages-----------------
# ----------------------------------------------------------
echo '--- Remove old Snap packages'
if ! command -v 'snap' &> /dev/null; then
  echo 'Skipping because "snap" is not found.'
else
  snap list --all | while read -r name version rev tracking publisher notes; do
  if [[ $notes = *disabled* ]]; then
    sudo snap remove "$name" --revision="$rev";
  fi
done
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Remove orphaned Flatpak runtimes-------------
# ----------------------------------------------------------
echo '--- Remove orphaned Flatpak runtimes'
if ! command -v 'flatpak' &> /dev/null; then
  echo 'Skipping because "flatpak" is not found.'
else
  flatpak uninstall --unused --noninteractive
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------------Clear Flatpak cache--------------------
# ----------------------------------------------------------
echo '--- Clear Flatpak cache'
# Temporary cache
sudo rm -rfv /var/tmp/flatpak-cache-*
# New cache
rm -rfv ~/.cache/flatpak/system-cache/*
# Old cache
rm -rfv ~/.local/share/flatpak/system-cache/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------Clear obsolete APT packages----------------
# ----------------------------------------------------------
echo '--- Clear obsolete APT packages'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  sudo apt-get autoclean
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------Clear APT package file lists---------------
# ----------------------------------------------------------
echo '--- Clear APT package file lists'
sudo rm -rfv /var/lib/apt/lists/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------Clear orphaned APT package dependencies----------
# ----------------------------------------------------------
echo '--- Clear orphaned APT package dependencies'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  sudo apt-get -y autoremove --purge
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------Clear cache for APT packages---------------
# ----------------------------------------------------------
echo '--- Clear cache for APT packages'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  sudo apt-get clean
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Clear YUM/RPM data--------------------
# ----------------------------------------------------------
echo '--- Clear YUM/RPM data'
if ! command -v 'yum' &> /dev/null; then
  echo 'Skipping because "yum" is not found.'
else
  yum clean all --enablerepo='*'
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Clear DNF/RPM data--------------------
# ----------------------------------------------------------
echo '--- Clear DNF/RPM data'
if ! command -v 'dnf' &> /dev/null; then
  echo 'Skipping because "dnf" is not found.'
else
  dnf clean all --enablerepo='*'
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------------Clear user-specific cache-----------------
# ----------------------------------------------------------
echo '--- Clear user-specific cache'
rm -rfv ~/.cache/*
sudo rm -rfv root/.cache/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------------Clear system-wide cache------------------
# ----------------------------------------------------------
echo '--- Clear system-wide cache'
rm -rf /var/cache/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Clear Flatpak application cache--------------
# ----------------------------------------------------------
echo '--- Clear Flatpak application cache'
rm -rfv ~/.var/app/*/cache/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------Clear Snap application cache---------------
# ----------------------------------------------------------
echo '--- Clear Snap application cache'
rm -fv ~/snap/*/*/.cache/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Clear thumbnails (icon cache)---------------
# ----------------------------------------------------------
echo '--- Clear thumbnails (icon cache)'
rm -rfv ~/.thumbnails/*
rm -rfv ~/.cache/thumbnails/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------------------Empty trash------------------------
# ----------------------------------------------------------
echo '--- Empty trash'
# Empty global trash
rm -rfv ~/.local/share/Trash/*
sudo rm -rfv /root/.local/share/Trash/*
# Empty Snap trash
rm -rfv ~/snap/*/*/.local/share/Trash/*
# Empty Flatpak trash (apps may not choose to use Portal API)
rm -rfv ~/.var/app/*/data/Trash/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------Disable participation in Popularity Contest--------
# ----------------------------------------------------------
echo '--- Disable participation in Popularity Contest'
config_file='/etc/popularity-contest.conf'
if [ -f "$config_file" ]; then
  sudo sed -i '/PARTICIPATE/c\PARTICIPATE=no' "$config_file"
else
  echo "Skipping because configuration file at ($config_file) is not found. Is popcon installed?"
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------Remove Popularity Contest (`popcon`) package-------
# ----------------------------------------------------------
echo '--- Remove Popularity Contest (`popcon`) package'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  apt_package_name='popularity-contest'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "\"$apt_package_name\" is installed and will be uninstalled."
  sudo apt-get purge -y "$apt_package_name"
else
  echo "Skipping, no action needed, \"$apt_package_name\" is not installed."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -Remove daily cron entry for Popularity Contest (popcon)--
# ----------------------------------------------------------
echo '--- Remove daily cron entry for Popularity Contest (popcon)'
job_name='popularity-contest'
cronjob_path="/etc/cron.daily/$job_name"
if [[ -f "$cronjob_path" ]]; then
  if [[ -x "$cronjob_path" ]]; then
    sudo chmod -x "$cronjob_path"
    echo "Successfully disabled cronjob \"$job_name\"."
  else
    echo "Skipping, cronjob \"$job_name\" is already disabled."
  fi
else
  echo "Skipping, \"$job_name\" cronjob is not found."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------------Remove `reportbug` package----------------
# ----------------------------------------------------------
echo '--- Remove `reportbug` package'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  apt_package_name='reportbug'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "\"$apt_package_name\" is installed and will be uninstalled."
  sudo apt-get purge -y "$apt_package_name"
else
  echo "Skipping, no action needed, \"$apt_package_name\" is not installed."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------Remove Python modules for `reportbug`-----------
# ----------------------------------------------------------
echo '--- Remove Python modules for `reportbug`'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  apt_package_name='python3-reportbug'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "\"$apt_package_name\" is installed and will be uninstalled."
  sudo apt-get purge -y "$apt_package_name"
else
  echo "Skipping, no action needed, \"$apt_package_name\" is not installed."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----Remove UI for reportbug (`reportbug-gtk` package)-----
# ----------------------------------------------------------
echo '--- Remove UI for reportbug (`reportbug-gtk` package)'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  apt_package_name='reportbug-gtk'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "\"$apt_package_name\" is installed and will be uninstalled."
  sudo apt-get purge -y "$apt_package_name"
else
  echo "Skipping, no action needed, \"$apt_package_name\" is not installed."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------Enable dynamic First-Party Isolation (dFPI)--------
# ----------------------------------------------------------
echo '--- Enable dynamic First-Party Isolation (dFPI)'
pref_name='network.cookie.cookieBehavior'
pref_value='5'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------Enable Firefox network partitioning------------
# ----------------------------------------------------------
echo '--- Enable Firefox network partitioning'
pref_name='privacy.partition.network_state'
pref_value='true'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---Disable outdated Firefox First-Party Isolation (FPI)---
# ----------------------------------------------------------
echo '--- Disable outdated Firefox First-Party Isolation (FPI)'
pref_name='privacy.firstparty.isolate'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------Enable Firefox tracking protection------------
# ----------------------------------------------------------
echo '--- Enable Firefox tracking protection'
pref_name='privacy.trackingprotection.enabled'
pref_value='true'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# Enable Firefox anti-fingerprinting (may break some websites)
echo '--- Enable Firefox anti-fingerprinting (may break some websites)'
pref_name='privacy.resistFingerprinting'
pref_value='true'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# Disable WebRTC exposure of your private IP address in Firefox
echo '--- Disable WebRTC exposure of your private IP address in Firefox'
pref_name='media.peerconnection.ice.default_address_only'
pref_value='true'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------Minimize Firefox telemetry logging verbosity-------
# ----------------------------------------------------------
echo '--- Minimize Firefox telemetry logging verbosity'
pref_name='toolkit.telemetry.log.level'
pref_value='"Fatal"'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------Disable Firefox telemetry log output-----------
# ----------------------------------------------------------
echo '--- Disable Firefox telemetry log output'
pref_name='toolkit.telemetry.log.dump'
pref_value='"Fatal"'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------Disable pings to Firefox telemetry server---------
# ----------------------------------------------------------
echo '--- Disable pings to Firefox telemetry server'
pref_name='toolkit.telemetry.server'
pref_value='""'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Disable Firefox shutdown ping---------------
# ----------------------------------------------------------
echo '--- Disable Firefox shutdown ping'
pref_name='toolkit.telemetry.shutdownPingSender.enabled'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
pref_name='toolkit.telemetry.shutdownPingSender.enabledFirstSession'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
pref_name='toolkit.telemetry.firstShutdownPing.enabled'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Disable Firefox new profile ping-------------
# ----------------------------------------------------------
echo '--- Disable Firefox new profile ping'
pref_name='toolkit.telemetry.newProfilePing.enabled'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------Disable Firefox update ping----------------
# ----------------------------------------------------------
echo '--- Disable Firefox update ping'
pref_name='toolkit.telemetry.updatePing.enabled'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------------Disable Firefox prio ping-----------------
# ----------------------------------------------------------
echo '--- Disable Firefox prio ping'
pref_name='toolkit.telemetry.prioping.enabled'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# Disable collection of technical and interaction data in Firefox
echo '--- Disable collection of technical and interaction data in Firefox'
pref_name='datareporting.healthreport.uploadEnabled'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----Disable detailed telemetry collection in Firefox-----
# ----------------------------------------------------------
echo '--- Disable detailed telemetry collection in Firefox'
pref_name='toolkit.telemetry.enabled'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------Disable archiving of Firefox telemetry----------
# ----------------------------------------------------------
echo '--- Disable archiving of Firefox telemetry'
pref_name='toolkit.telemetry.archive.enabled'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------Disable Firefox unified telemetry-------------
# ----------------------------------------------------------
echo '--- Disable Firefox unified telemetry'
pref_name='toolkit.telemetry.unified'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Clear Firefox telemetry user ID--------------
# ----------------------------------------------------------
echo '--- Clear Firefox telemetry user ID'
pref_name='toolkit.telemetry.cachedClientID'
pref_value='""'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------Disable Firefox Pioneer study monitoring---------
# ----------------------------------------------------------
echo '--- Disable Firefox Pioneer study monitoring'
pref_name='toolkit.telemetry.pioneer-new-studies-available'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Clear Firefox pioneer program ID-------------
# ----------------------------------------------------------
echo '--- Clear Firefox pioneer program ID'
pref_name='toolkit.telemetry.pioneerId'
pref_value='""'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----Disable blocking of unstable plugins in Firefox------
# ----------------------------------------------------------
echo '--- Disable blocking of unstable plugins in Firefox'
pref_name='browser.safebrowsing.blockedURIs.enabled'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# Disable Firefox application reputation checks for downloads
echo '--- Disable Firefox application reputation checks for downloads'
pref_name='browser.safebrowsing.downloads.enabled'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------Disable Firefox malware protection------------
# ----------------------------------------------------------
echo '--- Disable Firefox malware protection'
pref_name='browser.safebrowsing.malware.enabled'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------Disable Firefox phishing protection------------
# ----------------------------------------------------------
echo '--- Disable Firefox phishing protection'
pref_name='browser.safebrowsing.phishing.enabled'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -Disable connection tests (breaks automatic Wi-Fi login)--
# ----------------------------------------------------------
echo '--- Disable connection tests (breaks automatic Wi-Fi login)'
pref_name='network.captive-portal-service.enabled'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# --Disable automatic Visual Studio Code extension updates--
# ----------------------------------------------------------
echo '--- Disable automatic Visual Studio Code extension updates'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'extensions.autoUpdate'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# Disable Visual Studio Code automatic extension update checks
echo '--- Disable Visual Studio Code automatic extension update checks'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'extensions.autoCheckUpdates'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# Disable automatic fetching of Microsoft recommendations in Visual Studio Code
echo '--- Disable automatic fetching of Microsoft recommendations in Visual Studio Code'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'extensions.showRecommendationsOnlyOnDemand'
target = json.loads('true')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# Disable synchronization of Visual Studio Code keybindings-
# ----------------------------------------------------------
echo '--- Disable synchronization of Visual Studio Code keybindings'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'settingsSync.keybindingsPerPlatform'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -Disable synchronization of Visual Studio Code extensions-
# ----------------------------------------------------------
echo '--- Disable synchronization of Visual Studio Code extensions'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'settingsSync.ignoredExtensions'
target = json.loads('["*"]')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# --Disable synchronization of Visual Studio Code settings--
# ----------------------------------------------------------
echo '--- Disable synchronization of Visual Studio Code settings'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'settingsSync.ignoredSettings'
target = json.loads('["*"]')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------Disable Visual Studio Code telemetry-----------
# ----------------------------------------------------------
echo '--- Disable Visual Studio Code telemetry'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'telemetry.telemetryLevel'
target = json.loads('"off"')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'telemetry.enableTelemetry'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'telemetry.enableCrashReporter'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# Disable online experiments by Microsoft in Visual Studio Code
echo '--- Disable online experiments by Microsoft in Visual Studio Code'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'workbench.enableExperiments'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# Disable Visual Studio Code automatic updates in favor of manual updates
echo '--- Disable Visual Studio Code automatic updates in favor of manual updates'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'update.mode'
target = json.loads('"none"')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'update.channel'
target = json.loads('"none"')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# Disable fetching release notes from Microsoft servers after an update
echo '--- Disable fetching release notes from Microsoft servers after an update'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'update.showReleaseNotes'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# Disable automatic fetching of remote repositories in Visual Studio Code
echo '--- Disable automatic fetching of remote repositories in Visual Studio Code'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'git.autofetch'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# Disable fetching package information from NPM and Bower in Visual Studio Code
echo '--- Disable fetching package information from NPM and Bower in Visual Studio Code'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'npm.fetchOnlinePackageInfo'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# Disable sending search queries to Microsoft in Visual Studio Code
echo '--- Disable sending search queries to Microsoft in Visual Studio Code'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'workbench.settings.enableNaturalLanguageSearch'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# Disable Visual Studio Code automatic type acquisition in TypeScript
echo '--- Disable Visual Studio Code automatic type acquisition in TypeScript'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'typescript.disableAutomaticTypeAcquisition'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------Disable Visual Studio Code Edit Sessions---------
# ----------------------------------------------------------
echo '--- Disable Visual Studio Code Edit Sessions'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'workbench.experimental.editSessions.enabled'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'workbench.experimental.editSessions.autoStore'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'workbench.editSessions.autoResume'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'workbench.editSessions.continueOn'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


echo 'Your privacy and security is now hardened 🎉💪\'
echo 'Press any key to exit.'
read -r -n 1 -s
