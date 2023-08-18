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
August 2023 Release: tl-osint-2023.03-virtualbox-amd64.ova 3100c8490dea3c88f5a6625466edac6091fa7ab331e1bb7b9997d1d39ff9c313
August 2023 Release: tl-osint-2023.03-vmware-amd64.7z 290c335448573de553ab7b4106309dc3b8a10a6f4e75937b5e4018db80874d36
tl-osint-2023.01-virtualbox-amd64.7z   996EE74CB6D8C4FF130A4F05DE037E267590932E1E0EF35714505444219CF845
tl-osint-2023.01-vmware-amd64.7z       F57DA9EA6BC42D5A101A6BA99CC59EEF89968827AC1B1DB1B5331E2586574F15
```
## Login Credntials
`osint`
`osint`
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

**Note**
* The majority of OSINT tools no longer come pre-packaged with the VM. There is an option to download them via a script on the desktop though. This keeps the size of the release small enough to build and host on Github.


**Reporting**
* [TJ Null's OSINT Joplin template](https://github.com/tjnull/TJ-OSINT-Notebook)

**Browsers**
* [Firefox ESR](https://www.mozilla.org/en-US/firefox/enterprise/)
* [Tor Browser](https://www.torproject.org/download/)

**Data Analysis**
* [DumpsterDiver](https://github.com/securing/DumpsterDiver)
* [Exifprobe](https://github.com/hfiguiere/exifprobe)
* [Exifscan](https://github.com/rcook/exifscan/) (Private)
* [Stegosuite](https://github.com/osde8info/stegosuite)

**Domains**
* [Domainfy (OSRFramework)](https://github.com/i3visio/osrframework)
* [Sublist3r](https://github.com/aboul3la/Sublist3r)

**Downloaders**
* [Browse Mirrored Websites](http://www.httrack.com/)
* [Metagoofil](https://github.com/opsdisk/metagoofil)
* [Spiderpig](https://github.com/hatlord/Spiderpig)
* [WebHTTrack Website Copier](http://www.httrack.com/)
* [Youtube-DL](https://github.com/ytdl-org/youtube-dl)

**Email**
* [Buster](https://github.com/sham00n/buster)
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
* [OnionSearch](https://github.com/sundowndev/phoneinfoga)

**Phone Numbers**
* [Phonefy (OSRFramework)](https://github.com/i3visio/osrframework)
* [PhoneInfoga](https://github.com/sundowndev/phoneinfoga)

**Social Media**
* [Instaloader](https://github.com/instaloader/instaloader)
* [Twint](https://github.com/twintproject/twint) (Archived)
* [Searchfy (OSRFramework)](https://github.com/i3visio/osrframework)
* [Tiktok Scraper](https://github.com/drawrowfly/tiktok-scraper)
* [Twayback](https://github.com/humandecoded/twayback)

**Usernames**
* [Alias Generator (OSRFramework)](https://github.com/i3visio/osrframework)
* [Sherlock](https://github.com/sherlock-project/sherlock)
* [Usufy (OSRFramework)](https://github.com/i3visio/osrframework)

**Other Tools**
* [Photon](https://github.com/s0md3v/Photon)
* [Sherlock](https://github.com/sherlock-project/sherlock)
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

PRs are welcome. We ask that you PR in to the Dev branch.
