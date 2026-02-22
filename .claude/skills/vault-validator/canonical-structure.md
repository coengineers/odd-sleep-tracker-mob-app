# Canonical CoEngineers Vault Structure

This is the exact folder and file structure that the vault-validator checks against.
Every vault must conform to this specification to pass validation.

## Top-level folders

Six required folders, numbered 00–05. The numbering enforces a consistent
ordering and makes the vault navigable at a glance.

```
[project-name]/
├── 00_brand/
├── 01_offer/
├── 02_audience/
├── 03_build/
├── 04_outreach/
└── 05_output/
```

### Naming rule

Folder names use the pattern `NN_name`:

- `NN` = two-digit zero-padded number (00, 01, 02, …)
- `_` = single underscore separator
- `name` = lowercase alphabetic name (no spaces, no hyphens)

## Required files by folder

### 00_brand/

| File | Purpose |
|------|---------|
| tone_of_voice.md | Brand voice guidelines and writing principles |
| ai_blocklist.md | Words, phrases, and patterns the AI must avoid |

### 01_offer/

| File | Purpose |
|------|---------|
| offer_definition.md | What the offer is, who it serves, and why it matters |
| value_equation.md | The value proposition broken down into components |
| gumroad_landing.md | Landing page copy and structure for Gumroad |

### 02_audience/

| File | Purpose |
|------|---------|
| target_avatar.md | Detailed profile of the ideal customer |

### 03_build/

| File | Purpose |
|------|---------|
| app_prd.md | Product requirements document for the app or build |

Additional slice files (e.g. `feature_slice_auth.md`, `api_design.md`) are
optional but encouraged. They do not trigger warnings.

### 04_outreach/

| File | Purpose |
|------|---------|
| warm_messages.md | Templates for warm outreach to existing contacts |
| follow_up_templates.md | Follow-up message sequences |

### 05_output/

This is an output directory. It has no required files and is allowed to be
completely empty. Subdirectories such as `book_chapter_drafts/` or
`social_posts/` may appear here during the build process.

Files inside `05_output/` subdirectories are exempt from metadata checks
when the subdirectory is empty.

## File naming convention

All `.md` files must use snake_case:

- Lowercase letters only (a–z)
- Numbers allowed (0–9)
- Underscores as word separators
- `.md` extension
- No spaces, hyphens, or uppercase letters

**Valid:** `tone_of_voice.md`, `app_prd.md`, `feature_slice_01.md`
**Invalid:** `Tone-Of-Voice.md`, `App PRD.md`, `appPrd.md`

## YAML frontmatter specification

Every `.md` file in the vault must begin with YAML frontmatter between `---`
markers. The following five fields are required:

```yaml
---
title: "Tone of Voice"
created: 2026-02-01
updated: 2026-02-15
status: complete
tags:
  - brand
  - voice
---
```

### Field rules

| Field | Type | Validation |
|-------|------|------------|
| title | string | Must be non-empty |
| created | date | Must match YYYY-MM-DD exactly |
| updated | date | Must match YYYY-MM-DD exactly; must be >= created |
| status | enum | Must be one of: `draft`, `in-progress`, `complete` |
| tags | list | Must be a YAML list with at least one item |

### Status values

| Status | Meaning |
|--------|---------|
| draft | Initial creation, content not yet reviewed |
| in-progress | Actively being written or revised |
| complete | Content is finalised and ready for use |

## Items to ignore

The validator skips these entirely:

- Hidden files (names starting with `.`)
- The `.obsidian/` directory (Obsidian configuration)
- Any non-`.md` files (images, PDFs, etc.)

## Summary counts

| Check | Count |
|-------|-------|
| Required folders | 6 |
| Required files | 9 |
| Required metadata fields per file | 5 (title, created, updated, status, tags) |
