FROM docker.io/kalilinux/kali-rolling

RUN apt-get update \
 && apt-get install  -y \
    bmap-tools debos linux-image-amd64 p7zip parted qemu-utils xz-utils zerofree user-mode-linux libslirp-helper \
 && apt-get clean
