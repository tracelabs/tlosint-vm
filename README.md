![Image](https://github.com/user-attachments/assets/7d73ef43-25c0-47a7-bff9-be1109cea1b9)
[![Version](https://img.shields.io/badge/tlosintvm-1.0.0-brightgreen.svg?maxAge=259200)]()
![event workflow](https://github.com/tracelabs/tlosint-vm/actions/workflows/releases.yml/badge.svg?event=push)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Github All Releases](https://img.shields.io/github/downloads/tracelabs/tlosint-vm/total.svg)]()

# Maintainer Notes

This repository is actively maintained by Trace Labs staff.

- **Contributing:** PRs are welcome. Please read [CONTRIBUTING.md](./docs/CONTRIBUTING.md) before opening a PR.
- **Issues:** To recommend a tool, report a bug, or share feedback, [open an issue](https://github.com/tracelabs/tlosint-vm/issues/new/choose).
- **Code of conduct:** We follow the [Contributor Covenant](CODE_OF_CONDUCT.md). By participating, you agree to uphold it.


# Introduction

The repository includes a [recipe file](./tlosint.yaml) to build a Linux OSINT Distribution for Trace Labs based on the Kali Linux kali-vm script - <https://gitlab.com/kalilinux/build-scripts/kali-vm>

# Using the VM

## Option 1: Download the prebuilt Full Trace Labs OSINT VM

Use this if you just want to import and go.

- **Minimal Build (no tools) Releases (canonical):**  
  - https://github.com/tracelabs/tlosint-vm/releases (2026.05 VM release)

- **Full Build Releases (includes pre-installed OSINT tools)**
  - [**Click here to download the VirtualBox OVA**](https://vm-downloads.tracelabs.org/2026.5/tl-osint-2026.5-vbox-amd64-full.ova) (2026.05 VM Release)
  - [**Click here to download the VMware OVA**](https://vm-downloads.tracelabs.org/2026.5/tl-osint-2026.5-vmware-amd64-full.ova) (2026.05 VM Release)
  - [**Click here to download the ARM64 qcow2 release supporting Apple silicon**](https://vm-downloads.tracelabs.org/2026.5/tl-osint-2026.5-arm64-full.qcow2) (2026.05 VM Release)

 
- **Checksums:**  
  - VMware: `d078731e2940e670bdf5af5c20d9602bdbbb0680df59a80259048b2cdcbf078a`  
  - VirtualBox: `7377109bad57162d45f76c9892305b09897d4a925cfb9db1688e2ca12f0d4187`
  - Apple Silicon (qcow2): `a718a38acac863443eeecaaf000cb598fc881f887a2e3b22bde6c5c52ee3b0ab`

### Verify integrity

  ```bash
  # Linux/macOS
  sha256sum <downloaded-file>.ova

  # Windows (PowerShell)
  Get-FileHash .\<downloaded-file>.ova -Algorithm SHA256
  ```

### Import the VM

- **VirtualBox:** File → Import Appliance… → select `.ova`
- **VMware (Workstation/Player/Fusion):** File → Open… → select `.ova`

**Default login**  

username: `osint`
password: `osint`

---

## Option 2: Customize your own system with our tools script

Use this option if you want to start with your own base OS and then install OSINT tools and apply Firefox hardening on demand.

> **Note:** [`tlosint-tools.sh`](https://raw.githubusercontent.com/tracelabs/tlosint-vm/main/scripts/tlosint-tools.sh) is a **standalone script** that is not part of the VM build process. It's designed to be downloaded and run manually by end-users on any Kali or Debian-based system to install OSINT tools on-demand. This keeps the VM image size small while giving users flexibility to customize their toolset.

> **Download the raw file, not the GitHub "blob" page.**

```bash
# Inside Kali (or other Debian-based OS)
cd ~/Desktop  # or any folder you prefer

# Fetch the script (RAW URL)
wget https://raw.githubusercontent.com/tracelabs/tlosint-vm/main/scripts/tlosint-tools.sh

# Give the script executable permission
chmod +x tlosint-tools.sh

# Execute the script
./tlosint-tools.sh
```

### What the script does

- Refreshes the **Debian archive keyring** and applies updates
- Installs a curated **OSINT toolset** (Shodan CLI, Sherlock, PhoneInfoga, SpiderFoot, sn0int, Metagoofil, Sublist3r, steghide/stegseek, StegOSuite, exiftool, tor, torbrowser-launcher, translate-shell, etc.)
- Adds a **Self-Heal & Update** shortcut to the Desktop
- Applies **Firefox hardening** (delete cookies/history on shutdown, block geolocation/mic/camera prompts by default, stronger tracking protection, preload OSINT bookmarks)

---

## Releases

Releases follow a **scheduled cadence**.
Releases are owned by assigned maintainers—usually Trace Labs staff.
Release owners and timelines are proposed and confirmed during our quarterly planning meetings.

See [RELEASES.md](./docs/RELEASES.md) for more details.

## About the releases

Releases are pre-built VM images you can import into VirtualBox or VMware. They are built from the `main` branch of this repo. The source here is the "recipe" for the VM; you can build your own or inspect how it was made.

After downloading a release, import it into your hypervisor. See [Releases](https://github.com/tracelabs/tlosint-vm/releases).

## Login Credentials

`osint`
`osint`

## Obsidian

Note taking app Obsidian comes bundled with the VM. There is an icon on the desktop to launch Obisidian or you can run the appimage located in the home directory. We've already set up a vault for you called "TL Vault" that lives on the Desktop. The first time you run Obsidian open that vault folder. The default theme is the Trace Labs theme.

## Build

If you'd rather build your own from source or modify the version we've released then building your own is fairly straight forward. (Note: You don't need to do this if you've already downloaded a release and imported to hypervisor)

We highly reccommend that you do your build in Docker. This assumes that you already have Docker installed on your system and that you are running the build on an Intel based chip.

With that in mind you can:

```sh
git clone https://github.com/tracelabs/tlosint-vm
cd tlosint-vm
chmod +x build-in-container.sh
./build-in-container.sh
```

You can explore the different build options with `-h` flag.

## Applications

The majority of OSINT tools no longer come pre-packaged with the VM. There is an option to download them via a helper script. This keeps the size of the release small enough to build and host on GitHub.

**Note:** The `tlosint-tools.sh` script is a **standalone utility** that is not executed during the VM build process. It's provided as a convenience script for users who want to install OSINT tools on-demand after importing the VM.

If you want to install the tools using our helper script, run the `tlosint-tools.sh` script found in the `scripts/` folder:

- Open a terminal.
- From the repository root (or wherever you saved the script), make it executable and run:

```bash
chmod +x scripts/tlosint-tools.sh
./scripts/tlosint-tools.sh
```

- From the repository root (or wherever you saved the script), make it executable and run it:

```bash
chmod +x scripts/tlosint-tools.sh
./scripts/tlosint-tools.sh
```

**Resources**

- [Trace Labs OSINT Field Manual](https://github.com/tracelabs/tofm/blob/main/tofm.md)
- [Trace Labs CTF Participant Guide](https://tracelabs.org/participant-guide)
- [Categories & Scoring System](https://tracelabs.org/searchparty-scoring)

**Reporting**

- [TJ Null's OSINT Joplin template](https://github.com/tjnull/TJ-OSINT-Notebook)
- [Owlculus](https://github.com/be0vlk/owlculus)

**Browsers**
  
- [Brave Browser](https://brave.com/download/)
- [Firefox ESR](https://www.mozilla.org/en-US/firefox/enterprise/)
- [Tor Browser](https://www.torproject.org/download/)

**Browser Extensions**

- [OSINT Forensics Full Screen Capture](https://chromewebstore.google.com/detail/forensic-osint-full-page/jojaomahhndmeienhjihojidkddkahcn?pli=1)

**Data Analysis**

- [DumpsterDiver](https://github.com/securing/DumpsterDiver)
- [Exifprobe](https://github.com/hfiguiere/exifprobe)
- [Stegosuite](https://github.com/osde8info/stegosuite)

**Domains**

- [Domainfy (OSRFramework)](https://github.com/i3visio/osrframework)
- [Sublist3r](https://github.com/aboul3la/Sublist3r)

**Downloaders**

- [Browse Mirrored Websites](http://www.httrack.com/)
- [Metagoofil](https://github.com/opsdisk/metagoofil)
- [WebHTTrack Website Copier](http://www.httrack.com/)
- [Youtube-DL](https://github.com/ytdl-org/youtube-dl)

**Email**

- [Checkfy (OSRFramework)](https://github.com/i3visio/osrframework)
- [Infoga](https://github.com/m4ll0k/Infoga)
- [Mailfy (OSRFramework)](https://github.com/i3visio/osrframework)
- [theHarvester](https://github.com/laramies/theHarvester)
- [h8mail](https://github.com/khast3x/h8mail)

**Frameworks**

- [Little Brother](https://github.com/lulz3xploit/LittleBrother) (Archived)
- [OSRFramework](https://github.com/i3visio/osrframework)
- [sn0int](https://github.com/kpcyrd/sn0int)
- [Spiderfoot](https://github.com/smicallef/spiderfoot)
- [Maltego](https://www.maltego.com/downloads/)
- [OnionSearch](https://github.com/megadose/OnionSearch)

**Phone Numbers**

- [Phonefy (OSRFramework)](https://github.com/i3visio/osrframework)
- [PhoneInfoga](https://github.com/sundowndev/phoneinfoga)

**Social Media**

- [Instaloader](https://github.com/instaloader/instaloader)
- [Twint](https://github.com/twintproject/twint) (Archived)
- [Searchfy (OSRFramework)](https://github.com/i3visio/osrframework)
- [Tiktok Scraper](https://github.com/drawrowfly/tiktok-scraper)
- [Twayback](https://github.com/humandecoded/twayback)
- [Stweet](https://github.com/markowanga/stweet)

**Usernames**

- [Alias Generator (OSRFramework)](https://github.com/i3visio/osrframework)
- [Usufy (OSRFramework)](https://github.com/i3visio/osrframework)

**Other Tools**

- [Photon](https://github.com/s0md3v/Photon)
- [Sherlock](https://github.com/sherlock-project/sherlock)
- [Shodan](https://cli.shodan.io/)
- [Joplin](https://joplinapp.org/help/)

## Configuration Settings

**Firefox**

- Delete cookies/history on shutdown
- Block geo tracking
- Block mic/camera detection
- Block Firefox tracking
- Preload OSINT Bookmarks

## Contributing

PRs are welcome; please target the `dev` branch and read [CONTRIBUTING.md](./docs/CONTRIBUTING.md). This project is licensed under [GPL-3.0](LICENSE).
