---
tags:
  - trace-labs
  - intel
  - collection
case_id: "{{CASE_ID}}"
target_name: "{{TARGET_NAME}}"
date_created: "{{DATE}}"
flag_count: 0
submitted_count: 0
mcp_tools_used: []
---

# 🧩 Intel Collection — {{TARGET_NAME}}

← Back to [[🔍 CASE — {{TARGET_NAME}}]]

> [!tip] How to Use This Note
> Every piece of intel gets its own entry below. Tag each with a **category**, **confidence**, and **flag tier**.
> MCP tool outputs go in the dedicated section at the bottom — extract flags from them and paste here.

---

## 📊 Intel Dashboard

| Metric | Count |
|--------|-------|
| Total Intel Items | 0 |
| 🥇 Tier 1 (High Value) | 0 |
| 🥈 Tier 2 (Medium Value) | 0 |
| 🥉 Tier 3 (Low Value / Context) | 0 |
| ✅ Submitted as Flags | 0 |
| ❌ Rejected / Unverified | 0 |

> Update this manually or use Dataview plugin to auto-calculate.

---

## 🗂️ Intel Registry

> One row per intel item. Assign an ID (e.g., INT-001) for cross-referencing.

### 📍 Location Intel

| ID | Intel | Tier | Confidence | MCP Tool | Source URL | Submitted? |
|----|-------|------|-----------|---------|-----------|-----------|
| LOC-001 | | 🥈 | 🟡 Probable | | | ⬜ |

### 🌐 Social Media Intel

| ID | Platform | Intel | Tier | Confidence | MCP Tool | Source URL | Submitted? |
|----|----------|-------|------|-----------|---------|-----------|-----------|
| SOC-001 | | | 🥈 | 🟡 | | | ⬜ |

### 👤 Identity Intel

| ID | Intel | Tier | Confidence | MCP Tool | Source URL | Submitted? |
|----|-------|------|-----------|---------|-----------|-----------|
| ID-001 | | 🥇 | 🟢 Confirmed | | | ⬜ |

### 💼 Employment / Education Intel

| ID | Intel | Tier | Confidence | MCP Tool | Source URL | Submitted? |
|----|-------|------|-----------|---------|-----------|-----------|
| EMP-001 | | 🥈 | 🟡 | | | ⬜ |

### 👥 Associates Intel

| ID | Associate Name/Handle | Relationship | Intel | Tier | Source | Submitted? |
|----|----------------------|-------------|-------|------|--------|-----------|
| ASC-001 | | | | 🥉 | | ⬜ |

### 📸 Image / Media Intel

| ID | Image URL / Description | Metadata Found | Tier | MCP Tool | Submitted? |
|----|------------------------|---------------|------|---------|-----------|
| IMG-001 | | | 🥈 | `image_analysis` | ⬜ |

### 🔑 Account / Credential Intel

| ID | Intel | Type | Tier | Source | Submitted? |
|----|-------|------|------|--------|-----------|
| ACC-001 | | Email/Username/Phone | 🥇 | | ⬜ |

### 🗒️ Miscellaneous Intel

| ID | Intel | Category | Tier | Source | Submitted? |
|----|-------|---------|------|--------|-----------|
| MISC-001 | | | 🥉 | | ⬜ |

---

## 🤖 MCP Tool Output Inbox

> Paste raw tlosint-mcp outputs here first. Review, extract intel items, and move them to the registry above.

---

### 🔧 Tool: `username_search`
**Run Date:** | **Query:** | **Session:** {{MCP_SESSION_ID}}

```json
// Paste output here

```

**Extracted Intel:**
- [ ] INT-XXX: 

---

### 🔧 Tool: `social_media_scan`
**Run Date:** | **Query:** | **Session:** {{MCP_SESSION_ID}}

```json
// Paste output here

```

**Extracted Intel:**
- [ ] INT-XXX:

---

### 🔧 Tool: `email_search`
**Run Date:** | **Query:** | **Session:** {{MCP_SESSION_ID}}

```json
// Paste output here

```

**Extracted Intel:**
- [ ] INT-XXX:

---

### 🔧 Tool: `geolocation_analysis`
**Run Date:** | **Query:** | **Session:** {{MCP_SESSION_ID}}

```json
// Paste output here

```

**Extracted Intel:**
- [ ] INT-XXX:

---

### 🔧 Tool: `image_analysis`
**Run Date:** | **Query:** | **Session:** {{MCP_SESSION_ID}}

```json
// Paste output here

```

**Extracted Intel:**
- [ ] INT-XXX:

---

### 🔧 Tool: `breach_check`
**Run Date:** | **Query:** | **Session:** {{MCP_SESSION_ID}}

```json
// Paste output here

```

**Extracted Intel:**
- [ ] INT-XXX:

---

### 🔧 Tool: `whois_lookup`
**Run Date:** | **Query:** | **Session:** {{MCP_SESSION_ID}}

```json
// Paste output here

```

**Extracted Intel:**
- [ ] INT-XXX:

---

### 🔧 Tool: `custom / other`
**Tool Name:** | **Run Date:** | **Query:**

```json
// Paste output here

```

**Extracted Intel:**
- [ ] INT-XXX:

---

## 🔗 Intel Connection Map

> Use this section to document connections between intel items. Great for building relationship webs.

```
[ID-001: Full Name] ──── linked to ──── [SOC-003: Facebook Account]
                                              │
                                         tags [ASC-001: Known Associate]
                                              │
                                    [LOC-002: City Confirmed]
```

---

## ⚠️ Disputed / Unverified Intel

> Items that couldn't be confirmed. Keep here for reference — don't submit.

| ID | Intel | Why Disputed | Date |
|----|-------|-------------|------|
| | | | |

---

*Template v1.0 — tlosint-mcp integration | Trace Labs OSINT Framework*
