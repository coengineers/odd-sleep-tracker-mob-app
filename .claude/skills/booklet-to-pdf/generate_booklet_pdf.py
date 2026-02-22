#!/usr/bin/env python3
"""Generate a branded A4 PDF from an offer booklet markdown file.

Design:
- Cover page: dark #1A1A1A background, white/accent text, accent rules
- Body pages: white background, dark text, Satoshi typography
- Back cover: dark #1A1A1A background, accent/muted text

Usage:
    python3 generate_booklet_pdf.py \
        --input path/to/booklet.md \
        --output path/to/booklet.pdf \
        --accent "#E87040" \
        --title "The Sleep Tracker Blueprint"
"""

import argparse
import os
import re
import sys

from reportlab.lib.pagesizes import A4
from reportlab.lib.units import mm
from reportlab.lib.colors import HexColor
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.enums import TA_LEFT, TA_CENTER
from reportlab.platypus import (
    BaseDocTemplate, PageTemplate, Frame, NextPageTemplate,
    Paragraph, Spacer, PageBreak, HRFlowable, KeepTogether,
)
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfbase.pdfmetrics import registerFontFamily

# ---------------------------------------------------------------------------
# Fonts
# ---------------------------------------------------------------------------
FONT_DIR = os.path.join(
    os.path.dirname(__file__),
    "..", "..",
    "10_Books", "scripts", "fonts",
)
FONT_DIR = os.path.normpath(FONT_DIR)


def register_fonts():
    pdfmetrics.registerFont(TTFont("Satoshi", os.path.join(FONT_DIR, "Satoshi-Regular.ttf")))
    pdfmetrics.registerFont(TTFont("Satoshi-Bold", os.path.join(FONT_DIR, "Satoshi-Bold.ttf")))
    pdfmetrics.registerFont(TTFont("Satoshi-Italic", os.path.join(FONT_DIR, "Satoshi-Italic.ttf")))
    pdfmetrics.registerFont(TTFont("Satoshi-BoldItalic", os.path.join(FONT_DIR, "Satoshi-BoldItalic.ttf")))
    pdfmetrics.registerFont(TTFont("Satoshi-Medium", os.path.join(FONT_DIR, "Satoshi-Medium.ttf")))
    registerFontFamily(
        "Satoshi",
        normal="Satoshi",
        bold="Satoshi-Bold",
        italic="Satoshi-Italic",
        boldItalic="Satoshi-BoldItalic",
    )


# ---------------------------------------------------------------------------
# Colours
# ---------------------------------------------------------------------------
BG_DARK = HexColor("#1A1A1A")
WHITE = HexColor("#FFFFFF")
TEXT_DARK = HexColor("#1A1A1A")
TEXT_MUTED = HexColor("#A3A3A3")
TEXT_MUTED_DARK = HexColor("#666666")
RULE_LIGHT = HexColor("#DDDDDD")

PAGE_W, PAGE_H = A4
MARGIN = 25 * mm


# ---------------------------------------------------------------------------
# Page backgrounds
# ---------------------------------------------------------------------------
def make_cover_bg(accent):
    def cover_bg(canvas, doc):
        canvas.saveState()
        canvas.setFillColor(BG_DARK)
        canvas.rect(0, 0, PAGE_W, PAGE_H, fill=True, stroke=False)
        canvas.setStrokeColor(accent)
        canvas.setLineWidth(3)
        canvas.line(MARGIN, PAGE_H - 20 * mm, PAGE_W - MARGIN, PAGE_H - 20 * mm)
        canvas.line(MARGIN, 25 * mm, PAGE_W - MARGIN, 25 * mm)
        canvas.restoreState()
    return cover_bg


def make_body_bg(accent, short_title):
    def body_bg(canvas, doc):
        canvas.saveState()
        canvas.setFillColor(WHITE)
        canvas.rect(0, 0, PAGE_W, PAGE_H, fill=True, stroke=False)
        canvas.setStrokeColor(RULE_LIGHT)
        canvas.setLineWidth(0.5)
        canvas.line(MARGIN, 15 * mm, PAGE_W - MARGIN, 15 * mm)
        canvas.setFillColor(TEXT_MUTED)
        canvas.setFont("Satoshi", 8)
        canvas.drawCentredString(PAGE_W / 2, 10 * mm, str(doc.page))
        canvas.setFillColor(TEXT_MUTED_DARK)
        canvas.setFont("Satoshi", 7)
        canvas.drawString(MARGIN, 10 * mm, "CoEngineers")
        canvas.drawRightString(PAGE_W - MARGIN, 10 * mm, short_title)
        canvas.restoreState()
    return body_bg


