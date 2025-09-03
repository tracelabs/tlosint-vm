#!/bin/bash
# checks kvm availability and sets container options appropriately
# checks for either Podman or Docker, then builds the container image and runs it
# normal args can be passed to the build.sh script, e.g. --no-cache
set -eu

IMAGE=tlvm-builder
OPTS=(
   --rm --interactive --tty --net host
    --privileged
    --volume $(pwd):/recipes -v $(pwd)/images/:/images --workdir /recipes
)

# Check for KVM
if [[ -e /dev/kvm ]]; then
    KVM_GID=$(stat -c '%g' /dev/kvm)
    OPTS+=(--group-add "$KVM_GID")
    echo "KVM detected: container will use hardware acceleration."
else
    echo "WARNING: /dev/kvm not found. Falling back to software-emulated QEMU."
    echo "The build will continue as root inside the container."
    # Do not add --user, container defaults to root
fi

if [ -x /usr/bin/podman ]; then
    PODMAN=podman
    # Add --user only if KVM is available (and we can safely map host user)
    if [[ -e /dev/kvm ]] && [ $(id -u) -eq 0 ]; then
        OPTS+=(--user "$(stat -c "%u:%g" .)")
    fi
    OPTS+=(--log-driver none) # suppress stdout in the journal
elif [ -x /usr/bin/docker ]; then
    PODMAN=docker
    if [[ -e /dev/kvm ]]; then
        OPTS+=(--user "$(stat -c "%u:%g" .)")
    fi
else
    echo "ERROR: No container engine detected, aborting." >&2
    exit 1
fi

bold() { tput bold; echo "$@"; tput sgr0; }
vrun() { bold "$" "$@"; "$@"; }
vexec() { bold "$" "$@"; exec "$@"; }
# build docker image if it doesn't exist
if ! $PODMAN inspect --type image $IMAGE >/dev/null 2>&1; then
    vrun $PODMAN build -t $IMAGE .
    echo
fi
# run the build script inside a container
vexec $PODMAN run "${OPTS[@]}" $IMAGE ./build.sh "$@"
