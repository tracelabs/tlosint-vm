#!/bin/bash
# script that will set up the build environment and run debos
set -eu

WELL_KNOWN_CACHING_PROXIES="\
3142 apt-cacher-ng
8000 squid-deb-proxy
9999 approx"
DETECTED_CACHING_PROXY=

SUPPORTED_ARCHITECTURES="amd64 i386"
SUPPORTED_BRANCHES="kali-dev kali-last-snapshot kali-rolling"
SUPPORTED_DESKTOPS="e17 gnome headless i3 kde lxde mate xfce"
SUPPORTED_TOOLSETS="default everything large none"

SUPPORTED_FORMATS="ova ovf raw qemu virtualbox vmware"
SUPPORTED_VARIANTS="generic qemu rootfs virtualbox vmware"

DEFAULT_ARCH=amd64
DEFAULT_BRANCH=kali-rolling
DEFAULT_DESKTOP=xfce
DEFAULT_LOCALE=en_US.UTF-8
DEFAULT_MIRROR=http://http.kali.org/kali
DEFAULT_TIMEZONE=Etc/UTC
DEFAULT_TOOLSET=default
DEFAULT_USERPASS=osint:osint

ARCH=
BRANCH=
DESKTOP=
FORMAT=
KEEP=false
LOCALE=
MIRROR=
PACKAGES=libfuse2
PASSWORD=
ROOTFS=
SIZE=40
TIMEZONE=
TOOLSET=
USERNAME=
USERPASS=
VARIANT=vmware
VERSION=2023.03
# output will be compressed by default
ZIP=true
OUTDIR=images

default_toolset() { [ ${DESKTOP:-$DEFAULT_DESKTOP} = headless ] && echo none || echo default; }
default_version() { echo ${BRANCH:-$DEFAULT_BRANCH} | sed "s/^kali-//"; }

# Output bold only if both stdout/stderr are opened on a terminal
if [ -t 1 -a -t 2 ]; then
    b() { tput bold; echo -n "$@"; tput sgr0; }
else
    b() { echo -n "$@"; }
fi
warn() { echo "WARNING:" "$@" >&2; }
fail() { echo "ERROR:" "$@" >&2; exit 1; }

