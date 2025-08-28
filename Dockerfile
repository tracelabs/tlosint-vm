FROM docker.io/kalilinux/kali-rolling

RUN apt-get update \
 && apt-get --quiet --yes install --no-install-recommends \
    bmap-tools \
    debos \
    dosfstools \
    linux-image-amd64 \
    p7zip \
    parted \
    qemu-utils \
    systemd-resolved \
    xz-utils \
    zerofree \
    e2fsprogs \
    curl \
    wget \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
