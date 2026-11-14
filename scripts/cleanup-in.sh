#!/bin/sh

set -eu

export DEBIAN_FRONTEND=noninteractive

apt-get autoremove -y --purge
rc_packages=$(dpkg --list | grep "^rc" | tr -s " " | cut -d " " -f 2 || true)
if [ -n "$rc_packages" ]; then
    # shellcheck disable=SC2086
    apt-get purge -y $rc_packages
fi
apt-get clean
