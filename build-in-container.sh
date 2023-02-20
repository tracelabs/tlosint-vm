#!/bin/bash

set -eu

IMAGE=ccxosint-builder
OPTS=(
    --rm --interactive --tty --net host
    --privileged
    --volume $(pwd):/recipes -v $(pwd)/images/:/images --workdir /recipes
    --workdir /recipes
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

if ! $PODMAN inspect --type image $IMAGE >/dev/null 2>&1; then
    vrun $PODMAN build -t $IMAGE .
    echo
fi

vexec $PODMAN run "${OPTS[@]}" $IMAGE ./build.sh "$@"