def make_back_bg(accent):
    def back_bg(canvas, doc):
        canvas.saveState()
        canvas.setFillColor(BG_DARK)
        canvas.rect(0, 0, PAGE_W, PAGE_H, fill=True, stroke=False)
        canvas.setStrokeColor(accent)
        canvas.setLineWidth(3)
        canvas.line(MARGIN, 25 * mm, PAGE_W - MARGIN, 25 * mm)
        canvas.restoreState()
    return back_bg


# ---------------------------------------------------------------------------
# Styles
# ---------------------------------------------------------------------------
def make_styles(accent):
    s = {}

    # Cover (dark bg)
    s["cover_title"] = ParagraphStyle(
        "cover_title", fontName="Satoshi-Medium", fontSize=34, leading=42,
        textColor=WHITE, alignment=TA_CENTER, spaceAfter=8 * mm)
    s["cover_subtitle"] = ParagraphStyle(
        "cover_subtitle", fontName="Satoshi", fontSize=14, leading=20,
        textColor=accent, alignment=TA_CENTER, spaceAfter=6 * mm)
    s["cover_author"] = ParagraphStyle(
        "cover_author", fontName="Satoshi", fontSize=11, leading=15,
        textColor=TEXT_MUTED, alignment=TA_CENTER, spaceAfter=3 * mm)

    # Section titles (white bg)
    s["section_title"] = ParagraphStyle(
        "section_title", fontName="Satoshi-Medium", fontSize=22, leading=28,
        textColor=accent, spaceBefore=6 * mm, spaceAfter=6 * mm)

    # H3 subsections
    s["h3"] = ParagraphStyle(
        "h3", fontName="Satoshi-Medium", fontSize=14, leading=19,
        textColor=TEXT_DARK, spaceBefore=6 * mm, spaceAfter=3 * mm,
        keepWithNext=1)

    # Body
    s["body"] = ParagraphStyle(
        "body", fontName="Satoshi", fontSize=10.5, leading=16,
        textColor=TEXT_DARK, spaceAfter=3 * mm)

    # Bullet list
    s["bullet"] = ParagraphStyle(
        "bullet", fontName="Satoshi", fontSize=10.5, leading=16,
        textColor=TEXT_DARK, leftIndent=8 * mm, bulletIndent=3 * mm,
        spaceAfter=2 * mm)

    # Italic (for tagline, visual suggestion)
    s["italic"] = ParagraphStyle(
        "italic", fontName="Satoshi-Italic", fontSize=11, leading=16,
        textColor=TEXT_MUTED_DARK, spaceAfter=3 * mm)

    # Back cover (dark bg)
    s["back_title"] = ParagraphStyle(
        "back_title", fontName="Satoshi-Medium", fontSize=20, leading=26,
        textColor=accent, alignment=TA_CENTER, spaceAfter=6 * mm)
    s["back_body"] = ParagraphStyle(
        "back_body", fontName="Satoshi", fontSize=11, leading=17,
        textColor=TEXT_MUTED, alignment=TA_CENTER, spaceAfter=4 * mm)

    return s


# ---------------------------------------------------------------------------
# Markdown parsing helpers
# ---------------------------------------------------------------------------
def strip_frontmatter(text):
    if text.startswith("---"):
        end = text.find("---", 3)
        if end != -1:
            return text[end + 3:].lstrip("\n")
    return text


def strip_html_comments(text):
    return re.sub(r'<!--.*?-->', '', text, flags=re.DOTALL)


