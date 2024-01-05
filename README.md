![Image](https://github.com/Apollo-o/tlosint-vm/assets/22546578/db6e5343-c08c-4ab1-8a1e-41112f80e18f)
[![Version](https://img.shields.io/badge/tlosintvm-1.0.0-brightgreen.svg?maxAge=259200)]()
![event workflow](https://github.com/tracelabs/tlosint-vm/actions/workflows/releases.yml/badge.svg?event=push)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Github All Releases](https://img.shields.io/github/downloads/tracelabs/tlosint-vm/total.svg)]()

# Introduction
The repository includes a recipe file to build a Linux OSINT Distribution for Trace Labs based on the Kali Linux kali-vm script - https://gitlab.com/kalilinux/build-scripts/kali-vm

## Releases
https://github.com/tracelabs/tlosint-vm/releases

## SHA256 Checksums:
``` 
tl-osint-2023.01-virtualbox-amd64.7z   996EE74CB6D8C4FF130A4F05DE037E267590932E1E0EF35714505444219CF845
tl-osint-2023.01-vmware-amd64.7z       F57DA9EA6BC42D5A101A6BA99CC59EEF89968827AC1B1DB1B5331E2586574F15
tlosint-vm-2023.1-beta.zip             C8BC07596DB6E1D3CF1CA4A1C9C5F838FAEDD2B39081877D2EEAC8910DACA928
tlosint-vm-2023.1-beta.tar.gz          A44C4822B298B81DE8EB7D0857F1E706DA135337ACEDAE67F67C6438148C95FC
```

<<<<<<< HEAD
=======
## Login Credentials
`osint`
`osint`

## Obsidian
Note taking app Obsidian comes bundled with the VM. There is an icon on the desktop to launch Obisidian or you can run the appimage located in the home directory. We've already set up a vault for you called "TL Vault" that lives on the Desktop. The first time you run Obsidian open that vault folder. The default theme is the Trace Labs theme. 
 
>>>>>>> 942d06e... Removed Tor config, doesn't allow policies.json
## Build
From a Kali Linux machine run the following commands:
```
git clone https://github.com/tracelabs/tlosint-vm
sudo apt -y install debos p7zip qemu-utils zerofree
cd tlosint-vm
chmod +x scripts/tl/*.sh
chmod +x scripts/*.sh
chmod +x *.sh
sudo ./build.sh
Locate the OVA in the images/ directory
```
## Applications

**Reporting**
* [TJ Null's OSINT Joplin template](https://github.com/tjnull/TJ-OSINT-Notebook)

**Browsers**
* [Firefox ESR](https://www.mozilla.org/en-US/firefox/enterprise/)
* [Tor Browser](https://www.torproject.org/download/)

**Data Analysis**
* [DumpsterDiver](https://github.com/securing/DumpsterDiver)
* [Exifprobe](https://github.com/hfiguiere/exifprobe)
* [Stegosuite](https://github.com/osde8info/stegosuite)

**Domains**
* [Domainfy (OSRFramework)](https://github.com/i3visio/osrframework)
* [Sublist3r](https://github.com/aboul3la/Sublist3r)

**Downloaders**
* [Browse Mirrored Websites](http://www.httrack.com/)
* [Metagoofil](https://github.com/opsdisk/metagoofil)
* [WebHTTrack Website Copier](http://www.httrack.com/)
* [Youtube-DL](https://github.com/ytdl-org/youtube-dl)

**Email**
* [Checkfy (OSRFramework)](https://github.com/i3visio/osrframework)
* [Infoga](https://github.com/m4ll0k/Infoga)
* [Mailfy (OSRFramework)](https://github.com/i3visio/osrframework)
* [theHarvester](https://github.com/laramies/theHarvester)
* [h8mail](https://github.com/khast3x/h8mail)

**Frameworks**
* [Little Brother](https://github.com/lulz3xploit/LittleBrother) (Archived)
* [OSRFramework](https://github.com/i3visio/osrframework)
* [sn0int](https://github.com/kpcyrd/sn0int)
* [Spiderfoot](https://github.com/smicallef/spiderfoot)
* [Maltego](https://www.maltego.com/downloads/)
* [OnionSearch](https://github.com/megadose/OnionSearch)

**Phone Numbers**
* [Phonefy (OSRFramework)](https://github.com/i3visio/osrframework)
* [PhoneInfoga](https://github.com/sundowndev/phoneinfoga)

**Social Media**
* [Instaloader](https://github.com/instaloader/instaloader)
* [Twint](https://github.com/twintproject/twint) (Archived)
* [Searchfy (OSRFramework)](https://github.com/i3visio/osrframework)
* [Tiktok Scraper](https://github.com/drawrowfly/tiktok-scraper)
* [Twayback](https://github.com/humandecoded/twayback)
* [Stweet](https://github.com/markowanga/stweet)

**Usernames**
* [Alias Generator (OSRFramework)](https://github.com/i3visio/osrframework)
* [Sherlock](https://github.com/sherlock-project/sherlock)
* [Usufy (OSRFramework)](https://github.com/i3visio/osrframework)

**Other Tools**
* [Photon](https://github.com/s0md3v/Photon)
* [Shodan](https://cli.shodan.io/)
* [Joplin](https://joplinapp.org/help/)

## Configuration Settings
**Firefox**
* Delete cookies/history on shutdown
* Block geo tracking
* Block mic/camera detection
* Block Firefox tracking
* Preload OSINT Bookmarks

## Contributing
Are you interested in the VM development? Join us on [Discord](https://discord.com/invite/tracelabs) in #osint-vm channel.
