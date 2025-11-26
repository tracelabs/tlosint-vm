# TraceLabs OSINT VM Tool Evaluation Policy

This Trace Labs OSINT VM is built for OSINT work, not as a “install everything” showcase. To keep it usable and maintainable, we triage tools before adding them.

This policy governs how suggestions for new tools are evaluated, accepted, or rejected for inclusion in the TL VM.

## Tool Classification

As part of evluating tool, a tool can end up as part of:

- core (installed by default)
- recommended (optional script to run, script available in the VM)
- documented (goes to the OSINT tool list repo)
- excluded (not added to the VM)

## Evaluation Criteria

Some of the following critera are intentionally imprecise so as to allow for the descretion and descernment of Trace Labs staff.

| Criterion | Requirement |
|-----------|-------------|
| **Relevance** | Directly supports OSINT investigation (e.g., data collection, parsing, visualization). |
| **Overlap with existing tools** | Does it duplicate functionality of an existing tool? If yes, is it significantly better, actively maintained, or more usable? |
| **Legal & Ethical** | No violation of copyright or terms of service agreements. |
| **Security** | No known vulnerabilities or malware signature matches. |
| **License Compatibility** | Must be permissive (MIT, Apache 2.0, GPL 3+, etc.) |
| **Documentation** | Provides clear usage docs or a reputable tutorial. |

### Bonus Criteria

- Active community.
- Recent (within 12 months) maintenance.

### Immediate Disqualifiers

- Any illegal techinical methodologies (hacking).
- Violation of copyright.

---

## Review Cycle

- Tools are reviewed quarterly.
- The policy itself is reviewed annually.
