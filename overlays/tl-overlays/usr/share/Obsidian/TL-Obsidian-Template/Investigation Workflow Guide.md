---
tags:
  - trace-labs
  - reference
  - workflow
pinned: true
---

# 🔁 Investigation Workflow Guide
*Trace Labs OSINT VM — Pivot Guide*

← Back to [[OSINT Resources]] | See also: [[VM Tool Reference]]

> [!info] How to use this guide
> Find the data type you currently have, then follow the numbered pivot steps. `VM Tool` = installed on the Trace Labs VM. `Web Resource` = external browser tool.

---

## 👤 Identity

### You have a Full Name

> A name alone is a starting point, not an answer. Narrow it down using location context, age, associated usernames, and photos. Prioritize platforms where your subject is most likely active based on age group and region.

**Step 1 — Search Google with operators**
Start broad, then add context to isolate the right person. Combine name with city, school, employer, or hobby.
- `Web Resource`: Google
- [Google Operators Cheatsheet](https://ahrefs.com/blog/google-advanced-search-operators/)

**Step 2 — Search social platforms directly**
Google doesn't always index private profiles. Search Facebook, LinkedIn, Instagram, TikTok, and X directly.
- `Web Resource`: Facebook, LinkedIn, Instagram
- [Facebook People Search](https://www.facebook.com/people-search)

**Step 3 — People aggregator sites**
Run the name through aggregators to surface addresses, relatives, phone numbers, and age data.
- `Web Resource`: TruthFinder, Spokeo, Intelius
- [IntelTechniques People Search](https://inteltechniques.com/tools/People.html)

**Step 4 — Reverse image search**
If you have a photo, run reverse image searches to find other profiles or appearances.
- `Web Resource`: PimEyes, Google Lens, TinEye

> [!example] 🚩 Flag Opportunities
> Current/last known location, social media profiles, employer, associates, vehicle.

---

## 🌐 Online Presence

### You have a Username / Handle

> Usernames are one of the most powerful pivots — people reuse handles across platforms without realizing it creates a cross-platform identity trail. Even slight variations (adding numbers, underscores) are worth checking.

**Step 1 — Run Sherlock across 300+ platforms**
The fastest way to find all accounts using this exact username. Save the output and check each hit manually.
- `VM Tool`: [[VM Tool Reference#Sherlock|Sherlock]]
- [Sherlock docs](https://github.com/sherlock-project/sherlock)

**Step 2 — Check username variants**
Try common variations: add/remove numbers, dots, underscores, or append birth year.
- `VM Tool`: [[VM Tool Reference#Sherlock|Sherlock]]
- `Web Resource`: [WhatsMyName](https://whatsmyname.app)

**Step 3 — Search the username as a keyword**
Google the username in quotes. It may appear in forum posts, old profiles, or comments that Sherlock won't catch.
- `Web Resource`: Google

**Step 4 — Check for linked accounts**
Once you find one active profile, look at the bio/about section for links to other accounts or email hints.
- `VM Tool`: [[VM Tool Reference#sn0int|sn0int]]
- [OSINT Framework](https://osintframework.com/)

> [!example] 🚩 Flag Opportunities
> New/active social profiles, username on dark web forums, linked email addresses, location hints in bio or posts.

---

### You have a Social Media Profile

> An active social profile is a goldmine. Work it systematically: who they follow, who follows them, what they post, where they tag themselves. Archive everything before it disappears.

**Step 1 — Archive the profile immediately**
Profiles can be deleted or set to private at any time. Preserve evidence with a hash.
- `VM Tool`: [[VM Tool Reference#Forensic OSINT Full Page Screen Capture|Forensic Screen Capture]]
- `Web Resource`: [Archive.today](https://archive.ph), [Wayback Machine](https://web.archive.org)

**Step 2 — Map followers and following**
Identify close associates, family members, and significant others. They may have more recent information.
- `VM Tool`: [[VM Tool Reference#SpiderFoot|SpiderFoot]]

**Step 3 — Analyze post content and timing**
Look at post history for location tags, check-ins, workplace mentions, and timestamps. Establish a pattern of life.
- `VM Tool`: [[VM Tool Reference#Owlculus|Owlculus]]

**Step 4 — Extract linked accounts**
Bio links, pinned posts, and cross-platform mentions often reveal additional accounts.
- `VM Tool`: [[VM Tool Reference#Sherlock|Sherlock]], [[VM Tool Reference#sn0int|sn0int]]

> [!example] 🚩 Flag Opportunities
> Last post timestamp, location check-ins, tagged photos, associates found via followers, linked accounts.

---

### You have a Domain / Website

> A domain registration is a public record that can reveal a real name, address, email, phone number, or hosting provider. Even privacy-protected registrations leave fingerprints.

**Step 1 — Run WHOIS lookup**
Reveals registrant name, email, address, creation date, and registrar. Many people don't use WHOIS privacy on older domains.
- `VM Tool`: `whois <domain>`
- `Web Resource`: [who.is](https://who.is), [DomainTools](https://whois.domaintools.com)

**Step 2 — Find subdomains**
Subdomains may reveal additional services, blogs, or applications tied to the person.
- `VM Tool`: [[VM Tool Reference#Sublist3r|Sublist3r]]
- `Web Resource`: [crt.sh](https://crt.sh)

**Step 3 — Extract document metadata**
Files hosted on the domain (PDFs, Word docs) may contain author names, internal paths, and software details.
- `VM Tool`: [[VM Tool Reference#Metagoofil|Metagoofil]]

**Step 4 — Check historical snapshots**
The Wayback Machine may have snapshots from before privacy was enabled, revealing original contact information.
- `Web Resource`: [Wayback Machine](https://web.archive.org)

> [!example] 🚩 Flag Opportunities
> Registrant real name/address, author metadata from documents, associated email address, historical content.

---

## 📞 Contact Info

### You have an Email Address

> Email addresses are high-value because they're used as account identifiers across virtually every platform. Even a partial address can yield account confirmation if tested carefully.

**Step 1 — Check breach databases**
Run the email through breach lookup tools. Leaked data often reveals passwords, usernames, and registration details.
- `Web Resource`: [HaveIBeenPwned](https://haveibeenpwned.com), [Dehashed](https://dehashed.com)

**Step 2 — Reverse search to find linked profiles**
Many platforms allow searching by email. Also try Googling the email in quotes.
- `Web Resource`: [Holehe](https://github.com/megadose/holehe), Google

**Step 3 — Extract the username prefix**
The part before the @ is often the same username the person uses elsewhere. Pivot to username workflow above.
- `VM Tool`: [[VM Tool Reference#Sherlock|Sherlock]]

**Step 4 — Domain intelligence (for custom domains)**
If the email uses a custom domain (not Gmail/Yahoo), look up the domain registration for name and address data.
- `VM Tool`: `whois`, [[VM Tool Reference#Sublist3r|Sublist3r]]
- `Web Resource`: [who.is](https://who.is)

> [!example] 🚩 Flag Opportunities
> Account registrations, physical address from breach data, associated usernames, employer from domain.

---

### You have a Phone Number

> Phone numbers can confirm identity, reveal carrier/region, and surface linked accounts on messaging apps and social platforms. Always try both national and E.164 international formats.

**Step 1 — Run PhoneInfoga for carrier and region**
Identifies carrier, country/region, line type (mobile vs landline), and scans OSINT sources automatically.
- `VM Tool`: [[VM Tool Reference#PhoneInfoga|PhoneInfoga]]

**Step 2 — Reverse lookup aggregators**
Check Truecaller, Sync.me, and NumLookup for name and carrier data.
- `Web Resource`: [Truecaller](https://www.truecaller.com), [NumLookup](https://www.numlookup.com)

**Step 3 — Check messaging apps**
WhatsApp, Telegram, and Signal use phone numbers as IDs. Searching or adding the number can reveal a profile photo or name.
- `Web Resource`: WhatsApp, Telegram

**Step 4 — Google the number**
Search with and without country code, in different formats. It may appear in classifieds or public posts.
- `Web Resource`: Google

> [!example] 🚩 Flag Opportunities
> Carrier confirms region, WhatsApp profile photo, name from reverse lookup, messaging app activity.

---

## 📍 Location

### You have a Location / Address

> Location data narrows the search radius and opens pivots to local platforms, regional social groups, and geographic databases. Even a city name can yield meaningful intel when combined with other identifiers.

**Step 1 — Search local Facebook groups**
Missing person posts, local buy/sell groups, and community boards often have activity from the subject or sightings.
- `Web Resource`: Facebook

**Step 2 — Reverse geocode coordinates**
Convert GPS coordinates to a street address, then search for businesses or residences at that location.
- `Web Resource`: [Google Maps](https://maps.google.com), [What3Words](https://what3words.com)
- [Reverse Geocode Tool](https://www.latlong.net/lat-long-to-address.html)

**Step 3 — Search geo-tagged social posts**
Instagram, Twitter/X, and Snapchat allow location-based searches. Look for posts from around the time of disappearance.
- `Web Resource`: [Snap Map](https://map.snapchat.com), [Twitter Advanced Search](https://twitter.com/search-advanced)

**Step 4 — Property and public records**
US addresses can be cross-referenced with county assessor records, voter rolls, and business registrations.
- `Web Resource`: [OpenCorporates](https://opencorporates.com), [Black Book Online](https://www.blackbookonline.info)

> [!example] 🚩 Flag Opportunities
> Last known address confirmed, employer location, new sighting via geo-tagged post, vehicle registered at address.

---

## 🖼 Media

### You have a Photo / Image

> Images carry two types of intelligence: hidden metadata (GPS, timestamps, device info) and visual content (face, location identifiers, context clues). Always extract EXIF first, then analyze the content.

**Step 1 — Extract EXIF metadata**
May contain GPS coordinates, exact timestamp, camera model, and software. GPS data is gold.
- `VM Tool`: [[VM Tool Reference#ExifTool|ExifTool]]

**Step 2 — Reverse image search (face search)**
PimEyes is the most powerful for facial recognition. Google Lens finds visually similar images. TinEye tracks exact copies.
- `Web Resource`: [PimEyes](https://pimeyes.com), [Google Lens](https://lens.google.com), [TinEye](https://tineye.com)

**Step 3 — Geolocate background details**
Look for street signs, landmarks, business names, or license plates visible in the photo. Confirm with Google Street View.
- `Web Resource`: Google Street View, [GeoHints](https://geohints.com)

**Step 4 — Check for steganographic data**
In CTF scenarios, data may be hidden inside the image file itself.
- `VM Tool`: [[VM Tool Reference#steghide|steghide]], [[VM Tool Reference#stegseek|stegseek]], [[VM Tool Reference#StegOSuite|StegOSuite]]

> [!example] 🚩 Flag Opportunities
> GPS coordinates from EXIF, timestamp of last photo, new social profiles found via face search, location from background.

---

## 🤝 Associates

### You have a Known Associate

> Associates are often the fastest path to locating a missing person — they may have more recent contact or unknowingly post information about the subject's whereabouts. Treat each associate as a mini-subject.

**Step 1 — Document the relationship**
Note how they're connected (tagged together, listed as relative, mutual followers).
- `VM Tool`: [[VM Tool Reference#Owlculus|Owlculus]]

**Step 2 — Check their profiles for subject mentions**
Search the associate's posts for the subject's name or username. Check photo tags for recent photos of the subject.
- `Web Resource`: Facebook Tag Search

**Step 3 — Map mutual connections**
Other mutual followers or friends may have information. Prioritize close relationships over loose online connections.
- `VM Tool`: [[VM Tool Reference#SpiderFoot|SpiderFoot]]

**Step 4 — Run the associate as a new lead**
Apply the full name/username/email workflows to the associate. Any information they reveal may indirectly locate the subject.
- `VM Tool`: [[VM Tool Reference#Sherlock|Sherlock]]

> [!example] 🚩 Flag Opportunities
> Associate posts recent photo of subject, location tag places subject in a specific area, associate's profile links to subject's new account.

---

*Trace Labs OSINT VM | To add a workflow, append a new section to this note.*
