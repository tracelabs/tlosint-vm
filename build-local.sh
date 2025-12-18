#!/bin/bash
# Local build script for TL OSINT VM OVAs
# This script mirrors the GitHub Actions workflow but runs locally
# Usage: ./build-local.sh [virtualbox|vmware|both]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Default to building both formats
BUILD_TARGET="${1:-both}"

echo "=============================================="
echo "  TL OSINT VM Local Builder"
echo "=============================================="
echo "Build target: $BUILD_TARGET"
echo "Working directory: $SCRIPT_DIR"
echo ""

# Ensure scripts are executable
echo "[*] Setting script permissions..."
chmod +x scripts/tl/*.sh
chmod +x scripts/*.sh
chmod +x *.sh

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "[ERROR] Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if KVM is available (optional but recommended)
if [ -e /dev/kvm ]; then
    KVM_GROUP="--group-add $(stat -c '%g' /dev/kvm)"
    echo "[*] KVM detected, hardware acceleration will be used"
else
    KVM_GROUP=""
    echo "[WARN] KVM not available, build will be slower"
fi

# Create output directory
mkdir -p images

# Build the Docker image
echo ""
echo "[*] Building Docker image (tlvm-builder)..."
docker build -t tlvm-builder .

# Function to run the build
run_build() {
    local variant="$1"
    local format="$2"
    
    echo ""
    echo "=============================================="
    echo "  Building: variant=$variant format=$format"
    echo "=============================================="
    
    docker run --rm --interactive \
        --net host \
        --privileged \
        $KVM_GROUP \
        --volume "$(pwd)":/recipes \
        --volume "$(pwd)/images/":/images \
        --workdir /recipes \
        tlvm-builder \
        ./build.sh -v "$variant" -f "$format"
}

# Build based on target
case "$BUILD_TARGET" in
    virtualbox)
        run_build virtualbox ova
        ;;
    vmware)
        run_build vmware vmware
        ;;
    both)
        run_build virtualbox ova
        run_build vmware vmware
        ;;
    *)
        echo "[ERROR] Unknown build target: $BUILD_TARGET"
        echo "Usage: $0 [virtualbox|vmware|both]"
        exit 1
        ;;
esac

echo ""
echo "=============================================="
echo "  Build Complete!"
echo "=============================================="
echo "Output files are in: $SCRIPT_DIR/images/"
ls -lh images/ 2>/dev/null || echo "(no files yet)"

