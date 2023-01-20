#!/bin/sh

set -eu

image=
zip=0

while [ $# -gt 0 ]; do
    case $1 in
        -z) zip=1 ;;
        *) image=$1 ;;
    esac
    shift
done

echo "INFO: Rename to $image.img"
mv -v $image.raw $image.img

cd $(dirname $image)
image=$(basename $image)

if [ $zip -eq 1 ]; then
    echo "INFO: Dig holes in the sparse file"
    fallocate -v --dig-holes $image.img

    echo "INFO: Create bmap file $image.img.bmap"
    bmaptool create $image.img > $image.img.bmap

    echo "INFO: Compress to $image.img.xz"
    xz -f $image.img
fi
