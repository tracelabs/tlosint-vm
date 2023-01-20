#!/bin/sh

set -eu

variant=$1

if dpkg -s kali-desktop-core 2>/dev/null | grep -q "ok installed"; then
    qemu="qemu-guest-agent spice-vdagent"
    virtualbox="virtualbox-guest-x11"
    vmware="open-vm-tools-desktop"
else
    qemu="qemu-guest-agent"
    virtualbox="virtualbox-guest-utils"
    vmware="open-vm-tools"
fi

generic=$(echo $qemu $virtualbox $vmware \
    | sed "s/ \+/\n/g" | LC_ALL=C sort -u \
    | awk 'ORS=" "' | sed "s/ *$//")

case $variant in
    qemu)       pkgs=$qemu ;;
    virtualbox) pkgs=$virtualbox ;;
    vmware)     pkgs=$vmware ;;
    generic)    pkgs=$generic ;;
    *)
        echo "ERROR: invalid variant '$variant'"
        exit 1
        ;;
esac

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y $pkgs
apt-get clean
