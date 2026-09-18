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

### maigret
> Check a username against 3000+ sites and build a structured dossier, not just a hit list

**Type:** `CLI` `Python` | **Use cases:** username search, account discovery, cross-platform profiling

```bash
maigret <username>                    # console report
maigret <username> --html             # browsable HTML dossier
maigret <username> --top-sites 500    # faster pass over the busiest sites
```

> [!tip] Tips
> Broader than Sherlock — run both. `--html` writes a report you can attach to case notes. Add `--no-progressbar` when piping output to a file.

[📄 Documentation](https://github.com/soxoj/maigret)

---

### WhatsMyName
> Username enumeration driven by the community-maintained WhatsMyName dataset

**Type:** `CLI` `Python` | **Use cases:** username search, account discovery

```bash
whatsmyname -u <username>
whatsmyname -u <username> --html      # write an HTML report
```

> [!tip] Tips
> Pulls the WebBreacher site list at runtime, so coverage stays current without reinstalling the tool. Good cross-check when maigret and Sherlock disagree.

[📄 Documentation](https://github.com/C3n7ral051nt4g3ncy/WhatsMyName-Python)

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

### Tesseract OCR
> Pull text out of images — screenshots, signs in photos, scanned documents

**Type:** `CLI` | **Use cases:** OCR, text from screenshots, signage in photos, scanned documents

```bash
tesseract image.png out && cat out.txt   # writes out.txt
tesseract image.png -                    # print straight to stdout
```

> [!tip] Tips
> Accuracy depends heavily on image quality — crop to the text and increase contrast first. Useful for reading usernames or phone numbers baked into a screenshot.

[📄 Documentation](https://tesseract-ocr.github.io)

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

## 📱 Social Platforms

### Instaloader
> Download Instagram posts, stories, tagged media, and follower lists

**Type:** `CLI` `Python` | **Use cases:** Instagram collection, post archiving, follower lists, story capture

```bash
instaloader profile <handle>                  # posts + profile pic
instaloader --no-posts --stories <handle>     # stories only (needs login)
instaloader --login <you> <handle>            # authenticated session
```

> [!warning] OPSEC
> Logging in ties the collection to that account. Use a research account, never a personal one.

[📄 Documentation](https://instaloader.github.io)

---

### GHunt
> Turn a Gmail address into Google activity — Maps reviews, Photos, Calendar, YouTube

**Type:** `CLI` `Python` | **Use cases:** Gmail-to-identity mapping, Google Maps reviews, Photos, Calendar

```bash
ghunt login                    # one-time browser cookie import
ghunt email <address>
ghunt gaia <gaia-id>
ghunt drive <file-or-folder-id>
```

> [!warning] Requires credentials
> GHunt does nothing until `ghunt login` imports cookies from a signed-in Google session. Use a research account. Until then the VM validator reports GHunt as "login deferred" — that is expected, not a broken install.

[📄 Documentation](https://github.com/mxrch/GHunt)

---

## 🎥 Media & Capture

### yt-dlp
> Download video and audio from YouTube, TikTok, X, Instagram, Facebook, and hundreds more

**Type:** `CLI` `Python` | **Use cases:** video download, evidence capture, audio extraction, metadata

```bash
yt-dlp <url>                              # best quality, merged
yt-dlp -F <url>                           # list available formats
yt-dlp --write-info-json --no-download <url>   # metadata only, no media
```

> [!tip] Tips
> ffmpeg is installed, so yt-dlp merges the best separate video and audio streams automatically. `--write-info-json` captures upload time, uploader ID, and description — often more useful for an investigation than the video itself.

[📄 Documentation](https://github.com/yt-dlp/yt-dlp)

---

### gallery-dl
> Bulk-download image galleries and media from social and image-hosting sites

**Type:** `CLI` `Python` | **Use cases:** image galleries, bulk media download, social media images

```bash
gallery-dl <url>
gallery-dl --write-metadata <url>     # save per-file JSON metadata
gallery-dl -g <url>                   # print direct media URLs only
```

> [!tip] Tips
> Complements yt-dlp: yt-dlp for video, gallery-dl for image sets. `--write-metadata` preserves the post context alongside each file.

[📄 Documentation](https://github.com/mikf/gallery-dl)

---

### Streamlink
> Capture live streams to disk before they disappear

**Type:** `CLI` `Python` | **Use cases:** live stream capture, real-time evidence, time-sensitive collection

```bash
streamlink <url> best -o capture.ts
streamlink <url> --json                # list available streams
```

> [!tip] Tips
> Live content is the most perishable evidence there is — start the capture first and sort out quality later. Uses ffmpeg for muxing.

[📄 Documentation](https://streamlink.github.io)

---

### FFmpeg
> Convert, trim, and extract frames from video and audio

**Type:** `CLI` | **Use cases:** video conversion, frame extraction, audio extraction, trimming

```bash
ffmpeg -i in.mp4 -ss 00:01:30 -t 10 clip.mp4   # 10s clip from 1:30
ffmpeg -i in.mp4 -vf fps=1 frame_%04d.png      # one frame per second
ffmpeg -i in.mp4 -vn -acodec copy audio.m4a    # strip audio track
```

> [!tip] Tips
> Also the dependency that lets yt-dlp and Streamlink merge separate video and audio streams. Extracting frames makes a video reverse-image-searchable.

[📄 Documentation](https://ffmpeg.org/documentation.html)

---

### gowitness
> Bulk-screenshot a list of URLs so many leads can be triaged at once

**Type:** `CLI` `Go` | **Use cases:** bulk screenshots, lead triage, profile URL sweeps

```bash
gowitness scan single --url <url>
gowitness scan file -f urls.txt          # one URL per line
gowitness report server                  # browse results in a local web UI
```

> [!tip] Tips
> Point it at a list of candidate profile URLs from a username search and review the screenshots instead of opening tabs one by one. Drives the system Chromium.

[📄 Documentation](https://github.com/sensepost/gowitness)

---

## 🗄 Archiving

### auto-archiver
> Archive a social post with screenshot, metadata, and content hash in one command

**Type:** `CLI` `Docker` | **Use cases:** social post archiving, evidence integrity, hashed captures

```bash
auto-archiver --help
# Your current directory is mounted at /data inside the container.
auto-archiver --config /data/orchestration.yaml
```

> [!tip] Tips
> Runs as a Docker container, so paths must be relative to `/data`. The content hash it records is what makes the capture defensible later.

[📄 Documentation](https://github.com/bellingcat/auto-archiver)

---

### monolith
> Freeze a live page into one self-contained HTML file — images, CSS, and JS inlined

**Type:** `CLI` `Rust` | **Use cases:** page snapshots, offline evidence, profile freezing

```bash
monolith <url> -o profile.html
monolith -j <url> -o profile.html    # exclude JavaScript
```

> [!tip] Tips
> One file, no external requests when reopened — much stronger evidence than a screenshot because the page text stays searchable and selectable.

[📄 Documentation](https://github.com/Y2Z/monolith)

---

### internetarchive (`ia`)
> Search, download from, and submit pages to the Internet Archive

**Type:** `CLI` `Python` | **Use cases:** Wayback retrieval, archive submission, durable storage

```bash
ia search '<query>'
ia download <identifier>
ia configure                     # optional: log in for uploads
```

> [!tip] Tips
> Check the Wayback Machine before assuming deleted content is gone. Submitting a live URL creates a third-party timestamped copy you do not control — useful corroboration.

[📄 Documentation](https://archive.org/services/docs/api/internetarchive/)

---

### Carbon14
> Estimate when web content was actually published or last changed

**Type:** `CLI` `Python` | **Use cases:** content dating, timeline building, claim verification

```bash
carbon14 <url>
```

> [!tip] Tips
> Useful when a post has no visible timestamp, or when the displayed date looks wrong. Treat the result as evidence for a timeline, not proof on its own.

[📄 Documentation](https://github.com/Lazza/Carbon14)

---

### HTTrack
> Mirror an entire website locally for offline review

**Type:** `CLI` `GUI` | **Use cases:** site mirroring, offline review, bulk page capture

```bash
httrack <url> -O ./mirror
webhttrack                        # GUI front-end
```

> [!tip] Tips
> Set a depth limit on large sites or the mirror will run for a very long time. Best for small sites and forum threads.

[📄 Documentation](https://www.httrack.com/html/index.html)

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

## 🛡 Investigator OPSEC

### mat2
> Strip metadata from files before you share or submit them

**Type:** `CLI` `Python` | **Use cases:** metadata removal, safe file sharing, OPSEC hygiene

```bash
mat2 --show evidence.jpg        # see what metadata is present
mat2 evidence.jpg              # writes evidence.cleaned.jpg
mat2 --inplace evidence.jpg     # overwrite the original
```

> [!warning] OPSEC
> Anything you produce on this VM may carry your own metadata — usernames, paths, software versions. Run `--show` before sending a file outside the team.

[📄 Documentation](https://0xacab.org/jvoisin/mat2)

---

### shred
> Overwrite a file's contents before deleting it

**Type:** `CLI` | **Use cases:** secure deletion, disposing of sensitive downloads

```bash
shred -u <file>            # overwrite, then remove
shred -u -n 3 <file>       # three passes
```

> [!tip] Tips
> Part of coreutils, already present. Note that on SSDs and copy-on-write filesystems overwriting in place is not guaranteed — full-disk encryption is the real protection.

[📄 Documentation](https://www.gnu.org/software/coreutils/manual/html_node/shred-invocation.html)

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
