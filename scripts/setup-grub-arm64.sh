#!/bin/sh

kernel=$(ls /boot/vmlinuz-* 2>/dev/null | sort -V | tail -1)
initrd=$(ls /boot/initrd.img-* 2>/dev/null | sort -V | tail -1)

[ -z "$kernel" ] && { echo "ERROR: no kernel found in /boot"; exit 1; }
[ -z "$initrd" ] && { echo "ERROR: no initrd found in /boot"; exit 1; }

root_uuid=$(blkid -s UUID -o value "$(df / | tail -1 | awk '{print $1}')")
[ -z "$root_uuid" ] && { echo "ERROR: could not determine root UUID"; exit 1; }

mkdir -p /boot/grub

cat > /boot/grub/grub.cfg << EOF
set default=0
set timeout=5

menuentry 'Debian GNU/Linux' {
    search --no-floppy --fs-uuid --set=root ${root_uuid}
    linux ${kernel} root=UUID=${root_uuid} ro quiet
    initrd ${initrd}
}
EOF
