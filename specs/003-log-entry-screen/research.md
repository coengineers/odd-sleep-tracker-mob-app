# Research: Log Entry Screen (D2)

**Feature**: `003-log-entry-screen`
**Date**: 2026-02-10

## R1: Form State Management Approach

**Decision**: Use `ConsumerStatefulWidget` with local form state (no separate state management library).

**Rationale**: The Log Entry form has only 4 fields (bedtime, wake time, quality, note) with straightforward validation. A `ConsumerStatefulWidget` with `setState` for form fields and a Riverpod provider for the async save operation is the simplest correct approach. No need for formz, reactive_forms, or bloc — they add complexity without proportional benefit for a 4-field form.

**Alternatives considered**:
- **formz**: Form validation library. Rejected — our validation logic already exists in `sleep_entry_model.dart` (`validateCreateInput`, `validateUpdateInput`). Adding formz would duplicate validation or require adapting existing validators to formz's `FormzInput` pattern.
- **flutter_form_builder**: Higher-level form widgets. Rejected — we need brand-compliant custom styling (brand kit inputs), which form_builder's opinionated widgets would fight against.
- **Riverpod StateNotifier for form fields**: Would move form state out of the widget tree. Rejected — the form is screen-local and ephemeral. Local state is simpler, faster, and matches Flutter's intended pattern for forms.

## R2: Date/Time Picker Strategy

**Decision**: Use `showDatePicker` + `showTimePicker` (Flutter Material built-ins) composed into a "pick date then pick time" flow for each field. Display the selected datetime in a tappable card/row.

**Rationale**: The PRD specifies "platform date/time pickers" (FR-009). Flutter's Material pickers are platform-adaptive (Material 3 on Android, Cupertino-style on iOS when using `.adaptive` constructors or theme settings). They are well-tested, accessible out of the box, and require zero additional dependencies.

**Alternatives considered**:
- **CupertinoDatePicker for iOS**: Would require platform detection and dual codepaths. Rejected — Material pickers are sufficient for v1 and already adapt to platform conventions via Material 3.
- **Custom inline picker widget**: More control over styling. Rejected — significant implementation effort for marginal UX gain. Standard pickers meet the "30 seconds" goal and are immediately familiar to users.
- **showDateTimePicker (combined)**: Flutter doesn't have a built-in combined date+time picker. Third-party packages exist but add dependencies. Rejected — the two-step (date then time) flow is standard and works well for bedtime/wake time where the date part changes (cross-midnight).

**Implementation detail**: For new entries, bedtime defaults to yesterday 22:00 and wake time defaults to today 07:00 (Assumption A-002). The picker pre-selects these defaults so the user only adjusts what differs from the common case.

## R3: Quality Selector Widget Pattern

**Decision**: Custom `QualitySelector` widget — a horizontal row of 5 tappable circles/chips numbered 1–5. Selected value highlighted with primary colour (brand orange). Minimum 44x44px touch targets.

**Rationale**: A row of tappable values is the fastest interaction pattern for a small discrete range (1–5). It's visible at a glance (no dropdown to open), supports single-tap selection, and naturally maps to a "rating" mental model. The widget is extracted to `lib/widgets/quality_selector.dart` for reusability (History/Home may display quality inline later).

**Alternatives considered**:
- **Slider (continuous or discrete)**: Provides 1–5 with steps. Rejected — sliders are harder to hit precise values on mobile, especially at small ranges. Imprecise interaction conflicts with the "frictionless" principle.
- **DropdownButton**: Standard Flutter form widget. Rejected — requires two taps (open + select), adds unnecessary friction, and is visually heavier than a simple row.
- **Star rating widget**: Common for review-style ratings. Rejected — "stars" imply a review/opinion metaphor that doesn't perfectly fit sleep quality (which is more objective). Numbered 1–5 is more precise and matches the PRD's language.

## R4: Save Flow and Error Handling

**Decision**: On save, call the existing `AppDatabase.createEntry()` or `updateEntry()` method via `appDatabaseProvider`. Catch typed exceptions (`InvalidTimeRangeException`, `InvalidQualityException`, `EntryNotFoundException`) and map them to inline error messages. On success, call `context.pop()` to return to the previous screen.

**Rationale**: The D1 layer already implements full validation and throws typed exceptions. The UI layer performs its own pre-validation (enabling/disabling the Save button, showing inline messages), then delegates to the DB layer as the single source of truth. This double-validation ensures both UX responsiveness and data integrity.

**Error mapping**:
- `InvalidTimeRangeException` → "Wake time must be after bedtime (within 24 hours)." (spec FR-006)
- `InvalidQualityException` → "Please select a quality rating." (should never reach DB layer if UI validates)
- `EntryNotFoundException` → "This entry was deleted. Returning to previous screen." (edge case: concurrent deletion)
- Generic exception → "Something went wrong. Please try again." (defensive fallback)

## R5: Edit Mode Data Loading

**Decision**: When `entryId` is non-null, use a `FutureProvider.family` keyed on `entryId` to load the existing entry from `AppDatabase.getEntryById()`. Show a loading indicator while fetching. If the entry is not found, show an error and pop back.

**Rationale**: `FutureProvider.family` integrates cleanly with Riverpod's `ref.watch` pattern, handles loading/error states automatically, and caches the result for the lifetime of the provider. The family parameter (`entryId`) allows the same provider definition to serve any entry.

**Alternatives considered**:
- **Load in `initState`**: Would require manual `Future` management and `setState`. Rejected — Riverpod's provider handles loading/error/data states more cleanly and integrates with the rest of the provider tree.
- **Pass full `SleepEntry` object via route**: Would avoid the DB fetch but requires serialising the object through the route (go_router passes strings). Rejected — passing an ID and fetching is simpler, more robust (always gets latest data), and follows the existing route pattern (`/log?id=...`).

## R6: Brand-Compliant Form Styling

**Decision**: Add `InputDecorationTheme` to `AppTheme.dark` to style all text fields consistently. Individual form elements use theme tokens directly.

**Input decoration tokens** (from brand kit):
- Fill colour: `#1A1B1F` (surface) — `colorScheme.surface`
- Border colour: `#23283A` (fintech border) — `colorScheme.outline`
- Focus border: `#F7931A` (primary/orange) — `colorScheme.primary`
- Error border: `#EF4444` (error) — `colorScheme.error`
- Border radius: 12px (`rounded-lg`)
- Min height: 44px (via `contentPadding`)
- Text: `bodyMedium` (Nunito 16px)
- Hint text: `#6E748A` (muted) — `colorScheme.onSurface.withValues(alpha: 0.5)` or explicit muted colour
- Error text: `#EF4444` (error) — `colorScheme.error`

**Quality selector tokens**:
- Unselected: `surface` background, `outline` border, `onSurface` text
- Selected: `primary` background, `onPrimary` text (black on orange)
- Touch target: 44x44px minimum
- Shape: `CircleBorder` or `RoundedRectangleBorder(12px)`

This ensures brand compliance without scattering magic colour values across widgets.
