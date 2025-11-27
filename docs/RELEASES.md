# VM Release Process

This document describes how we prepare, validate, and publish official Trace Labs OSINT VM releases. The process is intentionally lightweight but ensures every release is stable, reproducible, and properly documented. All releases come from the **`main`** branch after passing the required checks.

Releases are owned by assigned maintainers—usually Trace Labs staff.
Release owners and timelines are proposed and confirmed during our quarterly planning meetings.

---

## Overview

Development happens in the **`dev`** branch. Once `dev` is stable and the full VM build passes, changes are merged into **`main`**. Tagging `main` triggers the automated release workflow.

We follow a predictable release cadence, with additional hotfix releases when needed. The process is mostly automated but includes a small number of manual steps.

---

## Timeline & Cadence

- Releases follow a **scheduled cadence** (e.g., every 3 months using tags like `2025.08`).  
- Automated bi-weekly builds (coming soon) will trigger a release if the build passes.
- **Hotfix releases** occur outside this schedule for urgent breakages.  
- All releases must complete the pre-release checklist before tagging.

---

## Release Owner Checklist

### Planning

- Confirm release dates during our quarterly planning meetings.
- Assign ownership to Trace Labs staff.
- Review open issues/PRs to see what is landing in this release.
- Open a release tracking issue to track the release and assign it to the release owner.

(This issue will include a checklist of items to complete before the release.)

### Pre-Release

- Ensure CI is passing on the `dev` branch
- Merge `dev` into `main`
- Build full VM images (VirtualBox + VMware)
- Generate SHA256 checksums for both images

### Release Tagging & Publishing

- Select a version tag matching the format (`YYYY.MM`)
- Tag the `main` branch (`git checkout main && git tag <version> && git push origin <version>`)
- The [automated release workflow](../.github/workflows/releases.yml) will build and package the images.
- Build the full VM images locally
- Upload VM images + checksums to [Google Drive](https://drive.google.com/drive/u/1/folders/19YF5F5b8AdcFprnW-1GSea97AqyhSPdz)
- Create the GitHub Release and include:
  - Google Drive download links  
  - Checksums  
  - Review generated release notes

### Post-Release

- Monitor early user feedback.
- Log any discovered issues for the next cycle.
- Confirm next release timeline and owners.

---

## Release Artifacts

Each official release includes three types of assets:

### 1. GitHub Release VM (~1.5 GB)

- Distributed via GitHub Releases.
- Includes the base VM environment.
- **Tool install script is included but *not executed*.**
- Smaller download; ideal if you want to run the tool installer yourself.

### 2. Google Cloud VM (~2.5 GB)

- Hosted on Google Drive due to larger size.
- Same base VM as the GitHub release.
- **Tool install script has been executed** (all tools pre-installed).
- Best choice for users who want a ready-to-go environment.

### 3. Standalone Tool Install Script

- Available as a separate downloadable file.
- Can be run on any compatible Debian-based host OS.
- Ideal for users who want TLOSINT tooling without using the VM.

---

## Release Procedure

### Creating a Release Using GitHub

1. **Determine the release tag** in `YYYY.MM` format.  
2. **Tag the `main` branch** with the chosen version.  
3. Let the automated release workflow build and package images.  
4. **Upload the OVA files and checksums** to the Google Drive release folder.  
5. **Create or update the GitHub Release** with:
   - Google Drive download links  
   - SHA256 checksums  
   - Relevant release notes  

Once published, the release is considered official.

---

## Hotfix Releases

Hotfixes address urgent issues such as upstream breakage, major tool failures, or anything that substantially impacts users.

### Hotfix Policy

- Hotfix PRs should be **minimal** and focused solely on the fix.  
- Hotfix PRs land in `dev`, then are cherry-picked or merged into `main`.  
- Hotfix releases should not include unrelated changes.

### Hotfix Workflow

1. Identify the issue requiring a hotfix.  
2. Submit a PR to `dev` with the minimal fix.  
3. After merging, wait for CI to run a full build on `dev` to confirm stability.  
4. Cherry-pick the fix into `main`.  
5. Tag a hotfix release (e.g., `yyyy.mm.1`).  
6. Follow the release procedure to publish the hotfix release.

Hotfixes should be used sparingly and only when necessary.
