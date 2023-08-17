#!/bin/sh

set -eu

if [ -z "$ROOTDIR" ]; then
    echo "ERROR: ROOTDIR is empty"
    exit 1
fi

rm -f  $ROOTDIR/etc/ssh/ssh_host_*
rm -fr $ROOTDIR/tmp/*
rm -fr $ROOTDIR/var/lib/apt/lists/*
rm -f  $ROOTDIR/var/log/bootstrap.log
rm -fr $ROOTDIR/var/tmp/*

# Taken from kali-docker, however not sure it's suitable here,
#rm -f  $ROOTDIR/var/cache/ldconfig/aux-cache
#find   $ROOTDIR/var/log -depth -type f -print0 | xargs -0 truncate -s 0
