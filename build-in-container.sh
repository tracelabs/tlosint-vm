#!/bin/bash
# checks for either Podman or Docker, then builds the container image and runs it
# normal args can be passed to the build.sh script, e.g. --no-cache
set -eu

IMAGE=tlvm-builder
OPTS=(
   --rm --interactive --tty --net host
    --privileged
    --group-add $(stat -c '%g' /dev/kvm)
    --volume $(pwd):/recipes -v $(pwd)/images/:/images --workdir /recipes
)


if [ -x /usr/bin/podman ]; then
    PODMAN=podman
    if [ $(id -u) -eq 0 ]; then
        OPTS+=(--user $(stat -c "%u:%g" .))
    fi
    OPTS+=(--log-driver none)    # we don't want stdout in the journal
elif [ -x /usr/bin/docker ]; then
    PODMAN=docker
    OPTS+=(--user $(stat -c "%u:%g" .))
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
