#!/bin/sh

set -eu

blockdev=$1

# The partition needs to be either unmounted or mounted read-only before we can
# "zerofree" it. Furthermore, the partition must be mounted when this script
# exits, as debos will want to unmount it and it will complain if it can't.

mntpoint=$(findmnt --noheadings -o target $blockdev)
if [ "$mntpoint" ]; then
    mount -v -o remount,ro $blockdev
fi

zerofree -v $blockdev
