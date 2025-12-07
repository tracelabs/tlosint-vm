# TraceLabs OSINT VM Tool Evaluation Policy

This Trace Labs OSINT VM is built for OSINT work, not as a “install everything” showcase. To keep it usable and maintainable, we review tools before adding them.

This policy governs how suggestions for new tools are evaluated, accepted, or rejected for inclusion in the TL VM. 

All tools should be suggested by creating a ["Tool Request Issue"](https://github.com/tracelabs/tlosint-vm/issues). After the issue is created, it will be labeled as `tool/triaged`. During our review, we will follow the evaluation criteria and proceed to classify the tool based on the tool classification below.

## Tool Classification

As part of evluating tool, we categorize the tools using github labels as referenced below (our triage process is in progress of maturing, so for simplicity, we will mark tools either as `accepted` or `rejected`):

- core (installed in the VM by default, `tool/accepted`)
- recommended (optional script to run, script available in the VM, `tool/accepted`)
- documented (goes to the OSINT tool list repo, `tool/accepted`)
- rejected (not added to the VM, `tool/rejected`)

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
