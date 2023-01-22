# Trace Labs Kali Linux build configuration 

## Overview
The repository includes a recipe file to build a Linux OSINT Distribution for Trace Labs based on the Kali Linux kali-vm script (https://gitlab.com/kalilinux/build-scripts/kali-vm).

https://www.tracelabs.org/initiatives/osint-vm

## How to download/build

Download - You may download the latest version in GitHub https://github.com/tracelabs/tlosint-vm/releases
Build -
```From a Kali Linux machine run the following commands:
git clone https://github.com/tracelabs/tlosint-vm
sudo apt -y install debos p7zip qemu-utils zerofree
cd tlosint-vm
chmod +x scripts/tl/*.sh
chmod +x scripts/*.sh
chmod +x *.sh
sudo ./build.sh
Locate the OVA in the images/ directory

## Applications included in the build 

**Browsers**
* Firefox ESR
* Tor Browser

**Data Analysis**
* DumpsterDiver
* Exifprobe
* Exifscan
* Stegosuite

**Domains**
* Domainfy (OSRFramework)
* Sublist3r

**Downloaders**
* Browse Mirrored Websites
* Metagoofil
* Spiderpig
* WebHTTrack Website Copier
* Youtube-DL

**Email**
* Buster
* Checkfy (OSRFramework)
* Infoga
* Mailfy (OSRFramework)
* theHarvester
* h8mail

**Frameworks**
* Little Brother
* OSRFramework
* sn0int
* Spiderfoot
* Maltego
* OnionSearch

**Phone Numbers**
* Phonefy (OSRFramework)
* PhoneInfoga

**Social Media**
* Instaloader
* Twint
* Searchfy (OSRFramework)
* Tiktok Scraper
* Twayback

**Usernames**
* Alias Generator (OSRFramework)
* Sherlock
* Usufy (OSRFramework)

**Other tools
* Photon
* Sherlock
* Shodan

## Configuration Settings
**Firefox**
* Delete cookies/history on shutdown
* Block geo tracking
* Block mic/camera detection
* Block Firefox tracking
* Preload OSINT Bookmarks
