# Feature Specification: Flutter Scaffold & Navigation (D0)

**Feature Branch**: `001-flutter-scaffold-nav`
**Created**: 2026-02-09
**Status**: Draft
**Input**: User description: "Implement D0 from /docs/PRD.md — Flutter scaffold & navigation"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Launch App and See Home Screen (Priority: P1)

A user installs the app for the first time, opens it, and immediately
sees a Home screen with a clear layout and a call-to-action to log
their first sleep entry. The app loads without requiring any account
setup, network connection, or onboarding flow.

**Why this priority**: The Home screen is the entry point for every
user session. If the app does not boot to a usable Home screen,
nothing else matters.

**Independent Test**: Launch the app on a device in airplane mode.
The Home screen renders with the brand-correct theme, the empty-state
message is visible, and the "Log sleep" CTA is tappable.

**Acceptance Scenarios**:

1. **Given** a fresh install on a device in airplane mode,
   **When** the user opens the app,
   **Then** the Home screen renders within 2 seconds (cold start)
   with the app title, an empty-state message ("No sleep logged yet.
   Add last night's sleep to start tracking."), and a visible "Log
   sleep" call-to-action.

2. **Given** the app is already running,
   **When** the user returns to the Home screen from any other screen,
   **Then** the Home screen renders and no network requests are made.

---

### User Story 2 - Navigate to All Screens (Priority: P1)

From the Home screen, the user can navigate to each of the four main
screens (Home, Log Entry, History, Insights) and return. Every screen
shows a placeholder shell that confirms the route is reachable.

**Why this priority**: Navigation is the structural backbone. All
future deliverables (D1-D5) depend on routes being defined and
reachable. Without working navigation, no subsequent feature can be
built or tested.

**Independent Test**: Starting from Home, tap each navigation target
and verify the correct screen shell renders. Use the back button or
navigation to return to Home after each visit.

**Acceptance Scenarios**:

1. **Given** the user is on the Home screen,
   **When** the user taps "Log sleep" (or equivalent CTA),
   **Then** the Log Entry screen shell renders with a back navigation
   affordance to return to Home.

2. **Given** the user is on the Home screen,
   **When** the user navigates to History,
   **Then** the History screen shell renders with the screen title
   visible.

3. **Given** the user is on the Home screen,
   **When** the user navigates to Insights,
   **Then** the Insights screen shell renders with the screen title
   visible.

4. **Given** the user is on the History screen,
   **When** the user taps an entry (placeholder for future edit flow),
   **Then** the Log Entry screen shell renders (reusing the same
   route, parameterised for edit mode in future deliverables).

5. **Given** the user is on any child screen (Log Entry, History,
   Insights),
   **When** the user uses back navigation,
   **Then** the user returns to the Home screen.

---

### User Story 3 - Brand-Compliant Visual Identity (Priority: P2)

The app renders with the CoEngineers brand identity: dark theme as
default, brand orange for primary accents, Satoshi font for headings,
Nunito for body text, and consistent spacing and radius tokens. The
visual identity is established once in the scaffold so all subsequent
screens inherit it automatically.

**Why this priority**: Establishing the theme in D0 means every
subsequent deliverable gets brand compliance for free. Deferring
theming creates rework across all screens later.

**Independent Test**: Launch the app and visually verify: dark
background (`#0E0F12`), brand orange CTA (`#F7931A`), Satoshi
headings, Nunito body text. Confirm text is readable (sufficient
contrast) and touch targets meet minimum size.

**Acceptance Scenarios**:

1. **Given** the app launches,
   **When** the Home screen renders,
   **Then** the background colour is the brand dark mode default,
   heading text uses the Satoshi font family, and body text uses the
   Nunito font family.

2. **Given** the app launches,
   **When** the user views any primary action button,
   **Then** the button uses brand orange (`#F7931A`) as its
   background with black text (`#000000`) for contrast.

3. **Given** the app launches,
   **When** the user views any interactive element,
   **Then** the element has a minimum tap area of 44x44 points.

---

### Edge Cases

- What happens when the device has extremely large or small text
  accessibility settings? Screen shells MUST remain usable and not
  clip or overflow. Body text minimum is 16px to prevent iOS input
  zoom.
- What happens when the user rapidly navigates between screens?
  Navigation MUST not produce duplicate route entries on the stack
  or cause visual glitches.
- What happens on devices with notches, dynamic islands, or
  non-standard safe areas? Screen content MUST respect safe area
  insets.
- What happens when the user rotates the device? The scaffold MUST
  handle portrait orientation gracefully (no crash on rotation).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-D0-001**: The app MUST boot to the Home screen without
  requiring any account, sign-in, or network connection.
- **FR-D0-002**: The app MUST define routes for four screens: Home,
  Log Entry, History, and Insights.
- **FR-D0-003**: The user MUST be able to navigate from Home to Log
  Entry, History, and Insights, and return to Home via back
  navigation.
- **FR-D0-004**: The user MUST be able to navigate from History to
  Log Entry (for future edit flow), reusing the same route.
- **FR-D0-005**: Each screen MUST render a shell with a visible
  screen title and placeholder content indicating its purpose.
- **FR-D0-006**: The Home screen MUST display an empty-state message
  and a "Log sleep" call-to-action when no data exists.
- **FR-D0-007**: The app MUST apply the CoEngineers brand theme
  (dark mode default) with correct colour tokens, typography, spacing,
  and radius values from the brand kit.
- **FR-D0-008**: All fonts (Satoshi for headings, Nunito for body)
  MUST be bundled as app assets — no runtime font downloads.
- **FR-D0-009**: All interactive elements MUST have a minimum tap
  area of 44x44 points.
- **FR-D0-010**: Navigation from Home to child screens MUST use
  push-style navigation (preserving the back stack) rather than
  replace-style navigation.

### Key Entities

- **Screen Shell**: A placeholder screen with a title, optional
  subtitle, and placeholder body content. Serves as the mounting
  point for future feature implementation.
- **Route**: A named navigation destination with a defined path and
  associated screen widget. Routes form the navigation graph of the
  app.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The app boots to the Home screen in under 2 seconds
  (cold start) on a mid-range device with no network connection.
- **SC-002**: A user can navigate from Home to every other screen and
  back within 5 seconds total, completing a full navigation loop.
- **SC-003**: All four screens are reachable and render their shell
  content without errors or blank screens.
- **SC-004**: The app produces zero crashes during a navigation
  smoke test covering all defined routes.
- **SC-005**: The visual theme matches the brand kit specification:
  correct background colour, primary accent colour, heading font, and
  body font are applied consistently across all screens.
- **SC-006**: No network requests are made at any point during app
  usage (verified via inspection).

## Assumptions

- Navigation uses a Home-centric pattern: Home is the root, and all
  other screens are pushed onto the navigation stack from Home (or
  from History for the edit flow). Bottom tab navigation is not used
  in v1; Home provides direct links/buttons to each destination.
- Screen shells are intentionally minimal — they display a title and
  placeholder text only. Actual screen content (forms, lists, charts)
  is deferred to D1-D4.
- The Log Entry route accepts an optional parameter (entry ID) to
  support future edit mode, but in D0 the parameter is not used.
- Portrait orientation is the primary layout. The app handles rotation
  gracefully (no crash) but does not optimise for landscape.
- Light mode theming is deferred to a future deliverable. Only dark
  mode is implemented in D0.
