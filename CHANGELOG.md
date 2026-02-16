# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- PLACEHOLD

### Security Enhancements

#### Dockerfile Hardening (CIS Benchmark Compliance)
- **Image Pinning**: Pinned base image to specific SHA256 digest (`sha256:b1f67719a6d2c62f08ceadaebf2daf64a32cb56b5dbf5c6307ac48cd84cda3d4`) for supply chain security and immutability
  - This pin should be updated as Kali pushes new releasese
  - Reference: CIS Docker Benchmark v1.6.0 - 4.1
  - Includes update instructions in comments for manual digest updates
  
- **Signature Verification**: Enabled Docker Content Trust (`ENV DOCKER_CONTENT_TRUST=1`) for all image pulls
  - Reference: CIS Docker Benchmark v1.6.0
  - Ensures cryptographic validation of base image authenticity

- **HTTPS-Only Package Sources**: Configured all APT sources to use HTTPS
  - Mirror: `https://kali.download/kali`
  - Bootstrap ca-certificates via HTTP (unavoidable first step), then switch entirely to HTTPS
  - Configured APT retry logic (3 retries) and timeout (30s) for reliability
  - Reference: CIS Benchmark v1.1.1

- **GPG Key Verification**: Implemented cryptographic verification of Kali archive GPG key
  - Downloads key from official Kali repository
  - Verifies packet structure with `gpg --list-packets` before import
  - Converts to keyring format with `gpg --dearmor`
  - Key Details:
    - Key ID: ED65462EC8D5E4C5
    - Owner: Kali Linux Archive Automatic Signing Key (2025)
    - Algorithm: RSA-4096
    - Validity: 2025-04-21 to 2028-04-21

- **Minimal Package Installation**: Applied `--no-install-recommends` flag to all APT installs
  - Reference: CIS Benchmark v2.2.x
  - Reduces attack surface by excluding unnecessary dependencies

- **Layer Optimization**: Combined related RUN commands to reduce final image layer count
  - Reference: CIS Docker Benchmark v1.6.0 - 4.7
  - Reduces image size and improves caching efficiency

- **Package Cache Cleanup**: Aggressive cleanup of package manager artifacts
  - Removes: `/var/lib/apt/lists/*`, `/tmp/*`, `/var/tmp/*`, `/var/cache/apt/archives/*.deb`
  - Reduces final image size and eliminates stale package metadata

- **Non-Root User Implementation**: Created dedicated non-root user `tlosint` (UID 1000)
  - Reference: CIS Docker Benchmark v1.6.0 - 4.1
  - Runs all container processes with restricted privileges
  - User created with `groupadd -r` (system group) and `useradd -r` (system user) flags

- **SUID/SGID Bit Removal**: Removed dangerous permission bits from all binaries
  - Reference: CIS Benchmark v1.5.4
  - Prevents privilege escalation attacks via setuid/setgid binaries
  - Applied to all binaries in `/usr/bin` and `/usr/sbin`

- **Permission Hardening**: Enforced restrictive filesystem permissions
  - Home directory (`/home/tlosint`): 750 (user rwx, group rx, other no access)
  - Root directory (`/root`): 700 (user rwx only)
  - Reference: CIS Benchmark v6.2.8, v6.2.9

- **Health Check**: Added HEALTHCHECK instruction
  - Reference: CIS Docker Benchmark v1.6.0 - 4.6
  - Validates container health via directory existence check
  - Interval: 30s, Timeout: 3s, Start period: 5s, Retries: 3

### Added

- **Comprehensive CIS Benchmark Documentation**: Every Dockerfile layer now includes references to specific CIS Benchmark controls
  - Provides clear compliance mapping
  - Facilitates security audits and compliance verification

### Changed

- **Dockerfile Organization**: Restructured with detailed security inline comments
  - Header section explains CIS Benchmark purpose and philosophy
  - Each RUN instruction includes justification and control references

## Workflow Updates (.github/workflows)

### ensure-vm-builds.yml
- **Dev Branch Support**: Added `dev` branch to workflow triggers
  - Triggers on: `push` and `pull_request` to both `main` and `dev` branches
  - Ensures CI/CD validation for both production and development branches

- **Path Exclusions**: Configured path-ignore patterns
  - Skips workflow on changes to: `.github/CODEOWNERS`, `.github/ISSUE_TEMPLATE/**`, `docs/**`, `LICENSE`, `README.md`
  - Reduces unnecessary CI/CD runs for non-code changes

- **Docker Build Infrastructure**: Enhanced Docker build process
  - Uses Docker Buildx with caching for faster rebuilds
  - Supports multi-platform builds and layer caching

- **Host Dependency Management**: Explicit installation of build dependencies
  - Dependencies: debos, p7zip, qemu-utils, zerofree, e2fsprogs
  - Cleanup: Removes package lists after installation (`/var/lib/apt/lists/*`)

### manual.yml
- **Manual Build Trigger**: Implements `workflow_dispatch` for on-demand builds
  - Allows authorized users to trigger OVA builds without code changes
  - Input parameter for build identification

- **Host Dependencies**: Specifies required tools for OVA build process
  - Dependencies: debos, p7zip, qemu-utils, zerofree

- **Script Execution**: Explicit permission grant and execution
  - Makes build scripts executable: `chmod +x scripts/tl/*.sh` and `chmod +x ./build.sh`
  - Ensures scripts run with proper permissions

- **Artifact Upload**: Configured artifact retention
  - Uploads built OVA images from `images/*.7z`
  - Makes builds available as GitHub artifacts for download

### shellcheck.yml
- Static analysis workflow for shell script validation
- Detects syntax errors and common shell script pitfalls

### releases.yml
- Automated release process for version tags
- Handles artifact publishing and changelog generation

## Build System Architecture

### build-in-container.sh
- Entry point for local/CI builds
- Detects Podman or Docker availability
- Builds `tlvm-builder` image if not cached
- Mounts volumes: `./recipes` → `/recipes`, `./images` → `/images`
- Executes `build.sh` inside container

### build.sh
- Runs inside `tlvm-builder` container
- Copies Kali GPG key from container to host: `/opt/kali-archive-keyring.gpg` → `/recipes/`
- Executes debos with `tlosint.yaml` recipe
- Generates OVA VM image in `./images/`

### Dockerfile
- Creates minimal, hardened build environment
- Installs debos and build tools
- Extracts and prepares Kali archive GPG key for OVA build process
- Final image: ~1.6GB

## Security Posture

### Compliance
- CIS Docker Benchmark v1.6.0: Multiple controls implemented
- CIS Linux Benchmark: User, permission, and SUID/SGID controls
- Supply Chain Security: Image pinning and signature verification

## Notes

- Container runs as non-root (`tlosint` user) with UID 1000
- GPG key embedded in container for automated OVA builds
- Network requirement: `--net host` for CI/CD; HTTPS-only for package operations
- No CMD/ENTRYPOINT defined; container exits after task completion
- Build artifacts available in `./images/` directory

# COMMAND
- Continue the hunt, until they all come home.
