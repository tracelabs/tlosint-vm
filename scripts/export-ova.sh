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
qemu-img convert -O vmdk -o subformat=streamOptimized $image.raw $image.vmdk

[ $keep -eq 1 ] || rm -f $image.raw

echo "INFO: Generate $image.ovf"
scripts/generate-ovf.sh $image.vmdk

echo "INFO: Generate $image.mf"
scripts/generate-mf.sh $image.ovf $image.vmdk

cd $(dirname $image)
image=$(basename $image)

# An OVA is simply a tar archive. The .ovf must come first,
# then the .mf comes either second or last. For details,
# refer to the OVF spec: https://www.dmtf.org/dsp/DSP0243.
echo "INFO: Generate $image.ova"
tar -cvf $image.ova $image.ovf $image.vmdk $image.mf

[ $keep -eq 1 ] || rm -f $image.ovf $image.vmdk $image.mf

# Since the disk is already compressed (streamOptimized means
# deflate compression with zlib),  there's nothing to gain by
# compressing the .ova again. So we ignore the '-z' option.
