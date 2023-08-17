#!/bin/sh

set -eu

# Helpers

fail() { echo "$@" >&2; exit 1; }
usage() { fail "Usage: $(basename $0) VMDK"; }

gen_uuid() {

    # Generate a UUID in a format suitable for the .vmx file.
    # In practice, it's automatically generated if missing from
    # the .vmx file, so we don't need this function.
    # Cf. https://kb.vmware.com/s/article/1541

    local p1= p2=

    p1=$(od -An -tx1 -N8 /dev/urandom | sed "s/^ *//")
    p2=$(od -An -tx1 -N8 /dev/urandom | sed "s/^ *//")

    echo $p1-$p2
}

gen_vmci_id() {

    # Generate a VMCI id. In practice, it's automatically
    # generated if missing from the .vmx file, so we don't
    # need this function.
    # Cf. https://kb.vmware.com/s/article/1010806

    od -vAn -tu4 -N4 < /dev/urandom | sed "s/^ *//"
}

# Validate arguments

[ $# -eq 1 ] || usage

disk_path=$1

[ ${disk_path##*.} = vmdk ] || fail "Invalid input file '$disk_path'"

description_template=scripts/templates/vm-description.txt
machine_template=scripts/templates/vm-definition.vmx

# Prepare all the values

disk_file=$(basename $disk_path)
name=${disk_file%.*}
nvram=${name}.nvram

arch=${name##*-}
[ "$arch" ] || fail "Failed to get arch from image name '$name'"
version=$(echo $name | sed -E 's/^kali-linux-(.+)-.+-.+$/\1/')
[ "$version" ] || fail "Failed to get version from image name '$name'"

case $arch in
    amd64)
        platform=x64
        guest_os=debian10-64
        ;;
    i386)
        platform=x86
        guest_os=debian10
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

annotation=$(echo "$description" | awk "{print}" ORS='\\|0D\\|0A')

# Create the .vmx file

output=${disk_path%.*}.vmx

sed \
    -e "s|%annotation%|$annotation|g" \
    -e "s|%displayName%|$name|g" \
    -e "s|%fileName%|$disk_file|g" \
    -e "s|%guestOS%|$guest_os|g" \
    -e "s|%nvram%|$nvram|g" \
    $machine_template > $output

# Tweaks for i386, not sure it's really needed.
if [ $arch = i386 ]; then
    sed -i \
        -e "/^ethernet0\.virtualDev/d" \
        -e "/^vcpu\.hotadd/d" \
        $output
fi

unmatched_patterns=$(grep -E -n "%[A-Za-z_]+%" $output || :)
if [ "$unmatched_patterns" ]; then
    echo "Some patterns were not replaced in '$output':" >&2
    echo "$unmatched_patterns" >&2
    exit 1
fi
