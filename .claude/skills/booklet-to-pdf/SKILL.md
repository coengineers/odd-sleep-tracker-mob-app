---
name: booklet-to-pdf
description: >
  Converts an offer booklet markdown file into a branded, Gumroad-ready A4 PDF.
  Uses ReportLab with Satoshi fonts. Reads the booklet from the vault's 05_output/
  directory and produces a styled PDF in the same directory. Use when the user wants
  to generate a PDF from their offer booklet, or mentions "booklet PDF", "offer PDF",
  "Gumroad PDF", or "convert booklet".
---

# Booklet to PDF

Converts an offer booklet markdown file into a branded, print-ready A4 PDF suitable
for Gumroad upload. Uses the CoEngineers visual identity: dark cover/back pages,
Satoshi typography, accent colour theming, and clean body layout.

## When this skill activates

| Trigger | Example |
|---------|---------|
| User wants a PDF from their booklet | "Convert my booklet to PDF" |
| User mentions Gumroad-ready PDF | "Make this Gumroad-ready" |
| User wants a branded PDF | "Generate a PDF for my offer" |
| User provides a vault path | "/booklet-to-pdf ~/my-project" |

## Input

The user provides:
1. **Vault path** (required) — path to the vault directory containing `05_output/` with a booklet markdown file
2. **Accent colour** (optional) — hex colour code for branding. Defaults to `#E87040` (Bitcoin Orange)
3. **Offer title** (optional) — if not provided, extracted from the booklet's H1

```
/booklet-to-pdf [vault-path] [--accent #HEX] [--title "Offer Title"]
```

## How it works

1. Find the booklet markdown file in `[vault-path]/05_output/` (the file ending in `-offer-booklet.md`)
2. Read the brand files from `[vault-path]/00_brand/` for tone context
3. Run the Python PDF generator script at `.claude/skills/booklet-to-pdf/generate_booklet_pdf.py`
4. Output the PDF to `[vault-path]/05_output/` with the same base name

### Running the script

```bash
python3 .claude/skills/booklet-to-pdf/generate_booklet_pdf.py \
  --input [path-to-booklet.md] \
  --output [path-to-output.pdf] \
  --accent [hex-colour] \
  --title [offer-title]
```

The script handles:
- YAML frontmatter stripping
- 7-section parsing (Cover, The Offer, Who It's For, What You Get, How It Works, Pricing, Next Steps)
- Dark cover and back cover pages with accent-coloured rules
- White body pages with Satoshi typography
- Bullet lists, bold text, horizontal rules
- Page numbers and footer branding
- HTML comment stripping (thin-section flags)

## Behaviour Rules

1. Always check that the booklet markdown file exists before running
2. If multiple booklet files exist in `05_output/`, ask the user which one
3. Report the output path and page count when done
4. Do not modify the source markdown file
5. The PDF should be A4 portrait, suitable for digital reading and Gumroad upload

## Dependencies

- Python 3 with `reportlab` package
- Satoshi font files in `10_Books/scripts/fonts/`
