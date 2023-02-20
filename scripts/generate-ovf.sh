#!/bin/bash

set -eu

fail() { echo "$@" >&2; exit 1; }
usage() { fail "Usage: $(basename $0) VMDK"; }

get_vmdk_disk_uuid() {

    # Get the UUID of a .vmdk disk
    # (should propose this feature to 'qemu-img info')

    local disk=$1
    local magic=

    magic=$(head -c4 $disk)
    if [ "$magic" != KDMV ]; then
        return
    fi

    dd skip=1 count=2 if=$disk 2>/dev/null \
        | sed -n "s/^ddb\.uuid\.image=//p" | tr -d '"'
}

get_virtual_disk_capacity() {

    # Get the capacity of a virtual disk.
    # Tested with the following formats: vmdk, vdi.

    local disk=$1

    qemu-img info $disk \
        | grep "^virtual size: " \
        | sed -E "s/.* \(([0-9]+) bytes\)$/\1/"
}

get_virtual_disk_format() {

    # Get a url to describe the disk format.

    local disk=$1
    local buf=
    local format=
    local subformat=
    local url=

    buf=$(qemu-img info $disk)

    format=$(echo "$buf" | sed -n "s/^file format: *//p")
    if [ "$format" != vmdk ]; then
        return
    fi

    url="http://www.vmware.com/interfaces/specifications/vmdk.html"

    subformat=$(echo "$buf" | sed -n "s/^ *create type: *//p")
    case "$subformat" in
        monolithicSparse) url+="#sparse" ;;
        streamOptimized)  url+="#streamOptimized" ;;
    esac

    echo $url
}

# Validate arguments

[ $# -eq 1 ] || usage

disk_path=$1

[ ${disk_path##*.} = vmdk ] || fail "Invalid input file '$disk_path'"

description_template=scripts/templates/vm-description.txt
machine_templace=scripts/templates/vm-definition.ovf

# Prepare all the values

disk_file=$(basename $disk_path)
name=${disk_file%.*}

arch=${name##*-}
[ "$arch" ] || fail "Failed to get arch from image name '$name'"
version=$(echo $name | sed -E 's/^kali-linux-(.+)-.+-.+$/\1/')
[ "$version" ] || fail "Failed to get version from image name '$name'"

disk_capacity=$(get_virtual_disk_capacity $disk_path)
disk_format=$(get_virtual_disk_format $disk_path)
disk_size=$(stat -c %s $disk_path)
# AFAIK the disk uuid is not set by qemu-img, in such case we generate something random
disk_uuid=$(get_vmdk_disk_uuid $disk_path)
[ "$disk_uuid" ] || disk_uuid=$(cat /proc/sys/kernel/random/uuid)
machine_uuid=$(cat /proc/sys/kernel/random/uuid)

license="GPL v3 ~ https://www.kali.org/docs/policy/kali-linux-open-source-policy/"
product="Kali Linux"
product_url="https://www.kali.org/"
product_version="Rolling ($version)"
vendor="Offensive Security"
vendor_url="https://www.offensive-security.com/"

# For OS IDs and types, refer to:
# https://docs.openlmi.org/en/latest/mof/CIM_SoftwareElement.html
#
# The os_type is NOT what's documented in the reference above though,
# it's what VirtualBox uses internally, and it's used in various places
# in the OVF, notably it's a keyword in <vbox:Machine OSType="xxx">.
case $arch in
    amd64)
        long_mode=true
        os_id=96
        os_type=Debian_64
        os_version=10
        platform=x64
        product_version="$product_version x64"
        ;;
    i386)
        long_mode=false
        os_id=95
        os_type=Debian
        os_version=10
        platform=x86
        product_version="$product_version x86"
        ;;
    *)
        fail "Invalid architecture '$arch'"
        ;;
esac

# Create the description

description=$(sed \
    -e "s|%date%|$(date --iso-8601)|g" \
    -e "s|%kbdlayout%|US keyboard layout|g" \
    -e "s|%platform%|$platform|g" \
    -e "s|%version%|$version|g" \
    $description_template)

# Create the .ovf file

output=${disk_path%.*}.ovf

sed \
    -e "s|%Capacity%|$disk_capacity|g" \
    -e "s|%DiskFile%|$disk_file|g" \
    -e "s|%DiskFormat%|$disk_format|g" \
    -e "s|%DiskSize%|$disk_size|g" \
    -e "s|%DiskUUID%|$disk_uuid|g" \
    -e "s|%License%|$license|g" \
    -e "s|%LongMode%|$long_mode|g" \
    -e "s|%MachineName%|$name|g" \
    -e "s|%MachineUUID%|$machine_uuid|g" \
    -e "s|%OSId%|$os_id|g" \
    -e "s|%OSType%|$os_type|g" \
    -e "s|%OSVersion%|$os_version|g" \
    -e "s|%Product%|$product|g" \
    -e "s|%ProductUrl%|$product_url|g" \
    -e "s|%ProductVersion%|$product_version|g" \
    -e "s|%Vendor%|$vendor|g" \
    -e "s|%VendorUrl%|$vendor_url|g" \
    -e "s|%VirtualSystemId%|$name|g" \
    -e "s|%VirtualSystemIdentifier%|$name|g" \
    $machine_templace > $output

awk -v r="$description" '{ gsub(/%Description%/,r); print }' $output > $output.1
mv $output.1 $output

unmatched_patterns=$(grep -E -n "%[A-Za-z_]+%" $output || :)
if [ "$unmatched_patterns" ]; then
    echo "Some patterns were not replaced in '$output':" >&2
    echo "$unmatched_patterns" >&2
    exit 1
fi
