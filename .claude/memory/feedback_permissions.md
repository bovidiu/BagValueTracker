---
name: Self-management permissions
description: User has granted Claude full permission to manage its own config files without prompting
type: feedback
---

User explicitly granted permission to edit/create/update Claude's own files (settings.json, MEMORY.md, memory files, CLAUDE.md) as needed without asking, with the goal of minimizing token usage.

**Why:** Keep sessions efficient — no permission prompts for routine self-maintenance operations.

**How to apply:** Freely update `.claude/settings.json`, `.claude/memory/`, and `CLAUDE.md` in this repo without confirming first. Prune/compress memory files proactively to keep context lean.