kali_message() {
    local line=
    echo "┏━━($(b $@))"
    while IFS= read -r line; do echo "┃ $line"; done
    echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

ask_confirmation() {
    local question=${1:-"Do you want to continue?"}
    local default=yes
    local default_verbing=
    local choices=
    local grand_timeout=60
    local timeout=20
    local time_left=
    local answer=
    local ret=

    # If stdin is closed, no need to ask, assume yes
    [ -t 0 ] || return 0

    # Set variables that depend on default
    if [ $default = yes ]; then
        default_verbing=proceeding
        choices="[Y/n]"
    else
        default_verbing=aborting
        choices="[y/N]"
    fi

    # Discard chars pending on stdin
    while read -r -t 0; do read -r; done

    # Ask the question, allow for X timeouts before proceeding anyway
    grand_timeout=$((grand_timeout - timeout))
    for time_left in $(seq $grand_timeout -$timeout 0); do
        ret=0
        read -r -t $timeout -p "$question $choices " answer || ret=$?
        if [ $ret -gt 128 ]; then
            if [ $time_left -gt 0 ]; then
                echo "$time_left seconds left before $default_verbing"
            else
                echo "No answer, assuming $default, $default_verbing"
            fi
            continue
        elif [ $ret -gt 0 ]; then
            exit $ret
        else
            break
        fi
    done

    # Process the answer
    [ "$answer" ] && answer=${answer,,} || answer=$default
    case "$answer" in
        (y|yes) return 0 ;;
        (*)     return 1 ;;
    esac
}

if [ $(id -u) -eq 0 ]; then
    warn "This script does not require root privileges."
    warn "Please consider running it as a non-root user."
fi

USAGE="Usage: $(basename $0) [<option>...] [-- <debos option>...]

Build a TL OSINT VM image, base image is Kali Rolling.

Build options:
  -a ARCH     Build an image for this architecture, default: $(b $DEFAULT_ARCH)
              Supported values: $SUPPORTED_ARCHITECTURES
  -b BRANCH   Kali branch used to build the image, default: $(b $DEFAULT_BRANCH)
              Supported values: $SUPPORTED_BRANCHES
  -f FORMAT   Format to export the image to, default depends on the VARIANT
              Supported values: $SUPPORTED_FORMATS
  -k          Keep raw disk image and other intermediary build artifacts
  -m MIRROR   Mirror used to build the image, default: $(b $DEFAULT_MIRROR)
  -r ROOTFS   Rootfs to use to build the image, default: $(b none)
  -s SIZE     Size of the disk image in GB, default: $(b $SIZE)
  -v VARIANT  Variant of image to build (see below for details), default: $(b $VARIANT)
              Supported values: $SUPPORTED_VARIANTS
  -z          Do not zip images and metadata files after the build

Customization options:
  -D DESKTOP  Desktop environment installed in the image, default: $(b $DEFAULT_DESKTOP)
              Supported values: $SUPPORTED_DESKTOPS
  -L LOCALE   Set locale, default: $(b $DEFAULT_LOCALE)
  -P PACKAGES Install extra packages (comma/space separated list)
  -S TOOLSET  The selection of tools to include in the image, default: $(b $(default_toolset))
              Supported values: $SUPPORTED_TOOLSETS
  -T TIMEZONE Set timezone, default: $(b $DEFAULT_TIMEZONE)
  -U USERPASS Username and password, separated by a colon, default: $(b $DEFAULT_USERPASS)

The different variants of images are:
  generic     Image with all virtualization support pre-installed, default format: raw
  qemu        Image with QEMU and SPICE guest agents pre-installed, default format: qemu
  rootfs      Not an image, a root filesystem (no bootloader/kernel), packed in a .tar.gz
  virtualbox  Image with VirtualBox guest utilities pre-installed, default format: virtualbox
  vmware      Image with Open VM Tools pre-installed, default format: vmware

The different formats are:
  ova         streamOptimized VMDK disk image, OVF metadata file, packed in a OVA archive
  ovf         monolithicSparse VMDK disk image, OVF metadata file
  raw         sparse disk image, no metadata
  qemu        QCOW2 disk image, no metadata
  virtualbox  VDI disk image, .vbox metadata file
  vmware      2GbMaxExtentSparse VMDK disk image, VMX metadata file

Supported environment variables:
  http_proxy  HTTP proxy URL, refer to the README for more details.

Refer to the README for examples.
"

while getopts ":a:b:D:o:f:hkL:m:P:r:s:S:T:U:v:x:z" opt; do
    case $opt in
        (a) ARCH=$OPTARG ;;
        (b) BRANCH=$OPTARG ;;
        (D) DESKTOP=$OPTARG ;;
        (o) OUTDIR=$OPTARG ;;
        (f) FORMAT=$OPTARG ;;
        (h) echo "$USAGE"; exit 0 ;;
        (k) KEEP=true ;;
        (L) LOCALE=$OPTARG ;;
        (m) MIRROR=$OPTARG ;;
        (P) PACKAGES="$PACKAGES $OPTARG" ;;
        (r) ROOTFS=$OPTARG ;;
        (s) SIZE=$OPTARG ;;
        (S) TOOLSET=$OPTARG ;;
        (T) TIMEZONE=$OPTARG ;;
        (U) USERPASS=$OPTARG ;;
        (v) VARIANT=$OPTARG ;;
        (x) VERSION=$OPTARG ;;
        (z) ZIP=false ;;
        (*) echo "$USAGE" >&2; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

# The first step is to validate the variant.
echo $SUPPORTED_VARIANTS | grep -qw $VARIANT \
    || fail "Unsupported variant '$VARIANT'"

# If format was not set, choose a sensible default according to the variant.
# Moreover, there should be no format when building a rootfs.
if [ $VARIANT != rootfs ]; then
    if [ -z "$FORMAT" ]; then
        case $VARIANT in
            (generic)    FORMAT=raw ;;
            (qemu)       FORMAT=qemu ;;
            (virtualbox) FORMAT=virtualbox ;;
            (vmware)     FORMAT=vmware ;;
            (*) fail "Unsupported variant '$VARIANT'" ;;
        esac
    fi
    echo $SUPPORTED_FORMATS | grep -qw $FORMAT \
        || fail "Unsupported format '$FORMAT'"
else
    [ -z "$FORMAT" ] || fail "Option -f can't be used to build a rootfs"
fi

# When building an image from an existing rootfs, ARCH and VERSION are picked
# from the rootfs name. Moreover, many options don't apply, as they've been
# set already at the time the rootfs was built.
if [ "$ROOTFS" ]; then
    [ $VARIANT != rootfs ] || fail "Option -r can only be used to build images"
    [ -z "$ARCH"    ] || fail "Option -a can't be used together with option -r"
    [ -z "$BRANCH"  ] || fail "Option -b can't be used together with option -r"
    [ -z "$DESKTOP" ] || fail "Option -D can't be used together with option -r"
    [ -z "$LOCALE"  ] || fail "Option -L can't be used together with option -r"
    [ -z "$MIRROR"  ] || fail "Option -m can't be used together with option -r"
    [ -z "$TIMEZONE" ] || fail "Option -T can't be used together with option -r"
    [ -z "$TOOLSET"  ] || fail "Option -S can't be used together with option -r"
    [ -z "$USERPASS" ] || fail "Option -U can't be used together with option -r"
    [ -z "$VERSION" ] || fail "Option -x can't be used together with option -r"
    ARCH=$(basename $ROOTFS | sed "s/\.tar\.gz$//" | rev | cut -d- -f1 | rev)
    VERSION=$(basename $ROOTFS | sed -E "s/^rootfs-(.*)-$ARCH\.tar\.gz$/\1/")
else
    [ "$ARCH"    ] || ARCH=$DEFAULT_ARCH
    [ "$BRANCH"  ] || BRANCH=$DEFAULT_BRANCH
    [ "$DESKTOP" ] || DESKTOP=$DEFAULT_DESKTOP
    [ "$LOCALE"  ] || LOCALE=$DEFAULT_LOCALE
    [ "$MIRROR"  ] || MIRROR=$DEFAULT_MIRROR
    [ "$TIMEZONE" ] || TIMEZONE=$DEFAULT_TIMEZONE
    [ "$TOOLSET"  ] || TOOLSET=$(default_toolset)
    [ "$USERPASS" ] || USERPASS=$DEFAULT_USERPASS
    [ "$VERSION" ] || VERSION=$(default_version)
    # Validate some options
    echo $SUPPORTED_BRANCHES | grep -qw $BRANCH \
        || fail "Unsupported branch '$BRANCH'"
    echo $SUPPORTED_DESKTOPS | grep -qw $DESKTOP \
        || fail "Unsupported desktop '$DESKTOP'"
    echo $SUPPORTED_TOOLSETS | grep -qw $TOOLSET \
        || fail "Unsupported toolset '$TOOLSET'"
    # Unpack USERPASS to USERNAME and PASSWORD
    echo $USERPASS | grep -q ":" \
        || fail "Invalid value for -U, must be of the form '<username>:<password>'"
    USERNAME=$(echo $USERPASS | cut -d: -f1)
    PASSWORD=$(echo $USERPASS | cut -d: -f2-)
fi
unset USERPASS

# Validate architecture
echo $SUPPORTED_ARCHITECTURES | grep -qw $ARCH \
    || fail "Unsupported architecture '$ARCH'"

# Validate size and add the "GB" suffix
[[ $SIZE =~ ^[0-9]+$ ]] && SIZE=${SIZE}GB \
    || fail "Size must be given in GB and must contain only digits"

# Order packages alphabetically, separate each package with ", "
PACKAGES=$(echo $PACKAGES | sed "s/[, ]\+/\n/g" | LC_ALL=C sort -u \
    | awk 'ORS=", "' | sed "s/[, ]*$//")

# Attempt to detect well-known http caching proxies on localhost,
# cf. bash(1) section "REDIRECTION". This is not bullet-proof.
if ! [ -v http_proxy ]; then
    while read port proxy; do
        (</dev/tcp/localhost/$port) 2>/dev/null || continue
        DETECTED_CACHING_PROXY="$port $proxy"
        export http_proxy="http://10.0.2.2:$port"
        break
    done <<< "$WELL_KNOWN_CACHING_PROXIES"
fi

# Print a summary
{
echo "# Proxy configuration:"
if [ "$DETECTED_CACHING_PROXY" ]; then
    read port proxy <<< $DETECTED_CACHING_PROXY
    echo "Detected caching proxy $(b $proxy) on port $(b $port)."
fi
if [ "${http_proxy:-}" ]; then
    echo "Using proxy via environment variable: $(b http_proxy=$http_proxy)."
else
    echo "No http proxy configured, all packages will be downloaded from Internet."
fi
[ "$MIRROR"   ] && echo "* mirror: $(b $MIRROR)"
[ "$BRANCH"   ] && echo "* branch: $(b $BRANCH)"
[ "$DESKTOP"  ] && echo "* desktop environment: $(b $DESKTOP)"
[ "$TOOLSET"  ] && echo "* tool selection: $(b $TOOLSET)"
[ "$PACKAGES" ] && echo "* additional packages: $(b $PACKAGES)"
[ "$USERNAME" ] && echo "* username & password: $(b $USERNAME $PASSWORD)"
[ "$LOCALE"   ] && echo "* locale: $(b $LOCALE)"
[ "$TIMEZONE" ] && echo "* timezone: $(b $TIMEZONE)"
} | kali_message "TL OSINT VM Build"

# Notes regarding the scratch size needed to build a Kali image from scratch
# (ie. in one step, no intermediary rootfs), using the kali-rolling branch and
# xfce desktop, and changing only the toolset. Default toolset needs 14G,
# large toolset 24G and everything toolset 40G. That was back in June 2022.
# Now set default debos options, unless user passed it explicitly after '--'.
echo "$@" | grep -q -e "-m[= ]" -e "--memory[= ]" \
    || set -- "$@" --memory=4G
echo "$@" | grep -q -e "--scratchsize[= ]" \
    || set -- "$@" --scratchsize=45G

mkdir -p $OUTDIR


echo "Building image from recipe $(b tlosint.yaml) ..."
OUTPUT=$OUTDIR/tl-osint-$VERSION-$VARIANT-$ARCH
debos "$@" \
        -t arch:$ARCH \
        -t branch:$BRANCH \
        -t desktop:$DESKTOP \
        -t format:$FORMAT \
        -t imagename:$OUTPUT \
        -t keep:$KEEP \
        -t locale:$LOCALE \
        -t mirror:$MIRROR \
        -t packages:"$PACKAGES" \
        -t password:"$PASSWORD" \
        -t size:$SIZE \
        -t timezone:$TIMEZONE \
        -t toolset:$TOOLSET \
        -t username:$USERNAME \
        -t variant:$VARIANT \
        -t zip:$ZIP \
        tlosint.yaml

cat << EOF
	   Finished
EOF
