# Contributing to the Trace Labs OSINT VM

Thanks for your interest in contributing! This project builds a full OSINT virtual machine, so we keep our development process structured to ensure stability and predictable releases. This document outlines the essentials you need to know before opening a PR.

By participating in this project, you agree to abide by our [Code of Conduct](../CODE_OF_CONDUCT.md).

---

## Where to Get Help

- **Bugs and feature requests:** Use the [issue templates](https://github.com/tracelabs/tlosint-vm/issues/new/choose).
- **Tool requests:** Open an issue and choose the "Tool Request" template; see [TOOLING_POLICY.md](../TOOLING_POLICY.md) for evaluation criteria.

---

## Before You Start

- Read the README to understand the purpose and design of the VM.  
- Look through [open issues](https://github.com/tracelabs/tlosint-vm/issues) to avoid duplicating work.  
- Issues labeled `good first issue` are good entry points for new contributors.  
- If you plan to work on an issue, **assign it to yourself**.

---

## Development Workflow

### Summary

`PR → dev (can break) → full build passes → dev → main → tag → release`

### Branch & CI Workflow

- All PRs are merged into the **`dev`** branch.  
- PRs must pass linting and smoke tests (no full 15-min builds on PRs).  
- Every push to `dev` triggers a **full VM build**; if it fails, `dev` must be fixed before anything moves to `main`.  
- The **`main`** branch only receives changes from `dev` once the full build is passing.  
- On a scheduled cadence (e.g., every three months), maintainers merge `dev` into `main` and tag a release, which triggers the automated release workflow.
- Automated bi-weekly builds (coming soon) will trigger a release if the build passes.

Read more about the release process in [RELEASES.md](./RELEASES.md).

### Pull Request Guidelines

- Keep PRs focused: **one change, feature, or fix per PR**.  
- If your PR closes an issue, include `Closes #123` in the description.  
- Do **not** include built VM images or large binaries in PRs.
- PRs should target the `dev` branch.

---

## Build Process Overview

The VM is built using **debos** (Debian OS builder), which reads `tlosint.yaml` as a playbook. The build process follows these high-level steps:

1. **Debootstrap** - Creates a minimal Debian/Kali base system
2. **Package Installation** - Installs core packages, desktop environment, and standard tools
3. **Configuration** - Sets locale, timezone, hostname, and user accounts
4. **Overlays** - Applies custom files (desktop shortcuts, bookmarks, backgrounds, etc.)
5. **System Setup** - Creates swap file, installs kernel/bootloader, configures virtualization support
6. **Cleanup** - Removes temporary files, logs, and unnecessary packages
7. **Export** - Converts the raw image to the final format (OVA, OVF, VMware, VirtualBox, etc.)

Scripts in the `scripts/` directory are executed by debos at various stages of the build. Most scripts run inside a chroot environment (`chroot: true`), while cleanup and export scripts run outside (`chroot: false`).

**Note:** The `tlosint-tools.sh` script is **not** part of the build process. It's a standalone utility script that users can download and run manually after importing the VM to install OSINT tools on-demand.

## Adding or Updating Tools

We follow a tooling policy to avoid VM bloat and maintain stability.  
If you want to propose a new tool:

1. Open an issue describing the tool and its OSINT use case.  
2. Follow the guidelines in [TOOLING_POLICY.md](../TOOLING_POLICY.md).
3. Once approved, submit a PR targeting `dev` with your proposed changes.
