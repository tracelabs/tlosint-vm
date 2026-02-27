---
tags:
  - trace-labs
  - investigation
  - active
case_id: "{{CASE_ID}}"
target_name: "{{TARGET_NAME}}"
target_alias: "{{ALIAS}}"
competition: "{{COMPETITION_NAME}}"
date_opened: "{{DATE}}"
date_closed: ""
investigator: "{{YOUR_HANDLE}}"
status: "🟡 Active"   # 🟡 Active | 🔴 Stalled | 🟢 Submitted | ⚫ Closed
priority: "Medium"    # High | Medium | Low
mcp_session_id: "{{MCP_SESSION_ID}}"
---

# 🔍 {{TARGET_NAME}} — Case File

> [!info] Quick Brief
> **Case ID:** `{{CASE_ID}}` | **Opened:** `{{DATE}}` | **Investigator:** `{{YOUR_HANDLE}}`
> **Status:** {{status}} | **Competition:** {{competition}}

---

## 🗺️ Case Map

| Phase | Template | Status |
|-------|----------|--------|
| 🎯 Target Profile | [[🎯 Profile — {{TARGET_NAME}}]] | ⬜ Not Started |
| 🧩 Intel Collection | [[🧩 Intel — {{TARGET_NAME}}]] | ⬜ Not Started |
| 📦 Final Submission | [[📦 Submission — {{TARGET_NAME}}]] | ⬜ Not Started |

---

## ⚡ Quick Intel — Known Facts

> Drop critical confirmed facts here as you find them. Link to full evidence in the Intel note.

- [ ] Full legal name confirmed
- [ ] Last known location
- [ ] Contact information
- [ ] Active social media presence
- [ ] Employment / school
- [ ] Associates / family

---

## 🧵 Investigation Timeline

| Timestamp | Action | Result | Source |
|-----------|--------|--------|--------|
| `{{DATE}} {{TIME}}` | Case opened | — | — |
| | | | |

---

## 🛠️ MCP Tool Log

> Paste `tlosint-mcp` session outputs here or link to raw output files.

```
MCP Session: {{MCP_SESSION_ID}}
Tools invoked: 
Last run: 
```

**Tool Runs:**
- [ ] `username_search` — [[MCP Outputs/username_{{TARGET_NAME}}]]
- [ ] `email_search` — [[MCP Outputs/email_{{TARGET_NAME}}]]
- [ ] `social_media_scan` — [[MCP Outputs/social_{{TARGET_NAME}}]]
- [ ] `geolocation_analysis` — [[MCP Outputs/geo_{{TARGET_NAME}}]]
- [ ] `image_analysis` — [[MCP Outputs/img_{{TARGET_NAME}}]]

---

## 🔗 Linked Notes

- [[🎯 Profile — {{TARGET_NAME}}]]
- [[🧩 Intel — {{TARGET_NAME}}]]
- [[📦 Submission — {{TARGET_NAME}}]]
- [[🌐 OSINT Resources]] ← Quick launch pad & tool reference

---

## 🚧 Blockers & Dead Ends

> Track rabbit holes and dead ends to avoid re-investigating them.

| Dead End | Reason | Date |
|----------|--------|------|
| | | |

---

*Template v1.0 — tlosint-mcp integration | Trace Labs OSINT Framework*
