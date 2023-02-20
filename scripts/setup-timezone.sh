#!/bin/sh

set -eu

zone=$1

if ! [ -e /usr/share/zoneinfo/$zone ]; then
    echo "ERROR: invalid time zone '$zone'"
    exit 1
fi

echo "$zone" > /etc/timezone
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/$zone /etc/localtime

# Save settings in the debconf database
DEBIAN_FRONTEND=noninteractive \
DEBCONF_NONINTERACTIVE_SEEN=true \
    dpkg-reconfigure tzdata
