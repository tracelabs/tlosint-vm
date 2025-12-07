# Contributing to the Trace Labs OSINT VM

Thanks for your interest in contributing! This project builds a full OSINT virtual machine, so we keep our development process structured to ensure stability and predictable releases. This document outlines the essentials you need to know before opening a PR.

---

## Before You Start

- Read the README to understand the purpose and design of the VM.  
- Look through open issues to avoid duplicating work.  
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

## Adding or Updating Tools

We follow a tooling policy to avoid VM bloat and maintain stability.  
If you want to propose a new tool:

1. Open an issue describing the tool and its OSINT use case.  
2. Follow the guidelines in [TOOLING_POLICY.md](../TOOLING_POLICY.md).
3. Once approved, submit a PR targeting `dev` with your proposed changes.
