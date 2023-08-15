#!/bin/sh

set -e

# XXX Do it with kali-tweaks when it supports non-interactive mode
install /usr/lib/kali_tweaks/data/mount-shared-folders /usr/local/bin/mount-shared-folders
install /usr/lib/kali_tweaks/data/restart-vm-tools /usr/local/bin/restart-vm-tools
