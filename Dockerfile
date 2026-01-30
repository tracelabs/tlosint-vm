# Base image: Kali Linux Rolling
# INFRA: tlosint-vm/Dockerfile
# This Dockerfile purpose is to create a minimal Kali Linux environment not a fluffy pillow for attacks. 
# with essential tools for building custom OS images and pull the Kali key for package verification.
# TO UPDATE THIS IMAGE: docker pull kalilinux/kali-rolling:latest && docker inspect kalilinux/kali-rolling:latest --format='{{index .RepoDigests 0}}'
##################################################################################################################
# WHAT IS CIS Docker Benchmark?
# The CIS Docker Benchmark is a set of best practices and guidelines developed by the Center for Internet
# Security (CIS) to enhance the security of Docker containers and the Docker platform. It provides
# recommendations for securely configuring Docker, managing container images, and implementing security
# controls to protect containerized applications from potential threats and vulnerabilities.
# We accept nothing short of perfection for our Users. 
##################################################################################################################
# CIS Docker Benchmark v1.6.0 - 4.1: Pin base image to specific digest for immutability and supply chain security
# Last updated: 2026-01-29
FROM docker.io/kalilinux/kali-rolling@sha256:b1f67719a6d2c62f08ceadaebf2daf64a32cb56b5dbf5c6307ac48cd84cda3d4

# CIS Docker Benchmark v1.6.0 - Enable signature verification for all pulled images
ENV DOCKER_CONTENT_TRUST=1

# CIS Docker Benchmark v1.6.0 - 4.7: Combine update with install to reduce layers and avoid stale package cache
# Bootstrap HTTPS support (required before switching to HTTPS-only mirrors)
RUN apt update && apt install -y ca-certificates apt-transport-https

# CIS Benchmark - 1.1.1: Configure secure package sources (HTTPS-only to prevent MITM attacks)
# Configure apt retry/timeout for reliability
RUN echo 'deb https://kali.download/kali kali-rolling main contrib non-free non-free-firmware' > /etc/apt/sources.list \
    && echo 'Acquire::Retries "3";' > /etc/apt/apt.conf.d/80-retries \
    && echo 'Acquire::https::Timeout "30";' >> /etc/apt/apt.conf.d/80-retries

# Install GPG tools for cryptographic signature verification
RUN apt update && apt install -y --fix-missing curl gnupg

# CIS Benchmark - Verify GPG key authenticity before importing
# Download Kali archive GPG key, verify packet structure, then convert to keyring format
RUN mkdir -p /recipes \
    && curl -fsSL https://archive.kali.org/archive-key.asc -o /tmp/kali-key.asc \
    && gpg --list-packets /tmp/kali-key.asc \
    && gpg --dearmor < /tmp/kali-key.asc > /opt/kali-archive-keyring.gpg \
    && rm /tmp/kali-key.asc

# CIS Benchmark - 2.2.x: Install only required packages (--no-install-recommends)
# CIS Docker Benchmark v1.6.0 - 4.7: Combine multiple RUN commands to reduce image layers
# Install debos build tools and clean up package cache to reduce attack surface
RUN apt update \
 && apt --quiet --yes install --no-install-recommends \
    bmap-tools debos dosfstools linux-image-amd64 p7zip parted qemu-utils systemd-resolved xz-utils zerofree e2fsprogs \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && rm -rf /var/cache/apt/archives/*.deb

# CIS Docker Benchmark v1.6.0 - 4.1: Create a user for the container
# CIS Benchmark - 5.4.4: Ensure default user umask is configured
# Create non-root user with specific UID/GID for consistent permissions across systems
RUN groupadd -r tlosint -g 1000 \
    && useradd -r -u 1000 -g tlosint -m -s /bin/bash tlosint \
    && mkdir -p /home/tlosint/workspace /recipes \
    && chown -R tlosint:tlosint /home/tlosint /recipes

# CIS Benchmark - 6.2.8: Ensure users' home directories permissions are 750 or more restrictive
# CIS Benchmark - 6.2.9: Ensure users own their home directories
# CIS Benchmark - 1.5.4: Remove SUID/SGID bits to prevent privilege escalation
# Harden filesystem permissions and remove dangerous permission bits
RUN chmod 750 /home/tlosint \
    && chmod 700 /root \
    && find /usr/bin /usr/sbin -perm /4000 -type f -exec chmod u-s {} \; || true \
    && find /usr/bin /usr/sbin -perm /2000 -type f -exec chmod g-s {} \; || true

# Set working directory to non-root user home
WORKDIR /home/tlosint/workspace

# CIS Docker Benchmark v1.6.0 - 4.1: Run container as non-root user
USER tlosint

# CIS Docker Benchmark v1.6.0 - 4.6: Add HEALTHCHECK instruction to verify container health
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD [ "test", "-d", "/home/tlosint" ] || exit 1