def inline_md(text):
    text = text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    text = re.sub(r'\[([^\]]+)\]\(([^)]+)\)', r'<a href="\2" color="#D97706">\1</a>', text)
    text = re.sub(r'\*\*([^*]+)\*\*', r'<b>\1</b>', text)
    text = re.sub(r'(?<!\*)\*([^*]+)\*(?!\*)', r'<i>\1</i>', text)
    text = re.sub(r'`([^`]+)`', r'<font name="Courier" color="#333333">\1</font>', text)
    return text


def extract_title_from_md(text):
    for line in text.split("\n"):
        line = line.strip()
        if line.startswith("# ") and not line.startswith("## "):
            return line[2:].strip()
    return "Offer Booklet"


def extract_tagline_from_md(text):
    lines = text.split("\n")
    for i, line in enumerate(lines):
        if line.strip().startswith("# "):
            for j in range(i + 1, min(i + 5, len(lines))):
                stripped = lines[j].strip()
                if stripped.startswith("*") and stripped.endswith("*") and not stripped.startswith("**"):
                    return stripped.strip("*").strip()
    return ""


# ---------------------------------------------------------------------------
# Parse booklet into sections
# ---------------------------------------------------------------------------
def parse_booklet(md_text):
    """Split booklet markdown into sections by H2 headings."""
    sections = []
    current_title = None
    current_lines = []

    for line in md_text.split("\n"):
        stripped = line.strip()
        if stripped.startswith("## "):
            if current_title is not None:
                sections.append((current_title, "\n".join(current_lines)))
            current_title = stripped[3:].strip()
            current_lines = []
        elif stripped.startswith("# ") and not stripped.startswith("## "):
            continue  # skip H1 (cover title handled separately)
        else:
            if current_title is not None:
                current_lines.append(line)
            else:
                # Lines before first H2 (cover area)
                current_lines.append(line)

    if current_title is not None:
        sections.append((current_title, "\n".join(current_lines)))

    return sections


def section_to_flowables(title, body_text, styles, accent, is_first=False):
    """Convert a section title + body markdown into ReportLab flowables."""
    fl = []

    if not is_first:
        fl.append(PageBreak())

    fl.append(Spacer(1, 8 * mm))
    fl.append(Paragraph(inline_md(title), styles["section_title"]))
    fl.append(HRFlowable(
        width="100%", thickness=2, color=accent,
        spaceBefore=0, spaceAfter=6 * mm))

    lines = body_text.split("\n")
    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        # Skip empty
        if not stripped:
            i += 1
            continue

        # Horizontal rule
        if stripped == "---":
            fl.append(Spacer(1, 2 * mm))
            fl.append(HRFlowable(
                width="100%", thickness=0.5, color=RULE_LIGHT,
                spaceBefore=2 * mm, spaceAfter=3 * mm))
            i += 1
            continue

        # H3
        if stripped.startswith("### "):
            text = inline_md(stripped[4:].strip())
            fl.append(Paragraph(text, styles["h3"]))
            i += 1
            continue

        # Italic lines (tagline, visual suggestion)
        if stripped.startswith("*") and stripped.endswith("*") and not stripped.startswith("**"):
            text = stripped.strip("*").strip()
            fl.append(Paragraph(inline_md(text), styles["italic"]))
            i += 1
            continue

        # Bullet list
        if re.match(r'^[-*]\s', stripped):
            text = inline_md(stripped[2:].strip())
            fl.append(Paragraph(f'\u2022  {text}', styles["bullet"]))
            i += 1
            continue

        # Numbered list
        m_num = re.match(r'^(\d+)\.\s+(.+)', stripped)
        if m_num:
            num = m_num.group(1)
            text = inline_md(m_num.group(2).strip())
            fl.append(Paragraph(f'{num}.  {text}', styles["bullet"]))
            i += 1
            continue

        # "By" line or "Visual suggestion" (italic context)
        if stripped.startswith("By ") and len(stripped) < 60:
            fl.append(Paragraph(inline_md(stripped), styles["italic"]))
            i += 1
            continue

        if stripped.lower().startswith("visual suggestion"):
            fl.append(Paragraph(inline_md(stripped), styles["italic"]))
            i += 1
            continue

        # Regular paragraph
        fl.append(Paragraph(inline_md(stripped), styles["body"]))
        i += 1

    return fl


