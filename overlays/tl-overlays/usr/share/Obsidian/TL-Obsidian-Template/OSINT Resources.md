---
tags:
  - trace-labs
  - resources
  - bookmarks
  - osint-tools
date_updated: "{{DATE}}"
pinned: true
---

# OSINT Resources & Quick Launch

> [!tip] Pro Tip
> Pin this note in Obsidian (right-click → Pin) so it's always one click away during a competition.

---

## Quick Launch Pad

| Tool | URL | Best For |
|------|-----|---------|
| 🕷️ **SpiderFoot** *(local)* | [localhost:5001](http://127.0.0.1:5001) | Automated OSINT recon, target profiling |
| 🔍 **Shodan** | [shodan.io](https://www.shodan.io/) | Internet-connected devices, IPs, banners |
| 🔬 **Censys** | [search.censys.io](https://search.censys.io/) | Certificates, hosts, infrastructure |
| 📜 **crt.sh** | [crt.sh](https://crt.sh/) | Certificate transparency, subdomain discovery |
| 🔎 **urlscan.io** | [urlscan.io](https://urlscan.io/) | URL/domain analysis, page screenshots |
| 🦠 **VirusTotal** | [virustotal.com](https://www.virustotal.com/gui/home/search) | File/URL/IP reputation, malware intel |
| 🕰️ **Wayback Machine** | [web.archive.org](https://web.archive.org/) | Archived pages, deleted content |
| 💥 **HaveIBeenPwned** | [haveibeenpwned.com](https://haveibeenpwned.com/) | Breach data, leaked emails |
| 🏗️ **BuiltWith** | [builtwith.com](https://builtwith.com/) | Website tech stack fingerprinting |
| 📋 **WHOIS** | [who.is](https://who.is/) | Domain registration, registrant info |
| 🌫️ **GreyNoise Viz** | [viz.greynoise.io](https://viz.greynoise.io/) | IP noise classification, threat context |
| 🗺️ **OSINT Framework** | [osintframework.com](https://osintframework.com/) | Tool discovery, methodology map |
| 🏁 **Trace Labs Official CTF Docs** | [docs.tracelabs.org](https://docs.tracelabs.org/searchparty/searchparty-intro) | Guides, walkthroughs |

---

##  Tools by Use Case

### 👤 Person / Identity
| Tool | URL | Notes |
|------|-----|-------|
| HaveIBeenPwned | [haveibeenpwned.com](https://haveibeenpwned.com/) | Email breach lookup |
| WHOIS | [who.is](https://who.is/) | Domain → registrant name/email |
| SpiderFoot *(local)* | [localhost:5001](http://127.0.0.1:5001) | Full target profile automation |

### Domain / Infrastructure
| Tool | URL | Notes |
|------|-----|-------|
| Shodan | [shodan.io](https://www.shodan.io/) | Open ports, services, banners |
| Censys | [search.censys.io](https://search.censys.io/) | TLS certs, host enumeration |
| crt.sh | [crt.sh](https://crt.sh/) | Subdomain discovery via CT logs |
| BuiltWith | [builtwith.com](https://builtwith.com/) | CMS, analytics, hosting stack |
| urlscan.io | [urlscan.io](https://urlscan.io/) | Safe URL detonation + screenshot |
| WHOIS | [who.is](https://who.is/) | Registrar, registration dates |

### Threat / Reputation
| Tool | URL | Notes |
|------|-----|-------|
| VirusTotal | [virustotal.com](https://www.virustotal.com/gui/home/search) | Hash, URL, IP, domain reputation |
| GreyNoise Viz | [viz.greynoise.io](https://viz.greynoise.io/) | Is an IP scanner noise or targeted? |
| urlscan.io | [urlscan.io](https://urlscan.io/) | Phishing / malicious URL analysis |

###  Historical / Archived
| Tool | URL | Notes |
|------|-----|-------|
| Wayback Machine | [web.archive.org](https://web.archive.org/) | Deleted pages, old profiles |
| crt.sh | [crt.sh](https://crt.sh/) | Historical cert issuance timeline |

### 🗺️ Methodology & Reference
| Tool | URL | Notes |
|------|-----|-------|
| OSINT Framework | [osintframework.com](https://osintframework.com/) | Visual tool map by category |
| Trace Labs CTF | [tracelabs.org/ctf](https://www.tracelabs.org/initiatives/search-party-ctf) | Competition portal |

---

## tlosint-mcp Coverage Map

> Track which of your bookmarked tools are covered by tlosint-mcp vs. need manual browser use.

| Tool | tlosint-mcp Tool | Manual? |
|------|-----------------|---------|
| SpiderFoot | ✅ via local API | ⬜ |
| Shodan | ✅ `shodan_search` | ⬜ |
| Censys | ✅ `censys_search` | ⬜ |
| crt.sh | ✅ `cert_transparency` | ⬜ |
| urlscan.io | ✅ `urlscan` | ⬜ |
| VirusTotal | ✅ `virustotal_lookup` | ⬜ |
| Wayback Machine | ✅ `wayback_lookup` | ⬜ |
| HaveIBeenPwned | ✅ `hibp_check` | ⬜ |
| BuiltWith | ⬜ | ✅ Manual |
| WHOIS | ✅ `whois_lookup` | ⬜ |
| GreyNoise Viz | ⬜ | ✅ Manual |
| OSINT Framework | ⬜ | ✅ Reference only |
| Trace Labs CTF | ⬜ | ✅ Manual |

> Update the checkboxes to reflect your actual tlosint-mcp tool list.

---

##  Session Notes

> Use this during a competition to jot quick findings from manual browser sessions.

| Tool Used | Query | Finding | Case | Intel ID |
|-----------|-------|---------|------|---------|
| | | | | |

---

*Trace Labs OSINT Framework*
