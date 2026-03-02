---
tags:
  - trace-labs
  - reference
  - tools
pinned: true
---

# 🛠 VM Tool Reference
*Trace Labs OSINT VM — Search Party Edition*

← Back to [[OSINT Resources]] | See also: [[Investigation Workflow Guide]]

---

## 👤 People

### Sherlock
> Search for a username across 300+ social media sites simultaneously

**Type:** `CLI` `Python` | **Use cases:** username search, account discovery, social footprint

```bash
sherlock <username>
```

> [!tip] Tips
> Use `--print-found` to show only hits. Save results with `--output results.txt`. Add `--timeout 10` to skip slow sites.

[📄 Documentation](https://github.com/sherlock-project/sherlock)

---

### PhoneInfoga
> Look up phone numbers — carrier, region, reputation, and linked OSINT sources

**Type:** `CLI` `Web` | **Use cases:** phone number lookup, carrier identification, number reputation

```bash
phoneinfoga serve -p 8080
# Then open: http://localhost:8080

# Quick CLI scan:
phoneinfoga scan -n +1XXXXXXXXXX
```

> [!tip] Tips
> Starts a web UI at http://localhost:8080. For a quick scan without the UI use the CLI scan command above.

[📄 Documentation](https://sundowndev.github.io/phoneinfoga)

---

## 🔎 Recon

### sn0int
> Modular OSINT framework with a community registry of investigation modules

**Type:** `CLI` | **Use cases:** domain recon, username search, email discovery, subdomain enum

```bash
sn0int
```

> [!tip] Tips
> Opens an interactive shell. Type `help` to get started. Install modules with: `pkg install <module-name>`

[📄 Documentation](https://github.com/kpcyrd/sn0int)

---

### Sublist3r
> Find subdomains of a target domain using multiple search engines passively

**Type:** `CLI` `Python` | **Use cases:** subdomain discovery, domain recon, passive reconnaissance

```bash
sublist3r -d <domain.com>
sublist3r -d <domain.com> -o output.txt   # save results
sublist3r -d <domain.com> -b              # + brute force
```

> [!tip] Tips
> Use `-v` for verbose output. Add `-b` only when passive results are thin — it's noisier.

[📄 Documentation](https://github.com/aboul3la/Sublist3r)

---

### Metagoofil
> Find and extract metadata from public documents (PDFs, Word docs) on a target domain

**Type:** `CLI` `Python` | **Use cases:** document metadata, author names, email harvesting, software versions

```bash
metagoofil -d <domain.com> -t pdf,doc,xlsx -o output/
```

> [!tip] Tips
> Uses Google to find documents. Add `-l 20` to limit results and avoid rate limiting.

[📄 Documentation](https://github.com/laramies/metagoofil)

---

## 🖼 Images

### ExifTool
> Extract hidden metadata from images — GPS location, camera model, timestamps

**Type:** `CLI` | **Use cases:** GPS coordinates, camera info, timestamps, metadata extraction

```bash
exiftool <image.jpg>          # full dump
exiftool -gps:all <image.jpg> # GPS only
exiftool -all= <image.jpg>    # strip metadata
exiftool *.jpg                # batch process
```

> [!tip] Tips
> Always run this first on any image from the subject — GPS data is gold for location pivots.

[📄 Documentation](https://exiftool.org)

---

## 🔒 Steganography

### steghide
> Extract data hidden inside image or audio files (JPEG, BMP, WAV)

**Type:** `CLI` | **Use cases:** hidden data extraction, passphrase steg, steg analysis

```bash
steghide extract -sf <image.jpg>              # extract
steghide embed -cf image.jpg -ef secret.txt   # embed
```

> [!tip] Tips
> When prompted for a passphrase, try pressing Enter (blank) first. Works on JPEG, BMP, WAV, AU.

[📄 Documentation](https://steghide.sourceforge.net)

---

### stegseek
> Automatically crack steghide passphrases using a wordlist — extremely fast

**Type:** `CLI` | **Use cases:** passphrase cracking, CTF steg challenges, steghide brute force

```bash
stegseek <image.jpg> /usr/share/wordlists/rockyou.txt
```

> [!tip] Tips
> Only works on steghide-embedded files. Cracks most CTF challenges in under a second with rockyou.txt.

[📄 Documentation](https://github.com/RickdeJager/stegseek)

---

### StegOSuite
> Graphical tool for hiding and extracting data from image files

**Type:** `GUI` | **Use cases:** GUI steg analysis, image steganography, visual extraction

```bash
stegosuite
java -jar /opt/stegosuite/stegosuite.jar   # if above fails
```

> [!tip] Tips
> Supports BMP, GIF, JPG, PNG formats.

[📄 Documentation](https://github.com/osde8info/stegosuite)

---

## 🌐 Dark Web

### Tor Browser
> Browse anonymously and access .onion sites on the Tor network

**Type:** `GUI` | **Use cases:** anonymous browsing, .onion sites, identity protection

```bash
tor-browser
torsocks <command>   # route any CLI tool through Tor
```

> [!warning] OPSEC
> Never log into personal accounts while using Tor.

[📄 Documentation](https://www.torproject.org)

---

## 🛠 Utilities

### translate-shell
> Translate foreign text from the terminal — auto-detects language

**Type:** `CLI` | **Use cases:** language translation, foreign content, auto language detect

```bash
trans :en "text to translate here"   # translate to English
trans "bonjour monde"                 # auto-detect source
trans :en -i input.txt               # translate a file
```

[📄 Documentation](https://github.com/soimort/translate-shell)

---

## ⚙️ Frameworks

### SpiderFoot
> Automated OSINT tool that pulls from 200+ sources and maps relationships visually

**Type:** `CLI` `Web` | **Use cases:** automated OSINT, target profiling, relationship mapping

```bash
spiderfoot -l 127.0.0.1:5001
# Then open: http://127.0.0.1:5001
```

> [!tip] Tips
> Add API keys in Settings for richer results (Shodan, VirusTotal, etc.).

[📄 Documentation](https://www.spiderfoot.net/documentation)

---

### Owlculus
> Case management — keep subjects, notes, and evidence organized during a CTF

**Type:** `GUI` `Web` | **Use cases:** case management, evidence tracking, subject notes, CTF organization

```bash
cd /opt/owlculus && python3 app.py
```

> [!tip] Tips
> Perfect for Trace Labs CTFs with multiple missing persons subjects.

[📄 Documentation](https://github.com/be0vlk/owlculus)

---

## 🧩 Browser Extensions

### Forensic OSINT Full Page Screen Capture
> Capture full-page screenshots with timestamp, URL, and SHA-256 hash for evidence integrity

**Type:** `Browser Extension (Chromium)` | **Use cases:** evidence capture, forensic screenshots, hash verification

```
Install via Chrome Web Store → search "Forensic OSINT Full Page Screen Capture"
```

> [!warning] Essential for TL submissions
> The SHA-256 hash proves the screenshot hasn't been altered. Use this for every flag you submit.

[📄 Chrome Web Store](https://chrome.google.com/webstore/search/forensic+osint+full+page+screen+capture)

---

*Trace Labs OSINT VM | To add a tool, append a new section to this note.*
