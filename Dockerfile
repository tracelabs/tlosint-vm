FROM docker.io/kalilinux/kali-rolling

RUN apt-get update \
 && apt-get install --no-install-recommends -y \
    bmap-tools debos linux-image-amd64 p7zip parted qemu-utils xz-utils zerofree \
 && apt-get clean
