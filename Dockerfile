FROM docker.io/kalilinux/kali-rolling

RUN apt update && apt install -y curl gnupg

# Download and install the Kali GPG key for apt
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://archive.kali.org/archive-key.asc | gpg --dearmor -o /recipes/kali-archive-keyring.gpg

RUN apt update \
 && apt --quiet --yes install --no-install-recommends \
    bmap-tools debos dosfstools linux-image-amd64 p7zip parted qemu-utils systemd-resolved xz-utils zerofree e2fsprogs


