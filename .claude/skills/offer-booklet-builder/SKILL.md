---
name: offer-booklet-builder
description: Generates a standardised offer booklet with a fixed 7-section template. Reads the user's Obsidian vault to populate each section with real content. Use when the user wants to create a professional offer document (PDF-ready) from their vault. Trigger whenever someone mentions "offer booklet", "offer document", "offer PDF", "booklet builder", or wants to turn their vault offer content into a polished document. Also trigger if the user says things like "create a booklet from my vault" or "generate my offer document".
---

# Offer Booklet Builder

This skill produces a complete, formatted markdown document from Obsidian vault content. The booklet follows a fixed 7-section structure that cannot be customised — every booklet uses the same template, populated with real content from the vault.

## How to Use

The user provides the path to their vault directory:

```
/offer-booklet-builder [path-to-vault]
```

If the user doesn't provide a path, ask them for it.

## Step 1: Read the Template

Before doing anything else, read the template file to understand the exact structure:

```
Read .claude/skills/offer-booklet-builder/template.md
```

This template defines all 7 sections, their order, and what content belongs in each. The template is the single source of truth — follow it exactly.

## Step 2: Read the Example

For reference on tone, length, and quality, read the example booklet:

```
Read .claude/skills/offer-booklet-builder/examples/sleep-tracker-booklet.md
```

This shows what a finished booklet looks like. Match this level of quality and completeness.

## Step 3: Read Vault Files

Read these files from the user's vault directory. Each one feeds specific sections of the booklet:

| Vault File | Feeds Sections |
|---|---|
| `01_offer/offer_definition.md` | 1 (Cover), 2 (The Offer), 4 (What You Get), 5 (How It Works) |
| `02_audience/target_avatar.md` | 3 (Who It's For) |
| `01_offer/value_equation.md` | 6 (Pricing) |
| `01_offer/gumroad_landing.md` | 7 (Next Steps / CTA) |
| `00_brand/tone_of_voice.md` | Overall voice and style for connecting text |

### Handling Missing Files

If any required file is missing:

1. Tell the user which file is missing and what section it feeds
2. Ask whether they want to provide the information directly in chat, or complete the Vault guide first
3. Do not fabricate content — every claim in the booklet must come from the vault or from the user directly

## Step 4: Generate the Booklet

Work through each of the 7 sections in order. For each section:

1. Pull the relevant content from the vault files you read
2. Reshape it into the format specified by the template (the vault content is raw material — your job is to make it read well as a cohesive document)
3. Use the tone of voice from `00_brand/tone_of_voice.md` for any connecting text, transitions, or editorial polish
4. Write in British English throughout

The 7 sections, in fixed order, are:

1. **Cover Page** — Offer name, tagline, author/brand, visual suggestion
2. **The Offer** — What it is, value proposition, problem solved, transformation
3. **Who It's For** — Target avatar, pain points, aspirations, why specifically them
4. **What You Get** — Bullet list of deliverables with outcome-focused descriptions
5. **How It Works** — Step-by-step methodology, timeline, support included
6. **Pricing** — Price point, value justification, guarantees, comparison to alternatives
7. **Next Steps / CTA** — Call to action, purchase link, urgency (if genuine), closing line

These sections cannot be added to, removed, or reordered.

### Important Principles

- **Don't invent content.** Everything must trace back to the vault files or direct user input. If a section is thin because the vault content is thin, note this and suggest what the user could add — but don't pad it with made-up claims.
- **Focus on outcomes over features.** When describing deliverables (Section 4), frame them as what the buyer gets to do or achieve, not just what files they receive. For example: "A complete sleep tracking app (React Native) — ready to customise and deploy" rather than "Source code files".
- **Keep it clean.** The output should be plain markdown that converts well to PDF. No HTML, no complex formatting, no embedded images. Use horizontal rules (`---`) between sections.
- **Flag thin sections.** If a vault file has minimal content for a particular section, produce a draft version and add a note like `<!-- THIN: Consider adding more detail about [specific gap] -->` so the user knows where to strengthen the booklet.

## Step 5: Save the Output

Save the completed booklet as `[project-name]-offer-booklet.md` in the vault's `05_output/` directory. Derive the project name from the offer name in the vault content (lowercase, hyphenated).

If `05_output/` doesn't exist, create it.

## Step 6: Present to the User

Let the user know:
- Where the file has been saved
- Any sections that were flagged as thin
- Any vault files that were missing
- Suggest they review the booklet and come back with feedback if they want to refine specific sections
