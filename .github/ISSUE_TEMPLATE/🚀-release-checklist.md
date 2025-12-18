---
name: "🚀 Release Checklist"
about: Track the steps required to cut a new TLOSINT-VM release
title: "[RELEASE] yyyy.mm"
labels: kind/release

---
Release Owner: [@username](https://github.com/username)
Release Date: yyyy-mm-dd

### Pre-Release

- [ ] Ensure CI is passing on the `dev` branch
- [ ] PR `dev` into `main`
- [ ] Build full VM images (VirtualBox + VMware)
- [ ] Generate SHA256 checksums for both images

### Release Tagging & Publishing

- [ ] Select a version tag matching the format (`YYYY.MM`)
- [ ] Update the `VERSION` variable in the `build.sh` script to the new version.
- [ ] Tag the `main` branch (`git checkout main && git tag <version> && git push origin <version>`)
- [ ] The [automated release workflow](../.github/workflows/releases.yml) will build and package the images.
- [ ] Build the full VM images locally (For Vbox, export with stripped MAC addresses. For VMware, compact the hard drive and then export as an OVA (if .ova isn't specified, it breaks the ova into several files))
- [ ] Upload VM images + checksums to [Google Drive](https://drive.google.com/drive/u/1/folders/19YF5F5b8AdcFprnW-1GSea97AqyhSPdz)
- [ ] Create the GitHub Release and include:
  - [ ] Google Drive download links  
  - [ ] Checksums  
  - [ ] Review generated release notes

Once published, the release is considered official.

### Post-Release

- [ ] Make an announcement in the `#tools-n-tech` channel in the Trace Labs Discord
- [ ] Monitor early user feedback.
- [ ] Log any discovered issues for the next cycle.
- [ ] Confirm next quarterly planning meeting and release owner
