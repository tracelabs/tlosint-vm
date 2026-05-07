# Builder image for the Trace Labs OSINT VM.
# Hosts `debos` and the disk-image tooling needed to assemble the VM.
# This container is ephemeral build infrastructure — not the VM itself.

FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install --no-install-recommends -y \
        ca-certificates \
        debos \
        bmap-tools \
        dosfstools \
        e2fsprogs \
        linux-image-amd64 \
        p7zip \
        parted \
        qemu-utils \
        systemd-resolved \
        xz-utils \
        zerofree \
 && rm -rf /var/lib/apt/lists/*

RUN groupadd -r tlosint -g 1000 \
 && useradd  -r tlosint -u 1000 -g tlosint -m -s /bin/bash \
 && mkdir -p /recipes /images \
 && chown -R tlosint:tlosint /recipes /images

WORKDIR /recipes
USER tlosint
