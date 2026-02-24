# Context for AI Assistants (Claude / Cursor)

This file gives AI assistants project-specific context so suggestions stay aligned with how this repo works.

## What This Repo Is

- **Trace Labs OSINT VM** – A Debian/Kali-based virtual machine image for OSINT work, built with [debos](https://github.com/go-debos/debos).
- The **recipe** is `tlosint.yaml` (debos playbook). Scripts in `scripts/` are invoked by debos during the build; most run with `chroot: true`, some (e.g. cleanup, export) with `chroot: false`.
- **`tlosint-tools.sh`** is **not** part of the image build. It is a standalone script users run *after* importing the VM to install OSINT tools on-demand. Do not treat it as part of the debos pipeline.
- Maintained by Trace Labs staff. Community contributions are welcome; see CONTRIBUTING and CODE_OF_CONDUCT.

## Branch & Release Model

- **All PRs target `dev`.** Nothing goes directly to `main` for normal changes.
- Flow: `PR → dev` → full VM build on every push to `dev` → when stable, maintainers merge `dev` → `main` → tag → release.
- **`main`** is only updated from `dev` after the full build passes. Releases are tagged from `main` (e.g. `2025.08`).
- Do not suggest merging to `main` or changing the release cadence; that is maintainer-owned. Hotfixes follow the process in `docs/RELEASES.md`.

## Build & Tooling

- **Build:** debos reads `tlosint.yaml`; build is typically run via Docker (e.g. `build-in-container.sh`). CI runs full VM builds on `dev` and `main` (see `.github/workflows/ensure-vm-builds.yml`).
- **Adding tools:** New tools must be proposed via a **Tool Request** issue and follow **docs/TOOLING_POLICY.md**. The VM is curated for OSINT; we avoid bloat and duplicate functionality. Do not suggest adding tools without referencing the tooling policy and evaluation criteria.
- **Scripts:** Scripts in `scripts/` are either run by debos (see `tlosint.yaml`) or are standalone utilities (e.g. `tlosint-tools.sh`). Check the playbook and CONTRIBUTING before assuming a script is part of the image build.

## Key Files & Docs

| Purpose | Location |
|--------|----------|
| Contributing, workflow, PR guidelines | `docs/CONTRIBUTING.md` |
| Release process, hotfixes | `docs/RELEASES.md` |
| Tool evaluation and request process | `docs/TOOLING_POLICY.md` |
| Security reporting | `SECURITY.md` |
| Code of conduct | `CODE_OF_CONDUCT.md` |
| Debos playbook | `tlosint.yaml` |
| Issue/PR templates | `.github/ISSUE_TEMPLATE/`, `.github/pull_request_template.md` |

## Conventions to Follow

- **One logical change per PR.** PRs should target `dev`.
- **No built VM images or large binaries** in PRs.
- Reference issues with `Closes #123` (or similar) when a PR fixes an issue.
- When suggesting new tools or packages, remind the user to open a Tool Request issue and to follow docs/TOOLING_POLICY.md (relevance, license, no overlap, etc.).
- Documentation: user-facing and process docs live in `docs/`; root-level README, SECURITY, CODE_OF_CONDUCT, LICENSE, CHANGELOG stay at repo root.
- Changelog format follows [Keep a Changelog](https://keepachangelog.com/); list changes under `[Unreleased]` or the relevant version.

## What Not to Do

- Do not suggest merging feature PRs to `main` or bypassing `dev`.
- Do not suggest adding tools without going through the Tool Request process and TOOLING_POLICY criteria.
- Do not assume `tlosint-tools.sh` runs during the VM build; it is a post-import user script.
- Do not propose changes that conflict with the tooling policy (e.g. non-OSINT tools, duplicate tools, license-incompatible tools).
