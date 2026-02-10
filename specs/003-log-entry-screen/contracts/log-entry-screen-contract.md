# Screen Contract: Log Entry Screen

**Feature**: `003-log-entry-screen`
**Date**: 2026-02-10

## Screen Identity

- **Widget**: `LogEntryScreen` (ConsumerStatefulWidget)
- **Route**: `/log` (create mode) or `/log?id={entryId}` (edit mode)
- **File**: `lib/screens/log_entry_screen.dart`

## Inputs (Route Parameters)

| Parameter | Type | Required | Source | Notes |
|-----------|------|----------|--------|-------|
| entryId | String? | no | `state.uri.queryParameters['id']` | null = create mode, non-null = edit mode |

## Provider Dependencies

| Provider | Type | Purpose |
|----------|------|---------|
| `appDatabaseProvider` | `Provider<AppDatabase>` | Access to `createEntry()`, `updateEntry()`, `getEntryById()` |
| `sleepEntryProvider(id)` | `FutureProvider.family<SleepEntry?, String>` | Fetch existing entry for edit mode |

## UI Contract

### Layout (top to bottom)

1. **AppBar**
   - Title: "Log Entry" (create) or "Edit Entry" (edit)
   - Back button: `context.pop()`

2. **Bedtime Picker Row**
   - Label: "Bedtime" (`labelLarge`)
   - Display: formatted date + time (e.g., "Mon 9 Feb, 22:00") (`bodyMedium`)
   - Tap action: `showDatePicker` → `showTimePicker` → update state
   - Error: `durationError` shown below (shared with wake time)

3. **Wake Time Picker Row**
   - Label: "Wake time" (`labelLarge`)
   - Display: formatted date + time (e.g., "Tue 10 Feb, 07:00") (`bodyMedium`)
   - Tap action: `showDatePicker` → `showTimePicker` → update state
   - Computed display: "8h 0m" duration shown when both times set

4. **Duration Error** (conditional)
   - Text: "Wake time must be after bedtime (within 24 hours)."
   - Style: `bodySmall` with `colorScheme.error`
   - Shown when: duration ≤ 0 or > 1440 minutes after save attempt

5. **Quality Selector**
   - Label: "Quality" (`labelLarge`)
   - Widget: `QualitySelector(value: quality, onChanged: (v) => ...)`
   - Displays: 5 tappable items (1–5), selected = primary fill
   - Error: "Please select a quality rating." below when null on save

6. **Note Field**
   - Label: "Note (optional)" (`labelLarge`)
   - Widget: `TextField` with `maxLength: 280`, `maxLines: 3`
   - Decoration: brand-compliant input decoration (from InputDecorationTheme)
   - Counter: shows character count

7. **Save Button**
   - Text: "Save" (create) or "Update" (edit)
   - Style: `ElevatedButton` (full width, brand primary, 44px min height)
   - Disabled when: `isSaving == true`
   - Shows: `CircularProgressIndicator` when saving

8. **General Error Banner** (conditional)
   - Text: error message from save failure
   - Style: `bodySmall` with `colorScheme.error`
   - Dismissed on next save attempt

### Scrollability

The form body is wrapped in `SingleChildScrollView` with `padding: EdgeInsets.all(24)` to handle smaller screens and keyboard appearance.

## User Actions → System Responses

| User Action | System Response |
|-------------|----------------|
| Tap bedtime row | Open date picker (initial: current bedtime date) → open time picker (initial: current bedtime time) → update bedtime state, clear duration error |
| Tap wake time row | Open date picker (initial: current wake date) → open time picker (initial: current wake time) → update wake state, clear duration error |
| Tap quality chip (1–5) | Update quality state, clear quality error |
| Type in note field | Update note state (maxLength enforced at 280) |
| Tap Save/Update | Validate → if valid: set isSaving=true, call DB, pop on success, show error on failure → if invalid: show inline errors |
| Tap back / system back | Pop screen (discard unsaved changes, no confirmation) |

## Validation Contract

| Field | Rule | Error Message | Trigger |
|-------|------|---------------|---------|
| bedtime + wake time | duration between 1–1440 min | "Wake time must be after bedtime (within 24 hours)." | On save tap |
| quality | must be 1–5 (not null) | "Please select a quality rating." | On save tap |
| note | ≤ 280 characters | (prevented by maxLength) | Real-time |

## Save Contract

### Create Mode

```
Input: CreateSleepEntryInput(bedtimeTs, wakeTs, quality, note)
Call:  appDatabase.createEntry(input)
Success: context.pop()
Error:
  - InvalidTimeRangeException → show duration error
  - InvalidQualityException → show quality error (defensive)
  - Other → show generic error banner
```

### Edit Mode

```
Input: UpdateSleepEntryInput(bedtimeTs, wakeTs, quality, note, hasNote: true)
Call:  appDatabase.updateEntry(entryId, input)
Success: context.pop()
Error:
  - EntryNotFoundException → show "Entry was deleted" error, pop after delay
  - InvalidTimeRangeException → show duration error
  - Other → show generic error banner
```

## Accessibility Contract

| Element | Semantic Label | Notes |
|---------|---------------|-------|
| Bedtime row | "Bedtime, [formatted date time]. Tap to change." | Tappable, reads current value |
| Wake time row | "Wake time, [formatted date time]. Tap to change." | Tappable, reads current value |
| Quality chip N | "Quality N of 5" + selected/unselected state | Each chip is individually focusable |
| Note field | "Note, optional, [N] of 280 characters" | Standard TextField semantics |
| Save button | "Save" or "Update" | Disabled state announced |
| Duration error | Error text announced when visible | Uses `Semantics(liveRegion: true)` |
