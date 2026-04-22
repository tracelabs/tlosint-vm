#!/bin/sh

set -eu

if [ -z "$ROOTDIR" ]; then
    echo "ERROR: ROOTDIR is empty"
    exit 1
fi

rm -f  "$ROOTDIR"/etc/ssh/ssh_host_*
rm -fr "$ROOTDIR"/tmp/*
rm -fr "$ROOTDIR"/var/lib/apt/lists/*
rm -f  "$ROOTDIR"/var/log/bootstrap.log
rm -fr "$ROOTDIR"/var/tmp/*
