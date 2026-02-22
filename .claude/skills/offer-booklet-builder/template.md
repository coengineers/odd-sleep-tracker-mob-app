# Offer Booklet Template

This is the fixed 7-section template for all offer booklets. Every booklet uses this exact structure — no sections can be added, removed, or reordered.

Use horizontal rules (`---`) between each section in the output.

---

## Section 1: Cover Page

```markdown
# [Offer Name]

*[Tagline — one sentence that captures the transformation]*

By [Author/Brand Name]

**Visual suggestion:** [A brief description of an appropriate cover image or design direction for the user to create or commission. Keep it to 1-2 sentences.]
```

**Content source:** `01_offer/offer_definition.md` (title, tagline)

**Guidance:**
- The offer name should be large and prominent (H1)
- The tagline should capture the core transformation in a single sentence
- The visual suggestion is a creative brief, not a command — something like "A calm workspace with a laptop showing a dashboard" gives the user direction without being prescriptive

---

## Section 2: The Offer

```markdown
## The Offer

[2-3 clear paragraphs covering:]
- What the offer is
- The core value proposition
- What problem it solves
- The transformation the buyer can expect
```

**Content source:** `01_offer/offer_definition.md`

**Guidance:**
- Lead with what the buyer gets, not with the creator's backstory
- Be specific about the transformation — "you'll have a working app in two weeks" is better than "you'll learn new skills"
- Keep it to 2-3 paragraphs. If the vault content is extensive, distil it down to the essentials

---

## Section 3: Who It's For

```markdown
## Who It's For

[Cover all four of these aspects:]
- Target avatar description (who is the ideal buyer?)
- Their current situation (pain points, frustrations)
- Their desired situation (goals, aspirations)
- Why this offer is specifically for them (and not for everyone)
```

**Content source:** `02_audience/target_avatar.md`

**Guidance:**
- The reader should recognise themselves in this section. Write it as though you're describing them back to them.
- Include a "this is NOT for you if..." element where possible — exclusion builds trust and signals confidence
- Use second person ("you") to make it personal

---

## Section 4: What You Get

```markdown
## What You Get

- **[Deliverable 1]** — [1-2 sentence description focused on the outcome]
- **[Deliverable 2]** — [1-2 sentence description focused on the outcome]
- **[Deliverable 3]** — [1-2 sentence description focused on the outcome]
[... continue for all deliverables]
```

**Content source:** `01_offer/offer_definition.md` (deliverables section)

**Guidance:**
- Frame every deliverable as an outcome, not a feature. The buyer cares about what they can do with it, not what it technically is.
- Good: "A complete sleep tracking app (React Native) — ready to customise and deploy to the App Store"
- Bad: "Source code files in a zip archive"
- Each bullet should have the deliverable name in bold, followed by a dash and a brief description

---

## Section 5: How It Works

```markdown
## How It Works

[Step-by-step methodology or process, covering:]
- How the buyer goes from purchase to result
- Timeline or milestones (e.g. "Week 1: Set up your vault. Week 2: Build the app.")
- What support or resources are included
```

**Content source:** `01_offer/offer_definition.md` (methodology section)

**Guidance:**
- Number the steps if the process is sequential
- Include realistic timeframes — the buyer should know what to expect and when
- Mention any support channels, community access, or resources that come with the offer

---

## Section 6: Pricing

```markdown
## Pricing

[Cover all of these:]
- The price point (be direct and confident)
- Justification for the price (value-based, not cost-based)
- Reference to the Value Equation scores if available
- Any guarantees, refund policies, or risk-reversal
- Comparison to alternatives (what would it cost to do this another way?)
```

**Content source:** `01_offer/value_equation.md`, `01_offer/offer_definition.md`

**Guidance:**
- Lead with confidence. State the price clearly, then justify it.
- Value-based justification means showing what the buyer gets relative to the price, not explaining your costs
- If Value Equation scores are available (Dream Outcome, Perceived Likelihood, Time Delay, Effort & Sacrifice), weave them into the justification naturally — don't just dump the scores
- Comparison to alternatives helps the buyer see the price in context: "A freelance developer would charge £3,000+ for this. A bootcamp takes 12 weeks and costs £5,000."

---

## Section 7: Next Steps / CTA

```markdown
## Next Steps

[Cover all of these:]
- Clear, single call to action (what should the reader do next?)
- Link to the Gumroad page or purchase URL
- Any urgency or scarcity (only if genuine — never fabricate this)
- Contact information or community link
- A closing line that reinforces the transformation
```

**Content source:** `01_offer/gumroad_landing.md`

**Guidance:**
- One CTA only. Don't give the reader three different things to do.
- If there's no genuine urgency or scarcity, don't invent it. Simply make the CTA compelling on its own merits.
- The closing line should echo the transformation from Section 2, bringing the booklet full circle
