---
name: offer-validator
description: Scores an offer using Hormozi's Value Equation (Dream Outcome, Perceived Likelihood, Time Delay, Effort & Sacrifice). Reads the offer definition from the user's vault and produces individual scores (1-10), an overall value score, and specific improvement recommendations. Use when the user wants to validate, score, or stress-test their offer before launching. Also trigger when the user mentions "value equation", "offer score", "offer validation", or asks whether their offer is strong enough.
---

# Offer Validator

Scores an offer using Hormozi's Value Equation. Reads the user's vault, evaluates each component on a 1–10 scale, computes an overall value score, and delivers specific, actionable improvement recommendations.

**Scope**: This skill uses ONLY the Hormozi Value Equation. It does not implement the full *$100M Offers* framework (no Grand Slam Offer structure, no bonuses framework, no guarantee stacking). Just the Value Equation.

## The Value Equation

```
Value = (Dream Outcome × Perceived Likelihood) / (Time Delay × Effort & Sacrifice)
```

The numerator captures how desirable and believable the offer is. The denominator captures how much friction stands between the buyer and the result. Higher value = better offer.

For the full breakdown of each component with scoring rubrics, read `value-equation.md` in this skill's directory. For a complete scored example, read `examples/sleep-tracker-score.md`.

## How to Use This Skill

### Step 1 — Locate the Vault

The user provides a path to their vault directory. Read these files:

1. `01_offer/offer_definition.md` — the primary source for scoring
2. `02_audience/target_avatar.md` — for understanding the buyer's perspective
3. `01_offer/value_equation.md` — if it exists, the user's self-assessment (compare later)

If a file is missing, note it and work with what you have. If the offer definition itself is missing or too thin to score (fewer than ~100 words of substance), say so plainly and suggest what content to add before scoring.

### Step 2 — Score Each Component

Read `value-equation.md` for the detailed scoring rubrics. Score each component 1–10:

1. **Dream Outcome** — How desirable is the end result for the target audience?
2. **Perceived Likelihood** — How likely does the buyer think they will achieve it?
3. **Time Delay** — How quickly does the buyer see results? (10 = instant, 1 = years)
4. **Effort & Sacrifice** — How easy is it for the buyer? (10 = effortless, 1 = very hard)

Score from the **buyer's perspective** (the target avatar), not the creator's. Base scores on what is actually written in the vault — not assumptions. Every score needs a 1–2 sentence justification referencing specific vault content.

Do not inflate scores to be encouraging. Honest assessment is more valuable than flattery.

### Step 3 — Calculate the Overall Value Score

Time Delay and Effort & Sacrifice sit in the denominator, but we score them where high = good (fast/easy). So we invert them before dividing:

```
Time Delay_inverted   = 11 - Time Delay score
Effort_inverted       = 11 - Effort & Sacrifice score

Overall = (Dream Outcome × Perceived Likelihood) / (Time Delay_inverted × Effort_inverted)
```

Cap the result at 10: `min(10, Overall)`.

Show the formula with actual numbers so the user can see exactly how the score was computed.

**Worked example**: Dream = 8, Likelihood = 7, Time Delay = 8, Effort = 7
→ (8 × 7) / ((11−8) × (11−7)) = 56 / 12 = 4.67

### Step 4 — Compare Against Self-Assessment (If Available)

If the vault contains `01_offer/value_equation.md` with the user's own scores, compare your assessment against theirs. Flag any discrepancy of ±3 points or more — the user may be overestimating or underestimating a component, and the gap is worth discussing.

### Step 5 — Write Recommendations

Produce exactly three recommendations:

1. **Highest priority** — addresses the weakest score. Include current score, target score (+2), and a specific, actionable step the user can take. Reference their actual offer content.
2. **Second priority** — addresses the second weakest score. Same format.
3. **General recommendation** — a structural suggestion for overall value improvement.

Recommendations must be concrete. Not "improve your offer" but "Add a day-by-day timeline showing when the user will see their first results. This addresses the Time Delay score by making quick wins visible."

### Step 6 — Output the Report

Use this exact format:

```
═══════════════════════════════════════════════════
  OFFER VALIDATION REPORT
═══════════════════════════════════════════════════

  Offer:    [Offer name from vault]
  Audience: [Target avatar summary]
  Date:     [YYYY-MM-DD]

───────────────────────────────────────────────────
  VALUE EQUATION SCORES
───────────────────────────────────────────────────

  Dream Outcome:          [X]/10
  [1-2 sentence justification]

  Perceived Likelihood:   [X]/10
  [1-2 sentence justification]

  Time Delay:             [X]/10
  [1-2 sentence justification]

  Effort & Sacrifice:     [X]/10
  [1-2 sentence justification]

───────────────────────────────────────────────────
  OVERALL VALUE SCORE
───────────────────────────────────────────────────

  Formula: ([Dream] × [Likelihood]) / ([11-TimeDelay] × [11-Effort])
  Calculation: ([X] × [X]) / ([X] × [X]) = [result]

  Overall Value: [X.X]/10

  [One sentence overall assessment]

───────────────────────────────────────────────────
  RECOMMENDATIONS
───────────────────────────────────────────────────

  1. [HIGHEST PRIORITY — addresses the weakest score]
     Current score: [X]/10
     Target score: [X+2]/10
     Action: [Specific, actionable recommendation referencing
     the user's actual offer content]

  2. [SECOND PRIORITY — addresses the second weakest score]
     Current score: [X]/10
     Target score: [X+2]/10
     Action: [Specific, actionable recommendation]

  3. [GENERAL RECOMMENDATION — overall value improvement]
     Action: [A structural suggestion for increasing overall value]

═══════════════════════════════════════════════════
```

If a self-assessment comparison was done, add a section after RECOMMENDATIONS:

```
───────────────────────────────────────────────────
  SELF-ASSESSMENT COMPARISON
───────────────────────────────────────────────────

  Component              You    This Review    Gap
  Dream Outcome          [X]    [X]            [±X]
  Perceived Likelihood   [X]    [X]            [±X]
  Time Delay             [X]    [X]            [±X]
  Effort & Sacrifice     [X]    [X]            [±X]

  [Commentary on any significant discrepancies (±3 or more)]
```

## Behaviour Rules

1. Scores must be based on what is actually written in the vault, not assumptions.
2. Every score must include a justification referencing specific vault content.
3. Recommendations must be specific and actionable — not generic advice.
4. Evaluate from the buyer's perspective (the target avatar), not the creator's.
5. Do not inflate scores. Honest, constructive assessment beats flattery.
6. If the offer definition is too thin, say so and suggest what to add.
7. Time Delay and Effort scores are inverted in the formula (high = fast/easy = good). Make this clear in justifications.
8. Show the formula and working so the user understands the calculation.
9. Write in British English.
10. If the user has an existing self-assessment, compare and note discrepancies of ±3 or more.
