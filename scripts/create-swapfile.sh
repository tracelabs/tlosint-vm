#!/bin/sh

set -eu

for i in $(seq 1 5); do
    fallocate -v -l 1G /swapfile && break
    rm -f /swapfile    # probably useless, doesn't hurt either
    if [ $i -lt 5 ]; then
        echo "Retrying in 5 seconds..."
        sleep 5
    else
        echo "Aborting"
        exit 1
    fi
done
chmod 600 /swapfile
mkswap /swapfile
echo "/swapfile none swap defaults 0 0" >> /etc/fstab
