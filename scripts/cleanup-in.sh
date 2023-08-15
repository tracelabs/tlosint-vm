#!/bin/sh

set -eu

export DEBIAN_FRONTEND=noninteractive

apt-get autoremove -y --purge
rc_packages=$(dpkg --list | grep "^rc" | tr -s " " | cut -d " " -f 2)
apt-get purge -y $rc_packages
apt-get clean
