![Image](https://github.com/Apollo-o/tlosint-vm/assets/22546578/db6e5343-c08c-4ab1-8a1e-41112f80e18f)
[![Version](https://img.shields.io/badge/tlosintvm-1.0.0-brightgreen.svg?maxAge=259200)]()
![event workflow](https://github.com/tracelabs/tlosint-vm/actions/workflows/releases.yml/badge.svg?event=push)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Github All Releases](https://img.shields.io/github/downloads/tracelabs/tlosint-vm/total.svg)]()

# Introduction
The repository includes a recipe file to build a Linux OSINT Distribution for Trace Labs based on the Kali Linux kali-vm script - https://gitlab.com/kalilinux/build-scripts/kali-vm

## Releases
These are pre-generated bundles that can either import in to Virtualbox or VMWare. They are generated with the code in the Main branch of this repo with no interference from us. The goal here is to produce a finished product but give the users insight in to the "recipe" used to build it. 

After you've downloaded the release that applies to you, it should be as simple as importing it in to your hypervisor. 

https://github.com/tracelabs/tlosint-vm/releases

## Login Credntials
`osint`
`osint`

## Obsidian
Note taking app Obsidian comes bundled with the VM. There is an icon on the desktop to launch Obisidian or you can run the appimage located in the home directory. We've already set up a vault for you called "TL Vault" that lives on the Desktop. The first time you run Obsidian open that vault folder. The default theme is the Trace Labs theme. 
 
## Build
If you'd rather build your own from source or modify the version we've released then building your own is as straight forward as: (Note: You don't need to do this if you've already downloaded a release and imported to hypervisor)

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

The majority of OSINT tools no longer come pre-packaged with the VM. There is an option to download them via a script on the desktop though. This keeps the size of the release small enough to build and host on Github. If you want to install the tools in the script then: 
- Open a terminal
- Navigate to the `Desktop` folder
- Execute the install script with `./install-tools.sh`

**Resources**
* [Trace Labs OSINT Field Manual](https://github.com/tracelabs/tofm/blob/main/tofm.md)
* [Trace Labs CTF Contestant Guide](https://download2.tracelabs.org/Trace-Labs-OSINT-Search-Party-CTF-Contestant-Guide_v1.pdf)

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
