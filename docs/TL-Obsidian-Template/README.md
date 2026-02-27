# 🕵️ Trace Labs Obsidian Template System
### tlosint-mcp Integration Edition | v1.0

---

## 📁 Vault Structure

```
YourVault/
├── 📂 Cases/
│   ├── 🔍 CASE — TargetName.md          ← START HERE (Master Hub)
│   ├── 🎯 Profile — TargetName.md        ← Initial Recon
│   ├── 🧩 Intel — TargetName.md          ← Intel Collection & Tagging
│   └── 📦 Submission — TargetName.md     ← Flag Packaging
│
├── 📂 MCP Outputs/
│   └── 🤖 MCP — ToolName — TargetName.md ← Raw tool output capture
│
├── 📂 screenshots/
│   └── FLAG-001.png, FLAG-002.png ...
│
└── 🌐 OSINT Resources.md                 ← PIN THIS (bookmarks & tool map)
```

---

## 🚀 Quick Start — New Investigation

### Step 1: Create your 4 core notes
Duplicate each template and replace `{{TARGET_NAME}}` and `{{CASE_ID}}` throughout.

| Template | Purpose | Create When |
|----------|---------|------------|
| `🔍 CASE — ...` | Master hub & timeline | Immediately |
| `🎯 Profile — ...` | Identity & digital footprint | Immediately |
| `🧩 Intel — ...` | All raw intel & MCP outputs | Immediately |
| `📦 Submission — ...` | Flags ready to submit | When you have confirmed intel |
| `🌐 OSINT Resources` | Bookmarks & tool map | Once — lives in vault root, pin it |

### Step 2: Fill out Profile first
Work through the `🎯 Profile` template systematically. Use MCP tools and paste outputs directly.

### Step 3: Run tlosint-mcp & capture outputs
For each MCP tool run, either:
- **Option A:** Paste directly into the MCP Outputs Inbox section in `🧩 Intel`
- **Option B:** Create a dedicated `🤖 MCP — ToolName — Target.md` note (better for large outputs)

### Step 4: Extract & tag intel
Move every useful finding from raw MCP outputs into the Intel Registry. Assign:
- An **ID** (e.g., `LOC-001`, `SOC-003`)
- A **Tier** (🥇🥈🥉)
- A **Confidence level** (⬜ Unverified | 🟡 Probable | 🟢 Confirmed)

### Step 5: Package flags
Pull confirmed intel into `📦 Submission`. Each flag must have a source URL and screenshot.

---

## 🔑 Variable Reference

Replace these placeholders when creating notes from templates:

| Variable               | Description                 | Example           |
| ---------------------- | --------------------------- | ----------------- |
| `{{TARGET_NAME}}`      | Target's name or alias      | `Jane_Doe`        |
| `{{CASE_ID}}`          | TL case/competition ID      | `TL-2024-087`     |
| `{{COMPETITION_NAME}}` | Competition name            | `TL Global 2024`  |
| `{{DATE}}`             | Today's date                | `2024-11-15`      |
| `{{TIME}}`             | Current time                | `14:32 UTC+7`     |
| `{{YOUR_HANDLE}}`      | Your TL handle              | `r0bski`          |
| `{{MCP_SESSION_ID}}`   | tlosint-mcp session ID      | `sess_abc123`     |
| `{{ALIAS}}`            | Target's known online alias | `j4nedoe_99`      |
| `{{TOOL_NAME}}`        | MCP tool used               | `username_search` |
| `{{QUERY}}`            | Input query for MCP tool    | `j4nedoe_99`      |

---

## 🤖 tlosint-mcp Integration Workflow

```
tlosint-mcp tool run
        │
        ▼
Paste output into:
  🧩 Intel → MCP Tool Output Inbox
        │
        ▼
Review & extract actionable items
        │
        ▼
Add to Intel Registry with ID + Tier + Confidence
        │
        ▼
Confirmed intel → 📦 Submission as FLAG-XXX
        │
        ▼
Screenshot + source URL → submit to TL judges
```

---

## ⭐ Recommended Obsidian Plugins

| Plugin | Why |
|--------|-----|
| **Templater** | Auto-fill `{{variables}}` when creating notes |
| **Dataview** | Auto-calculate intel counts in dashboards |
| **Kanban** | Visual flag tracking board |
| **QuickAdd** | One-keystroke note creation from templates |
| **Tag Wrangler** | Manage TL tags across cases |
| **Obsidian Git** | Auto-commit your case notes (backup!) |

---

## 🏆 Tier Definitions

| Tier | Value | Examples |
|------|-------|---------|
| 🥇 Tier 1 — High | Direct lead to location or contact | Phone number, home address, active email |
| 🥈 Tier 2 — Medium | Narrows search significantly | City/region, employer, school, social handle |
| 🥉 Tier 3 — Context | Background info, builds picture | Interests, associates, historical locations |

---

*Trace Labs OSINT Framework | tlosint-mcp Integration*
*Built for Trace Labs CTF competitions. Handle all PII per TL rules of engagement.*
