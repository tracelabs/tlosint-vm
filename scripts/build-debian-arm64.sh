#!/bin/bash
# Build script for TLOSINT VM - Debian Trixie ARM64
# Runs inside the tlvm-debian-arm64-builder container on Ubuntu-24.04-arm runner
# Usage: ./scripts/build-debian-arm64.sh [--keep] [--zip]
set -eu

KEEP=false
ZIP=false
VERSION=${VERSION:-dev}
OUTDIR=images
LOCALE=en_US.UTF-8
TIMEZONE=Etc/UTC
USERNAME=osint
PASSWORD=osint
HOSTNAME=tlosint
SIZE=40GB

while [ $# -gt 0 ]; do
    case $1 in
        --keep) KEEP=true ;;
        --zip)  ZIP=true ;;
        *) echo "ERROR: Unknown option '$1'" >&2; exit 1 ;;
    esac
    shift
done

mkdir -p "$OUTDIR"

OUTPUT="$OUTDIR/tlosint-debian-arm64-${VERSION}"

echo "Building TLOSINT Debian ARM64 image: $OUTPUT.qcow2"
echo "  Version:  $VERSION"
echo "  Size:     $SIZE"
echo "  Locale:   $LOCALE"
echo "  Timezone: $TIMEZONE"

debos \
    --memory=4G \
    --scratchsize=8G \
    -t hostname:"$HOSTNAME" \
    -t imagename:"$OUTPUT" \
    -t keep:"$KEEP" \
    -t locale:"$LOCALE" \
    -t password:"$PASSWORD" \
    -t size:"$SIZE" \
    -t timezone:"$TIMEZONE" \
    -t username:"$USERNAME" \
    -t zip:"$ZIP" \
    tlosint-debian-arm64.yaml

echo ""
echo "Build complete: ${OUTPUT}.qcow2"
echo "Import into UTM, virt-manager, Proxmox, or any QEMU-based hypervisor."
