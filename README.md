# Trace Labs Kali Linux build configuration 

## Overview
The repository includes a recipe file to build a Linux OSINT Distribution for Trace Labs based on the Kali Linux kali-vm script (https://gitlab.com/kalilinux/build-scripts/kali-vm).

https://www.tracelabs.org/initiatives/osint-vm

## How to download

You may download the latest version in GitHub https://github.com/tracelabs/tlosint-vm/releases

## How to Build
From a Kali Linux machine run the following commands:
```
git clone https://github.com/tracelabs/tlosint-vm
sudo apt -y install debos p7zip qemu-utils zerofree
cd tlosint-vm
```
either
```
./build-vbox.sh -z
```
 or 
 ```
 ./build-vmware.sh -z
 ```


You can also build inside of a Docker container. Make sure that your user is a memeber of the kvm group and then:
```
./build-in-container.sh -v (either ova or vmware) -z
```

Locate the file(s) in the images/ directory

## Applications can be installed after you start the VM

From inside a terminal in the VM
```cd ~/Desktop
sudo ~/Desktop/install-tools.sh
```


**Reporting**
* TJ Null's OSINT Joplin template

**Browsers**
* Firefox ESR
* Tor Browser
* Chromium

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
* YT-DLP

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
* Joplin
* Obsidian

## Configuration Settings
**Firefox**
* Delete cookies/history on shutdown
* Block geo tracking
* Block mic/camera detection
* Block Firefox tracking
* Preloaded OSINT Bookmarks
