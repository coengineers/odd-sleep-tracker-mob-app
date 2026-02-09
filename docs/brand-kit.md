# CoEngineers Brand Kit

> Complete visual identity, design tokens, component patterns, and voice guidelines.
> Portable enough to replicate in web apps, mobile apps, or marketing sites.

**Version:** 1.1 — Updated 2026-02-06

| Version | Date       | Changes                                                                                                                                                                                                    |
| ------- | ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1.1     | 2026-02-06 | Fixed JSON config template, added accessibility section, added component states, added Do/Don't guidance, corrected `text-m` to `text-base`, corrected nav indicator `border-radius`, renamed spacing grid |
| 1.0     | —          | Initial brand kit                                                                                                                                                                                          |

---

## Table of Contents

- [1. Brand Identity](#1-brand-identity)
- [2. Logo & Mark](#2-logo--mark)
- [3. Colour System](#3-colour-system)
  - [3.1 Brand Orange](#31-brand-orange)
  - [3.2 Neutral Scale](#32-neutral-scale)
  - [3.3 Semantic Colours](#33-semantic-colours)
  - [3.4 Dark Mode (Default)](#34-dark-mode-default)
  - [3.5 Light Mode](#35-light-mode)
  - [3.6 Navigation Colours](#36-navigation-colours)
- [4. Typography](#4-typography)
- [5. Spacing & Layout](#5-spacing--layout)
- [6. Shadows & Depth](#6-shadows--depth)
- [7. Border & Radius](#7-border--radius)
- [8. Transitions & Micro-interactions](#8-transitions--micro-interactions)
- [9. Component Patterns](#9-component-patterns)
- [10. Iconography](#10-iconography)
- [11. Accessibility](#11-accessibility)
- [12. Voice & Tone](#12-voice--tone)
- [13. Platform Adaptation Notes](#13-platform-adaptation-notes)
- [Appendix: CSS Utility Quick Reference](#appendix-css-utility-quick-reference)
- [Appendix: Scrollbar Styling](#appendix-scrollbar-styling)
- [Appendix: Deprecated Tokens](#appendix-deprecated-tokens)

---

## 1. Brand Identity

- **Brand name:** CoEngineers
- **Design philosophy:** Modern Fintech Minimalism (Stripe x Linear x Notion)
- **Core principles:**
  1. Reduce visual noise
  2. Let hierarchy + spacing do the work
  3. Use orange for intent, not decoration
  4. Flat depth with soft shadows
  5. UX-first, dopamine-second

---

## 2. Logo & Mark

### Text Mark

The primary brand mark is a Satoshi bold letter "C" in a filled `bg-primary` (`#F7931A`) 8x8 box, paired with the word "CoEng" in Satoshi medium, coloured `#F7931A`.

```
 ┌──────┐
 │  C   │  CoEng
 └──────┘
  orange    orange text
  bg box    Satoshi heading font
  8x8
```

**Specifications:**

- Box: `h-8 w-8`, `bg-primary`, `text-primary-foreground`
- Letter: `font-heading`, `text-base`
- Wordmark: `font-heading`, `text-primary`, `text-base`
- No dedicated logo SVG exists — replicate using the text-mark pattern above

### Badge Icon

A medal SVG at `public/badge-icon.svg` is used for gamification features (achievements, streaks, challenges).

---

## 3. Colour System

### 3.1 Brand Orange

| Token                          | Value                                          | Usage                       |
| ------------------------------ | ---------------------------------------------- | --------------------------- |
| `--color-bitcoin-orange`       | `#F7931A`                                      | Primary brand colour        |
| `--color-bitcoin-orange-light` | `#FFB347`                                      | Hover/light variant         |
| `--color-bitcoin-orange-dark`  | `#C97500`                                      | Pressed/dark variant        |
| `--color-primary`              | `#F7931A`                                      | Alias for primary CTAs      |
| `--color-primary-foreground`   | `#FFFFFF` (token) / `#000000` (Tailwind theme) | Text on primary backgrounds |

> **Note:** The token layer defines primary-foreground as `#FFFFFF`, but the Tailwind `@theme` block overrides it to `#000000`. The Tailwind value (`#000000`) is what renders in components. Black on orange provides a 9.14:1 contrast ratio (AAA).

**Do — use orange for:**

- Primary CTAs and submit buttons
- Active navigation indicators (thin 3px left bar)
- Progress bars and loading states
- Key metrics and growth indicators
- Focus rings

**Don't — avoid orange for:**

- Backgrounds or large surface areas
- Decorative borders or icons in resting state
- Body text or headings
- Container backgrounds
- Text on light backgrounds (fails WCAG — see [Accessibility](#11-accessibility))

### 3.2 Neutral Scale

| Token                 | Value     |
| --------------------- | --------- |
| `--color-neutral-50`  | `#FAFAFA` |
| `--color-neutral-100` | `#F5F5F5` |
| `--color-neutral-200` | `#E5E5E5` |
| `--color-neutral-300` | `#D4D4D4` |
| `--color-neutral-400` | `#A3A3A3` |
| `--color-neutral-500` | `#737373` |
| `--color-neutral-600` | `#525252` |
| `--color-neutral-700` | `#404040` |
| `--color-neutral-800` | `#262626` |
| `--color-neutral-900` | `#171717` |
| `--color-neutral-950` | `#0A0A0A` |

### 3.3 Semantic Colours

| Token             | Value     | Usage                                  |
| ----------------- | --------- | -------------------------------------- |
| `--color-success` | `#22C55E` | Positive actions, confirmations        |
| `--color-warning` | `#EAB308` | Caution states                         |
| `--color-error`   | `#EF4444` | Destructive actions, validation errors |
| `--color-info`    | `#3B82F6` | Informational states                   |

### 3.4 Dark Mode (Default)

| Token                      | Value     | Usage                               |
| -------------------------- | --------- | ----------------------------------- |
| `--color-bg-app`           | `#0E0F12` | Main application background         |
| `--color-bg-surface`       | `#151821` | Card backgrounds, elevated surfaces |
| `--color-bg-surface-hover` | `#1C2030` | Hover states for surfaces           |
| `--color-border-fintech`   | `#23283A` | Borders, dividers, subtle lines     |
| `--color-border-subtle`    | `#1C2030` | Very subtle separators              |
| `--color-text-primary`     | `#E6E8EE` | Main content text                   |
| `--color-text-secondary`   | `#A2A8BD` | Supporting text, labels             |
| `--color-text-muted`       | `#6E748A` | Disabled, placeholder text          |

**Tailwind theme mappings (dark):**

| Tailwind Token                   | Resolved Value          |
| -------------------------------- | ----------------------- |
| `--color-background`             | `#0E0F12`               |
| `--color-foreground`             | `#E6E8EE`               |
| `--color-card`                   | `#171717` (neutral-900) |
| `--color-card-foreground`        | `#FAFAFA` (neutral-50)  |
| `--color-popover`                | `#171717` (neutral-900) |
| `--color-popover-foreground`     | `#FAFAFA` (neutral-50)  |
| `--color-secondary`              | `#262626` (neutral-800) |
| `--color-secondary-foreground`   | `#FAFAFA` (neutral-50)  |
| `--color-muted`                  | `#262626` (neutral-800) |
| `--color-muted-foreground`       | `#A3A3A3` (neutral-400) |
| `--color-accent`                 | `#262626` (neutral-800) |
| `--color-accent-foreground`      | `#FAFAFA` (neutral-50)  |
| `--color-destructive`            | `#EF4444`               |
| `--color-destructive-foreground` | `#FAFAFA` (neutral-50)  |
| `--color-border`                 | `#404040` (neutral-700) |
| `--color-input`                  | `#404040` (neutral-700) |
| `--color-ring`                   | `#F7931A`               |

**Sidebar tokens (dark):**

| Tailwind Token                       | Resolved Value          |
| ------------------------------------ | ----------------------- |
| `--color-sidebar`                    | `#171717` (neutral-900) |
| `--color-sidebar-foreground`         | `#FAFAFA` (neutral-50)  |
| `--color-sidebar-primary`            | `#F7931A`               |
| `--color-sidebar-primary-foreground` | `#000000`               |
| `--color-sidebar-accent`             | `#262626` (neutral-800) |
| `--color-sidebar-accent-foreground`  | `#FAFAFA` (neutral-50)  |
| `--color-sidebar-border`             | `#404040` (neutral-700) |

### 3.5 Light Mode

Applied via `.light` class on a parent element.

**Fintech tokens:**

| Token                       | Dark Value | Light Value |
| --------------------------- | ---------- | ----------- |
| `--color-bg-app`            | `#0E0F12`  | `#F8F9FA`   |
| `--color-bg-surface`        | `#151821`  | `#FFFFFF`   |
| `--color-bg-surface-hover`  | `#1C2030`  | `#F1F3F4`   |
| `--color-text-primary`      | `#E6E8EE`  | `#1A1D21`   |
| `--color-text-secondary`    | `#A2A8BD`  | `#5F6368`   |
| `--color-text-muted`        | `#6E748A`  | `#9AA0A6`   |
| `--color-border-fintech`    | `#23283A`  | `#E0E0E0`   |
| `--color-border-subtle`     | `#1C2030`  | `#F1F3F4`   |
| `--color-nav-icon-inactive` | `#7B8198`  | `#5F6368`   |

**Tailwind theme overrides (light):**

| Tailwind Token                      | Dark Value              | Light Value             |
| ----------------------------------- | ----------------------- | ----------------------- |
| `--color-background`                | `#0E0F12`               | `#FAFAFA` (neutral-50)  |
| `--color-foreground`                | `#E6E8EE`               | `#0A0A0A` (neutral-950) |
| `--color-card`                      | `#171717`               | `#FFFFFF`               |
| `--color-card-foreground`           | `#FAFAFA`               | `#0A0A0A` (neutral-950) |
| `--color-popover`                   | `#171717`               | `#FFFFFF`               |
| `--color-popover-foreground`        | `#FAFAFA`               | `#0A0A0A` (neutral-950) |
| `--color-secondary`                 | `#262626` (neutral-800) | `#F5F5F5` (neutral-100) |
| `--color-secondary-foreground`      | `#FAFAFA` (neutral-50)  | `#171717` (neutral-900) |
| `--color-muted`                     | `#262626` (neutral-800) | `#F5F5F5` (neutral-100) |
| `--color-muted-foreground`          | `#A3A3A3` (neutral-400) | `#737373` (neutral-500) |
| `--color-accent`                    | `#262626` (neutral-800) | `#F5F5F5` (neutral-100) |
| `--color-accent-foreground`         | `#FAFAFA` (neutral-50)  | `#171717` (neutral-900) |
| `--color-border`                    | `#404040`               | `#E5E5E5` (neutral-200) |
| `--color-input`                     | `#404040`               | `#E5E5E5` (neutral-200) |
| `--color-sidebar`                   | `#171717`               | `#F5F5F5` (neutral-100) |
| `--color-sidebar-foreground`        | `#FAFAFA`               | `#0A0A0A` (neutral-950) |
| `--color-sidebar-accent`            | `#262626` (neutral-800) | `#E5E5E5` (neutral-200) |
| `--color-sidebar-accent-foreground` | `#FAFAFA` (neutral-50)  | `#171717` (neutral-900) |
| `--color-sidebar-border`            | `#404040`               | `#E5E5E5` (neutral-200) |

### 3.6 Navigation Colours

| Token                       | Dark                | Light               |
| --------------------------- | ------------------- | ------------------- |
| `--color-nav-icon-inactive` | `#7B8198`           | `#5F6368`           |
| `--color-nav-icon-active`   | `#F7931A` (primary) | `#F7931A` (primary) |
| `--color-nav-indicator`     | `#F7931A` (primary) | `#F7931A` (primary) |

---

## 4. Typography

### 4.1 Font Stack

| Role             | Font           | Fallback                | Variable         |
| ---------------- | -------------- | ----------------------- | ---------------- |
| Headings (h1-h3) | Satoshi        | system-ui, sans-serif   | `--font-heading` |
| Body             | Nunito         | system-ui, sans-serif   | `--font-body`    |
| Code             | JetBrains Mono | ui-monospace, monospace | `--font-mono`    |

**Font sources:**

- Satoshi: [fontshare.com](https://www.fontshare.com/fonts/satoshi) or `@fontsource/satoshi`
- Nunito: [Google Fonts](https://fonts.google.com/specimen/Nunito) or `@fontsource/nunito`
- JetBrains Mono: [Google Fonts](https://fonts.google.com/specimen/JetBrains+Mono) or `@fontsource/jetbrains-mono`

### 4.2 Size Scale

| Token              | rem      | px   |
| ------------------ | -------- | ---- |
| `--font-size-xs`   | 0.75rem  | 12px |
| `--font-size-sm`   | 0.875rem | 14px |
| `--font-size-base` | 1rem     | 16px |
| `--font-size-lg`   | 1.125rem | 18px |
| `--font-size-xl`   | 1.25rem  | 20px |
| `--font-size-2xl`  | 1.5rem   | 24px |
| `--font-size-3xl`  | 1.875rem | 30px |
| `--font-size-4xl`  | 2.25rem  | 36px |

### 4.3 Weight Per Context

| Element              | Font    | Weight                         |
| -------------------- | ------- | ------------------------------ |
| h1, h2, h3           | Satoshi | 700                            |
| h4, h5, h6           | Nunito  | 700                            |
| Body                 | Nunito  | 400                            |
| `.text-heading-xs`   | Satoshi | 500                            |
| `.text-heading-sm`   | Satoshi | 500                            |
| `.text-heading-base` | Satoshi | 600                            |
| `.text-heading-lg`   | Satoshi | 600                            |
| `.text-heading-xl`   | Satoshi | 700                            |
| `.text-heading-2xl`  | Satoshi | 700                            |
| Numbers / KPIs       | —       | Tabular numbers, medium weight |

### 4.4 Line Heights

| Token                   | Value |
| ----------------------- | ----- |
| `--line-height-tight`   | 1.25  |
| `--line-height-normal`  | 1.5   |
| `--line-height-relaxed` | 1.75  |

### 4.5 Letter Spacing

| Context                     | Value            |
| --------------------------- | ---------------- |
| h1, h2, h3, `.font-heading` | `-0.02em`        |
| Body                        | Normal (default) |
| Numbers / KPIs              | Tight (tabular)  |

### 4.6 Heading Utility Classes

| Class                | Size     | Weight |
| -------------------- | -------- | ------ |
| `.text-heading-xs`   | 0.75rem  | 500    |
| `.text-heading-sm`   | 0.875rem | 500    |
| `.text-heading-base` | 1rem     | 600    |
| `.text-heading-lg`   | 1.125rem | 600    |
| `.text-heading-xl`   | 1.25rem  | 700    |
| `.text-heading-2xl`  | 1.5rem   | 700    |

All heading utilities use `font-family: var(--font-heading)` (Satoshi).

**Do — pair fonts correctly:**

- Satoshi headings with Nunito body text
- Satoshi for KPI numbers (with `font-variant-numeric: tabular-nums`)
- JetBrains Mono for code blocks, terminal output, and data tables with monospaced alignment

**Don't — avoid these pairings:**

- Nunito for headings (too soft, loses authority)
- Satoshi for long body copy (optimised for display, not reading)
- Mixing more than one heading font on a single view

---

## 5. Spacing & Layout

### 5.1 Spacing Scale (4px Base Grid)

The spacing scale uses a 4px base unit. Most layout decisions land on 8px multiples, but 4px and 12px steps are available for fine adjustments.

| Token        | Value |
| ------------ | ----- |
| `--space-1`  | 4px   |
| `--space-2`  | 8px   |
| `--space-3`  | 12px  |
| `--space-4`  | 16px  |
| `--space-5`  | 20px  |
| `--space-6`  | 24px  |
| `--space-8`  | 32px  |
| `--space-10` | 40px  |
| `--space-12` | 48px  |
| `--space-16` | 64px  |

### 5.2 Layout Dimensions

| Element              | Value                       |
| -------------------- | --------------------------- |
| Sidebar collapsed    | `--sidebar-collapsed`: 64px |
| Sidebar expanded     | `--sidebar-expanded`: 240px |
| Card padding         | 24-32px (`p-6` to `p-8`)    |
| Card header padding  | `p-6` (24px)                |
| Card content padding | `p-6 pt-0`                  |

### 5.3 Z-Index Scale

| Token                | Value | Usage            |
| -------------------- | ----- | ---------------- |
| `--z-base`           | 0     | Default stacking |
| `--z-dropdown`       | 10    | Dropdown menus   |
| `--z-sticky`         | 20    | Sticky headers   |
| `--z-fixed`          | 30    | Fixed elements   |
| `--z-modal-backdrop` | 40    | Modal overlay    |
| `--z-modal`          | 50    | Modal content    |
| `--z-tooltip`        | 60    | Tooltips         |

---

## 6. Shadows & Depth

### 6.1 Soft Shadow System

**Dark mode:**

| Token                 | Value                                                     |
| --------------------- | --------------------------------------------------------- |
| `--shadow-soft-sm`    | `0 1px 2px rgba(0,0,0,0.3), 0 4px 12px rgba(0,0,0,0.25)`  |
| `--shadow-soft`       | `0 1px 1px rgba(0,0,0,0.4), 0 8px 24px rgba(0,0,0,0.35)`  |
| `--shadow-soft-lg`    | `0 2px 4px rgba(0,0,0,0.4), 0 12px 32px rgba(0,0,0,0.4)`  |
| `--shadow-soft-hover` | `0 2px 4px rgba(0,0,0,0.4), 0 12px 28px rgba(0,0,0,0.38)` |

**Light mode:**

| Token                 | Value                                                     |
| --------------------- | --------------------------------------------------------- |
| `--shadow-soft-sm`    | `0 1px 2px rgba(0,0,0,0.04), 0 2px 6px rgba(0,0,0,0.06)`  |
| `--shadow-soft`       | `0 1px 2px rgba(0,0,0,0.06), 0 4px 12px rgba(0,0,0,0.08)` |
| `--shadow-soft-lg`    | `0 2px 4px rgba(0,0,0,0.06), 0 8px 24px rgba(0,0,0,0.1)`  |
| `--shadow-soft-hover` | `0 2px 4px rgba(0,0,0,0.08), 0 8px 20px rgba(0,0,0,0.1)`  |

> **Note:** Only use `shadow-soft-*` tokens in new work. Arcade shadow tokens are deprecated — see [Appendix: Deprecated Tokens](#appendix-deprecated-tokens).

---

## 7. Border & Radius

### 7.1 Radius Scale

| Token           | Value  | Usage                  |
| --------------- | ------ | ---------------------- |
| `--radius-none` | 0px    | Sharp corners          |
| `--radius-sm`   | 6px    | Small elements, badges |
| `--radius-md`   | 8px    | Buttons, inputs        |
| `--radius-lg`   | 12px   | Cards, dialogs         |
| `--radius-xl`   | 16px   | Large containers       |
| `--radius-full` | 9999px | Pill shapes, avatars   |

### 7.2 Component-Specific Radius

| Component           | Radius                              |
| ------------------- | ----------------------------------- |
| Button (default)    | `rounded-lg` (12px)                 |
| Button (sm, xs, lg) | `rounded-md` (8px)                  |
| Card                | `rounded-xl` (16px)                 |
| Input               | `rounded-lg` (12px)                 |
| Dialog              | `rounded-xl` (16px)                 |
| Badge               | `rounded-md` (8px)                  |
| Nav indicator bar   | `border-radius: 2px` on the 3px bar |

### 7.3 Border Colours

| Context        | Dark                    | Light                   |
| -------------- | ----------------------- | ----------------------- |
| Primary border | `#404040` (neutral-700) | `#E5E5E5` (neutral-200) |
| Fintech border | `#23283A`               | `#E0E0E0`               |
| Subtle border  | `#1C2030`               | `#F1F3F4`               |
| Focus ring     | `#F7931A` (primary)     | `#F7931A` (primary)     |

---

## 8. Transitions & Micro-interactions

### 8.1 Duration Tokens

| Token               | Value | Usage                               |
| ------------------- | ----- | ----------------------------------- |
| `--duration-fast`   | 150ms | Hovers, button presses              |
| `--duration-normal` | 300ms | Panel transitions, sidebar collapse |
| `--duration-slow`   | 500ms | Page-level transitions              |

### 8.2 Transition Presets

| Token                 | Value            | Usage                      |
| --------------------- | ---------------- | -------------------------- |
| `--transition-fast`   | `150ms ease-out` | Hovers, micro-interactions |
| `--transition-normal` | `200ms ease-out` | Standard state changes     |
| `--transition-slow`   | `300ms ease-out` | Layout shifts              |

### 8.3 Easing

Always `ease-out`. No bounce, no elastic, no shake.

### 8.4 Interaction Patterns

| Interaction      | Behaviour                                                                               |
| ---------------- | --------------------------------------------------------------------------------------- |
| Hover (surface)  | Background shifts to `--color-bg-surface-hover`, shadow shifts to `--shadow-soft-hover` |
| Hover (button)   | `brightness-110` filter                                                                 |
| Active (button)  | No special transform; arcade "press" effects are deprecated                             |
| Focus visible    | `2px solid #F7931A`, `outline-offset: 2px`                                              |
| Sidebar collapse | `duration-300` (300ms), `transition-all`                                                |
| Dialog enter     | `fade-in`, `zoom-in-95`, `slide-in-from-top-[48%]`                                      |
| Dialog exit      | `fade-out`, `zoom-out-95`, `slide-out-to-top-[48%]`                                     |

---

## 9. Component Patterns

### 9.1 Button

**Variants** (from CVA):

| Variant       | Style                                                           |
| ------------- | --------------------------------------------------------------- |
| `default`     | `bg-primary text-primary-foreground hover:brightness-110`       |
| `destructive` | `bg-destructive text-white hover:bg-destructive/90`             |
| `outline`     | `border-border-fintech bg-bg-surface hover:bg-bg-surface-hover` |
| `secondary`   | `bg-secondary text-secondary-foreground hover:bg-secondary/80`  |
| `ghost`       | `hover:bg-bg-surface-hover`                                     |
| `link`        | `text-primary underline-offset-4 hover:underline`               |

**Sizes:**

| Size      | Height          | Padding | Notes                   |
| --------- | --------------- | ------- | ----------------------- |
| `xs`      | 24px (h-6)      | `px-2`  | `text-xs`, `rounded-md` |
| `sm`      | 32px (h-8)      | `px-3`  | `rounded-md`            |
| `default` | 36px (h-9)      | `px-4`  | `rounded-lg`            |
| `lg`      | 40px (h-10)     | `px-6`  | `rounded-md`            |
| `icon`    | 36x36 (size-9)  | —       | Square icon button      |
| `icon-xs` | 24x24 (size-6)  | —       | `rounded-md`            |
| `icon-sm` | 32x32 (size-8)  | —       | Square icon button      |
| `icon-lg` | 40x40 (size-10) | —       | Square icon button      |

**Common styles:** `inline-flex items-center justify-center gap-2 text-sm font-medium transition-all duration-150 ease-out rounded-lg`

**Focus:** `focus-visible:ring-[3px] focus-visible:ring-ring/50 focus-visible:border-ring`

**States:**

| State        | Behaviour                                                                                  |
| ------------ | ------------------------------------------------------------------------------------------ |
| Disabled     | `pointer-events-none opacity-50`                                                           |
| Loading      | Replace label with a spinner (`size-4`), keep button dimensions, set `pointer-events-none` |
| aria-invalid | `ring-destructive/20 border-destructive`                                                   |

### 9.2 Card

**Anatomy:**

```
Card                bg-bg-surface text-card-foreground shadow-soft rounded-xl
├── CardHeader      p-6, flex-col, space-y-1.5
│   ├── CardTitle       font-heading text-lg tracking-tight
│   └── CardDescription text-muted-foreground text-sm
├── CardContent     p-6 pt-0
└── CardFooter      p-6 pt-0, flex items-center
```

**Interactive card utility:**

```css
card-surface-interactive:
  bg-bg-surface rounded-lg shadow-soft
  hover: bg-bg-surface-hover shadow-soft-hover
  transition: 150ms ease-out
```

**States:**

| State              | Behaviour                                                             |
| ------------------ | --------------------------------------------------------------------- |
| Loading / skeleton | Pulse `animate-pulse` on placeholder blocks inside card content areas |
| Empty              | Centre a muted icon + message inside `CardContent`                    |

**Do:** Use `bg-bg-surface` (not `bg-card`) for cards that sit on the app background.
**Don't:** Nest cards inside cards. Use section dividers or spacing instead.

### 9.3 Input / Form Field

**Anatomy:**

- Height: `h-10` (40px)
- Border: `border-border-fintech`
- Background: `bg-bg-surface`
- Radius: `rounded-lg`
- Padding: `px-3 py-2`
- Text: `text-base` (mobile), `md:text-sm` (desktop)
- Placeholder: `text-muted-foreground`
- Focus: `ring-2 ring-primary`
- Disabled: `cursor-not-allowed opacity-50`

**States:**

| State     | Behaviour                                                                                       |
| --------- | ----------------------------------------------------------------------------------------------- |
| Error     | `border-destructive ring-destructive/20` — pair with a `text-destructive text-sm` message below |
| Disabled  | `cursor-not-allowed opacity-50`, muted background                                               |
| Read-only | Same visual as default, no focus ring, `cursor-default`                                         |

### 9.4 Dialog / Modal

**Anatomy:**

```
DialogOverlay     fixed inset-0 z-50 bg-black/80
DialogContent     fixed center z-50 max-w-lg rounded-xl
                  border-border-fintech bg-bg-surface shadow-soft-lg p-6
├── DialogHeader  flex-col space-y-1.5
│   ├── DialogTitle        font-heading text-lg tracking-tight
│   └── DialogDescription  text-muted-foreground text-sm
├── (content)     gap-4
├── DialogFooter  flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2
└── Close button  absolute top-4 right-4, X icon (h-4 w-4)
```

**Animations:** fade + zoom (95%) + slide from top (48%), `duration-200`

### 9.5 Badge

**Variants:**

| Variant       | Style                                        |
| ------------- | -------------------------------------------- |
| `default`     | `bg-primary text-primary-foreground`         |
| `secondary`   | `bg-secondary text-secondary-foreground`     |
| `destructive` | `bg-destructive text-destructive-foreground` |
| `outline`     | `text-foreground` (border only)              |
| `success`     | `bg-green-600 text-white`                    |
| `warning`     | `bg-yellow-500 text-black`                   |

**Common styles:** `inline-flex items-center rounded-md border-border-fintech px-2.5 py-0.5 text-xs font-semibold`

> **Note:** The `warning` badge uses Tailwind's `bg-yellow-500` (`#EAB308`) which matches the semantic `--color-warning` token.

**States:**

| State      | Behaviour                                                      |
| ---------- | -------------------------------------------------------------- |
| Truncation | Apply `max-w-[200px] truncate` when badge content may overflow |

### 9.6 Avatar

**Specifications:**

- Size: `h-10 w-10` (40x40) default
- Border: `border-2 border-black`
- Overflow: hidden
- Image: `aspect-square h-full w-full`
- Fallback: `bg-muted font-heading text-xs`, centred

### 9.7 Navigation Item

**States:**

| State    | Style                                                             |
| -------- | ----------------------------------------------------------------- |
| Inactive | `text-nav-icon-inactive` (`#7B8198`)                              |
| Hover    | `text-text-secondary hover:bg-bg-surface-hover`                   |
| Active   | `text-primary` + 3px orange left bar via `before:` pseudo-element |

**Active indicator:**

```css
/* In globals.css @utility nav-indicator */
position: relative;
&::before {
  content: '';
  position: absolute;
  left: 0;
  top: 4px;
  bottom: 4px;
  width: 3px;
  background-color: var(--color-nav-indicator);
  border-radius: 2px;
}
```

**Icon size:** `h-5 w-5` (20x20)
**Item height:** `h-10` (40px)
**Padding:** `px-3`, `gap-3`
**Text:** `text-sm`

### 9.8 Focus Ring

Global focus-visible pattern:

```css
:focus-visible {
  outline: 2px solid #f7931a;
  outline-offset: 2px;
}
```

Button-specific: `focus-visible:ring-[3px] focus-visible:ring-ring/50`

---

## 10. Iconography

| Property               | Value                         |
| ---------------------- | ----------------------------- |
| Library                | Lucide React                  |
| Default size           | `h-5 w-5` (20x20)             |
| Button icon size       | `size-4` (16x16)              |
| Small button icon size | `size-3` (12x12)              |
| Close icon size        | `h-4 w-4` (16x16)             |
| Active colour          | `#F7931A` (primary)           |
| Inactive colour        | `#7B8198` (nav-icon-inactive) |
| Stroke width           | Default (2px)                 |

---

## 11. Accessibility

### 11.1 Contrast Ratios (WCAG 2.1)

**Dark mode** (on `#0E0F12` app background):

| Pairing                                        | Ratio  | AA Normal | AA Large |
| ---------------------------------------------- | ------ | --------- | -------- |
| `--color-text-primary` (`#E6E8EE`) on app bg   | 15.6:1 | Pass      | Pass     |
| `--color-text-secondary` (`#A2A8BD`) on app bg | 8.1:1  | Pass      | Pass     |
| `--color-text-muted` (`#6E748A`) on app bg     | 4.1:1  | **Fail**  | Pass     |
| `--color-text-primary` on surface (`#151821`)  | 14.5:1 | Pass      | Pass     |
| `--color-text-secondary` on surface            | 7.5:1  | Pass      | Pass     |
| `--color-text-muted` on surface                | 3.8:1  | **Fail**  | Pass     |
| `#F7931A` (orange) on app bg                   | 8.3:1  | Pass      | Pass     |
| `#F7931A` on surface                           | 7.7:1  | Pass      | Pass     |
| `#000000` on `#F7931A` (button text)           | 9.1:1  | Pass      | Pass     |
| `#FFFFFF` on `#F7931A`                         | 2.3:1  | **Fail**  | **Fail** |

**Light mode** (on `#F8F9FA` app background):

| Pairing                                        | Ratio  | AA Normal | AA Large |
| ---------------------------------------------- | ------ | --------- | -------- |
| `--color-text-primary` (`#1A1D21`) on app bg   | 16.1:1 | Pass      | Pass     |
| `--color-text-secondary` (`#5F6368`) on app bg | 5.7:1  | Pass      | Pass     |
| `--color-text-muted` (`#9AA0A6`) on app bg     | 2.5:1  | **Fail**  | **Fail** |
| `--color-text-primary` on surface (`#FFFFFF`)  | 16.9:1 | Pass      | Pass     |
| `--color-text-secondary` on surface            | 6.1:1  | Pass      | Pass     |
| `--color-text-muted` on surface                | 2.6:1  | **Fail**  | **Fail** |
| `#F7931A` on surface (`#FFFFFF`)               | 2.3:1  | **Fail**  | **Fail** |

### 11.2 Guidance

**Muted text colour:**

- In dark mode, `--color-text-muted` (`#6E748A`) passes AA for large text only (18px+ or 14px bold). Use it exclusively for placeholder text, disabled labels, and non-essential metadata — never for actionable or informational content.
- In light mode, `--color-text-muted` (`#9AA0A6`) fails all WCAG levels. Restrict usage to decorative or supplementary text that is also conveyed through other means (icons, position).

**Orange on light backgrounds:**

- `#F7931A` on white/light surfaces fails WCAG. In light mode, use orange only for non-text elements (icons, borders, progress bars) or pair with a dark background.

**White text on orange:**

- Never use white text on `#F7931A` (2.3:1). Always use black (`#000000`, 9.1:1) — this is already the default via `--color-primary-foreground` in the Tailwind theme.

### 11.3 Colour-Blind Considerations

- Orange (`#F7931A`) and green (`#22C55E`) are distinguishable for most forms of colour blindness, but can appear similar under deuteranopia. Pair semantic colours with icons or labels (e.g., checkmark for success, warning triangle for caution).
- Never rely on colour alone to convey meaning. Use shape, text, or position as secondary indicators.

### 11.4 Touch Targets

- Minimum interactive target: 44x44px (Apple HIG) / 48x48dp (Material Design)
- Current button default `h-9` (36px) relies on padding/margin for tap area. On mobile, scale to `h-10` (40px) minimum.
- Icon buttons (`size-9` = 36px, `size-6` = 24px) should have at least 44px hit area via padding or `min-h`/`min-w`.

### 11.5 Focus Indicators

- All interactive elements use `outline: 2px solid #F7931A; outline-offset: 2px` via `:focus-visible`
- Buttons add a 3px ring: `focus-visible:ring-[3px] focus-visible:ring-ring/50`
- Focus indicators must remain visible in both dark and light modes — `#F7931A` maintains sufficient contrast on all background surfaces

---

## 12. Voice & Tone

### 12.1 Tone Pillars

| Pillar        | Meaning                                                        |
| ------------- | -------------------------------------------------------------- |
| **Direct**    | Straightforward, clear communication. No fluff.                |
| **Confident** | Assured and authoritative. We know what we're doing.           |
| **Helpful**   | Supportive and useful. Always oriented toward the user's goal. |
| **No-BS**     | No nonsense, authentic. Say what needs to be said.             |

### 12.2 Language

- **Locale:** en-GB (British English)
- Use "colour" not "color" in user-facing copy, "organisation" not "organization", etc.
- Technical contexts (code, CSS, APIs) use standard en-US spellings

### 12.3 Words to Avoid

| Word/Phrase | Why                     | Instead                                     |
| ----------- | ----------------------- | ------------------------------------------- |
| "maybe"     | Undermines confidence   | "consider", "you can", or state it directly |
| "just"      | Minimises the action    | Remove it or describe the action plainly    |
| "I think"   | Hedging                 | State the recommendation directly           |
| "sorry"     | Unnecessary apologising | "Here's what happened" or "Let's fix this"  |

### 12.4 Brand Config Template

For replicating the brand in external tools and templates:

```json
{
  "brand": "CoEngineers",
  "version": "1.1",
  "colours": {
    "primary": "#F7931A",
    "primaryForeground": "#000000",
    "secondary": "#262626",
    "background": "#0E0F12",
    "surface": "#151821",
    "text": "#E6E8EE",
    "textSecondary": "#A2A8BD",
    "textMuted": "#6E748A",
    "border": "#23283A",
    "success": "#22C55E",
    "warning": "#EAB308",
    "error": "#EF4444",
    "info": "#3B82F6"
  },
  "typography": {
    "fontFamily": {
      "heading": "Satoshi",
      "body": "Nunito",
      "mono": "JetBrains Mono"
    },
    "fontSize": {
      "h1": "2.25rem",
      "h2": "1.875rem",
      "h3": "1.5rem",
      "body": "1rem",
      "small": "0.875rem"
    }
  },
  "voice": {
    "tone": ["direct", "confident", "helpful", "no-bs"],
    "language": "en-GB",
    "avoid": ["maybe", "just", "I think", "sorry"]
  }
}
```

---

## 13. Platform Adaptation Notes

### 13.1 Mobile Considerations

- **Touch targets:** Minimum 44x44px (Apple HIG) / 48x48dp (Material). Current button `h-9` (36px) should be scaled up to `h-10` (40px) minimum on mobile.
- **Spacing:** Use the same 4px base grid; increase padding by one step (e.g., `--space-4` becomes `--space-5`) for touch-friendly layouts.
- **Typography:** Maintain the same scale; body text minimum 16px to prevent iOS zoom on inputs.
- **Sidebar:** Converts to a bottom tab bar or hamburger drawer on mobile. Use the same icon sizes and active indicator colour.

### 13.2 Font Alternatives

| Context        | Primary            | Alternative                                   |
| -------------- | ------------------ | --------------------------------------------- |
| Headings       | Satoshi            | Inter (weight 500-700)                        |
| Body           | Nunito             | Inter or system default                       |
| Code           | JetBrains Mono     | Fira Code, SF Mono, Menlo                     |
| iOS native     | Satoshi (embedded) | SF Pro Display (headings), SF Pro Text (body) |
| Android native | Satoshi (embedded) | Google Sans (headings), Roboto (body)         |

---

## Appendix: CSS Utility Quick Reference

| Utility                    | What it applies                                                  |
| -------------------------- | ---------------------------------------------------------------- |
| `card-surface`             | `bg-bg-surface rounded-lg shadow-soft`                           |
| `card-surface-interactive` | Above + hover state with `bg-bg-surface-hover shadow-soft-hover` |
| `shadow-soft`              | `0 1px 1px rgba(0,0,0,0.4), 0 8px 24px rgba(0,0,0,0.35)`         |
| `shadow-soft-sm`           | `0 1px 2px rgba(0,0,0,0.3), 0 4px 12px rgba(0,0,0,0.25)`         |
| `shadow-soft-lg`           | `0 2px 4px rgba(0,0,0,0.4), 0 12px 32px rgba(0,0,0,0.4)`         |
| `text-fintech-primary`     | `color: var(--color-text-primary)`                               |
| `text-fintech-secondary`   | `color: var(--color-text-secondary)`                             |
| `text-fintech-muted`       | `color: var(--color-text-muted)`                                 |
| `nav-indicator`            | 3px orange left bar via `::before` pseudo-element                |
| `.font-heading`            | Satoshi, weight 700, letter-spacing -0.02em                      |
| `.font-mono`               | JetBrains Mono                                                   |

---

## Appendix: Scrollbar Styling

**Dark mode:**

- Track: `#262626` (neutral-800)
- Thumb: `#525252` (neutral-600), border `#262626`
- Thumb hover: `#F7931A` (bitcoin-orange)

**Light mode:**

- Track: `#F5F5F5` (neutral-100)
- Thumb: `#D4D4D4` (neutral-300), border `#F5F5F5`
- Thumb hover: `#F7931A` (bitcoin-orange)

Width: 8px. Height: 8px.

---

## Appendix: Deprecated Tokens

> These tokens remain in the codebase for backward compatibility. **Do not use in new work.**

### Arcade Shadows

| Token                    | Value                 |
| ------------------------ | --------------------- |
| `--shadow-arcade`        | `4px 4px 0px #000`    |
| `--shadow-arcade-sm`     | `2px 2px 0px #000`    |
| `--shadow-arcade-lg`     | `6px 6px 0px #000`    |
| `--shadow-arcade-orange` | `4px 4px 0px #F7931A` |

Light mode arcade shadow uses `--color-neutral-400` (`#A3A3A3`) instead of `#000`.

### Arcade Utilities

| Utility                | Status                                               |
| ---------------------- | ---------------------------------------------------- |
| `arcade-border`        | Deprecated — use `card-surface` instead              |
| `arcade-border-sm`     | Deprecated                                           |
| `arcade-border-lg`     | Deprecated                                           |
| `arcade-border-orange` | Deprecated                                           |
| `btn-arcade`           | Deprecated — use standard `Button` variant `default` |
| `card-arcade`          | Deprecated — use `card-surface`                      |
| `pixel-corners`        | Deprecated                                           |
