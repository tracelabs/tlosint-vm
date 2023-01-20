#!/bin/sh

set -eu

keep=0
image=
zip=0

while [ $# -gt 0 ]; do
    case $1 in
        -k) keep=1 ;;
        -z) zip=1 ;;
        *) image=$1 ;;
    esac
    shift
done

echo "INFO: Generate $image.vmdk"
rm -fr $image.vmwarevm && mkdir $image.vmwarevm
qemu-img convert -O vmdk -o subformat=twoGbMaxExtentSparse \
    $image.raw $image.vmwarevm/$(basename $image).vmdk

[ $keep -eq 1 ] || rm -f $image.raw

echo "INFO: Generate $image.vmx"
scripts/generate-vmx.sh $image.vmwarevm/$(basename $image).vmdk

cd $(dirname $image)
image=$(basename $image)

if [ $zip -eq 1 ]; then
    echo "INFO: Compress to $image.7z"
    7zr a -sdel -mx=9 $image.7z $image.vmwarevm
fi
