---
name: vault-validator
description: >
  Validates an Obsidian vault against the canonical CoEngineers folder structure.
  Checks folder names, required files, metadata fields, empty files, naming conventions,
  and template structure. Use when a user has built their vault and wants to verify it
  is correctly structured before moving on to the Offer guide. Also use when the user
  mentions "validate vault", "check vault", "audit vault", "vault structure", or asks
  whether their vault is ready or correct.
---

# Vault Validator

Audits an Obsidian vault directory against the canonical CoEngineers folder structure
and produces a structured validation report. The skill reads the actual filesystem,
checks every folder, file, and metadata field against a strict specification, and
reports all errors and warnings in a single pass.

## When this skill activates

| Trigger | Example |
|---------|---------|
| User wants to validate their vault | "Check my vault is set up correctly" |
| User asks if their vault structure is right | "Is my vault ready?" |
| User mentions vault audit or validation | "Audit my vault before I move on" |
| User wants to verify before proceeding to the Offer guide | "Validate the vault so I can start the next step" |
| User provides a path and asks to check it | "/vault-validator ~/my-project" |

## Input

The user provides the path to their vault directory as an argument:

```
/vault-validator [path-to-vault]
```

If no path is provided, ask the user for the vault path before proceeding.

## How to run the validation

Read the canonical structure reference first:

```
Read .claude/skills/vault-validator/canonical-structure.md
```

Then work through each check in priority order. Scan the entire vault once,
collecting all errors and warnings, and present the full report at the end.

### Important behaviour rules

1. Read the actual filesystem — never ask the user to describe their vault.
2. Check every `.md` file in every folder, not only the required files.
3. Do not modify any files — this skill is strictly read-only.
4. Report all errors and warnings; do not stop at the first one.
5. Clearly distinguish ERRORS (blocking) from WARNINGS (informational).
6. A vault PASSES only when there are zero ERRORS. Warnings are acceptable.
7. The `05_output/` folder is allowed to be empty.
8. Files inside `05_output/` subdirectories are exempt from metadata checks when the subdirectory is empty.
9. Ignore hidden files (starting with `.`) and the `.obsidian/` directory entirely.

## Validation checks (run in this order)

### Check 1 — Required folders exist

The vault must contain exactly these six top-level folders:

```
00_brand/
01_offer/
02_audience/
03_build/
04_outreach/
05_output/
```

Folder names must match exactly (case-sensitive). Missing folders are ERRORS.
Additional folders are allowed but generate a WARNING.

**Error format:**
```
ERROR: Missing required folder: 00_brand
```

**Warning format:**
```
WARNING: Unexpected folder found: 06_misc — this is not part of the canonical structure
```

### Check 2 — Required files exist

Each required file must exist in its correct folder with an exact case-sensitive
match. Missing required files are ERRORS. Additional files in required folders
are allowed without warning.

Required files:

| Folder | Required file |
|--------|---------------|
| 00_brand | tone_of_voice.md |
| 00_brand | ai_blocklist.md |
| 01_offer | offer_definition.md |
| 01_offer | value_equation.md |
| 01_offer | gumroad_landing.md |
| 02_audience | target_avatar.md |
| 03_build | app_prd.md |
| 04_outreach | warm_messages.md |
| 04_outreach | follow_up_templates.md |

That is 9 required files across 5 folders. (`05_output` has no required files.)

**Error format:**
```
ERROR: Missing required file: 01_offer/offer_definition.md
```

### Check 3 — YAML frontmatter metadata

Every `.md` file in the vault (required and optional) must have YAML frontmatter
between `---` markers at the very top of the file.

**Required metadata fields and their rules:**

| Field | Rule |
|-------|------|
| title | Non-empty string |
| created | Valid date in YYYY-MM-DD format |
| updated | Valid date in YYYY-MM-DD format, must be >= created |
| status | One of: `draft`, `in-progress`, `complete` |
| tags | YAML list with at least one tag |

Missing frontmatter is an ERROR. Each missing or invalid field is a separate ERROR.

**Error formats:**
```
ERROR: Missing YAML frontmatter in 00_brand/tone_of_voice.md
ERROR: Missing metadata field 'status' in 00_brand/tone_of_voice.md
ERROR: Invalid date format for 'created' in 01_offer/offer_definition.md — expected YYYY-MM-DD, got '5th Feb'
ERROR: 'updated' date is earlier than 'created' in 01_offer/value_equation.md
ERROR: 'status' must be one of draft, in-progress, complete in 03_build/app_prd.md — got 'done'
ERROR: 'tags' must be a non-empty list in 02_audience/target_avatar.md
```

### Check 4 — No empty files

Every `.md` file must have content beyond the YAML frontmatter. A file with only
frontmatter, or frontmatter followed by whitespace only, is an ERROR.

**Error format:**
```
ERROR: Empty file (no content after frontmatter): 02_audience/target_avatar.md
```

### Check 5 — Naming conventions

All `.md` file names must use snake_case: lowercase letters, numbers, and
underscores only, with the `.md` extension. No spaces, hyphens, or uppercase
letters.

Folder names must follow the `NN_name` pattern: a two-digit prefix, an
underscore, then a lowercase name.

**Error format:**
```
ERROR: Invalid filename: 01_offer/Offer-Definition.md — must use snake_case (expected: offer_definition.md)
ERROR: Invalid folder name: 1_offer — must use NN_name pattern (expected: 01_offer)
```

### Check 6 — Stale draft detection (WARNING only)

Any file with `status: draft` whose `updated` date is more than 7 days before
today generates a WARNING. This is informational and does not block a pass.

**Warning format:**
```
WARNING: 00_brand/tone_of_voice.md has been in 'draft' status for 14 days (last updated 2026-02-06)
```

## Output format

Produce the report in this exact structure. Replace placeholders with actual
values. See `examples/valid-vault-output.md` for a complete passing example.

```
═══════════════════════════════════════════════════
  VAULT VALIDATION REPORT
═══════════════════════════════════════════════════

  Vault:    [vault-name]
  Path:     [vault-path]
  Date:     [YYYY-MM-DD HH:MM]

───────────────────────────────────────────────────
  STRUCTURE
───────────────────────────────────────────────────

  Folders:  [X]/6 required folders present
  Files:    [X]/9 required files present

  [List any missing folders/files as ERROR lines]

───────────────────────────────────────────────────
  METADATA
───────────────────────────────────────────────────

  Files checked:    [N]
  Files with valid metadata: [N]
  Files with issues: [N]

  [List any metadata errors]

───────────────────────────────────────────────────
  QUALITY
───────────────────────────────────────────────────

  Empty files:      [N]
  Naming issues:    [N]
  Stale drafts:     [N]

  [List any quality errors/warnings]

───────────────────────────────────────────────────
  RESULT
───────────────────────────────────────────────────

  Errors:    [N]
  Warnings:  [N]

  [PASS — Vault is valid] or [FAIL — Fix [N] errors before proceeding]

═══════════════════════════════════════════════════
```

## Reference files

| File | When to read |
|------|-------------|
| `canonical-structure.md` | Before starting validation — contains the full expected structure with annotations |
| `examples/valid-vault-output.md` | When formatting the final report — shows a complete passing example |