# ---------------------------------------------------------------------------
# Build the PDF
# ---------------------------------------------------------------------------
def build_pdf(input_path, output_path, accent_hex, title_override):
    register_fonts()
    accent = HexColor(accent_hex)

    with open(input_path) as f:
        raw = f.read()

    md_text = strip_frontmatter(raw)
    md_text = strip_html_comments(md_text)

    # Extract metadata
    title = title_override or extract_title_from_md(md_text)
    tagline = extract_tagline_from_md(md_text)
    sections = parse_booklet(md_text)

    styles = make_styles(accent)
    short_title = title

    fl = []

    # --- COVER PAGE ---
    fl.append(Spacer(1, 55 * mm))
    title_html = title.replace("&", "&amp;")
    fl.append(Paragraph(title_html, styles["cover_title"]))
    fl.append(Spacer(1, 6 * mm))

    if tagline:
        fl.append(Paragraph(tagline, styles["cover_subtitle"]))
        fl.append(Spacer(1, 8 * mm))

    fl.append(HRFlowable(
        width="60%", thickness=2, color=accent,
        spaceBefore=4 * mm, spaceAfter=4 * mm, hAlign="CENTER"))
    fl.append(Spacer(1, 6 * mm))
    fl.append(Paragraph("John Gordon, CoEngineers", styles["cover_author"]))
    fl.append(Paragraph("February 2026", styles["cover_author"]))

    # Switch to body template
    fl.append(NextPageTemplate("body"))
    fl.append(PageBreak())

    # --- BODY SECTIONS ---
    for idx, (sec_title, sec_body) in enumerate(sections):
        sec_fl = section_to_flowables(
            sec_title, sec_body, styles, accent, is_first=(idx == 0))
        fl.extend(sec_fl)

    # --- BACK COVER ---
    fl.append(NextPageTemplate("back"))
    fl.append(PageBreak())
    fl.append(Spacer(1, 80 * mm))
    fl.append(Paragraph(title.replace("&", "&amp;"), styles["back_title"]))
    fl.append(Spacer(1, 6 * mm))
    fl.append(Paragraph("John Gordon, CoEngineers", styles["back_body"]))
    fl.append(Paragraph("February 2026", styles["back_body"]))
    fl.append(Spacer(1, 10 * mm))
    fl.append(HRFlowable(
        width="40%", thickness=2, color=accent,
        spaceBefore=0, spaceAfter=6 * mm, hAlign="CENTER"))
    fl.append(Spacer(1, 6 * mm))
    fl.append(Paragraph(
        f'<a href="mailto:john@coengineers.ai" color="{accent_hex}">john@coengineers.ai</a>',
        styles["back_body"]))
    fl.append(Paragraph(
        f'<a href="https://coengineers.ai" color="{accent_hex}">coengineers.ai</a>',
        styles["back_body"]))

    # --- Build ---
    frame = Frame(
        MARGIN, 22 * mm,
        PAGE_W - 2 * MARGIN, PAGE_H - MARGIN - 22 * mm,
        id="main")

    doc = BaseDocTemplate(
        output_path, pagesize=A4,
        title=short_title,
        author="John Gordon, CoEngineers",
    )
    doc.addPageTemplates([
        PageTemplate(id="cover", frames=[frame],
                     onPage=make_cover_bg(accent)),
        PageTemplate(id="body", frames=[frame],
                     onPage=make_body_bg(accent, short_title)),
        PageTemplate(id="back", frames=[frame],
                     onPage=make_back_bg(accent)),
    ])

    doc.build(fl)
    print(f"PDF generated: {output_path} ({doc.page} pages)")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description="Convert offer booklet markdown to branded PDF")
    parser.add_argument("--input", required=True, help="Path to booklet markdown file")
    parser.add_argument("--output", required=True, help="Path for output PDF")
    parser.add_argument("--accent", default="#E87040", help="Accent colour hex (default: #E87040)")
    parser.add_argument("--title", default=None, help="Override title (extracted from markdown if omitted)")
    args = parser.parse_args()

    if not os.path.exists(args.input):
        print(f"Error: Input file not found: {args.input}", file=sys.stderr)
        sys.exit(1)

    build_pdf(args.input, args.output, args.accent, args.title)


if __name__ == "__main__":
    main()
