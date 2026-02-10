# Research: Home + History Screens

**Feature**: 004-home-history-screens
**Date**: 2026-02-10

## R1: Mini Chart Library for Home Screen

**Decision**: Use `fl_chart` for the 7-day duration bar chart on the Home screen.

**Rationale**:
- `fl_chart` is already listed in the PRD tech stack (Section 10, D4) and the constitution's Technical Constraints.
- It is a pure-Dart rendering library with zero network activity — fully compatible with Principle I (Offline-First).
- It supports `BarChart` out of the box with customisable bar colours, labels, and tooltips.
- The mini chart on Home only needs a simple, non-interactive 7-bar display — `fl_chart` handles this without over-engineering.

**Alternatives considered**:
- **Custom `CustomPainter`**: Lower dependency but more code to write and maintain for bar layout, spacing, and labels. Rejected because `fl_chart` is already an approved dependency.
- **`syncfusion_flutter_charts`**: Feature-rich but heavier, and the free-tier licence has usage restrictions. Rejected for simplicity and licensing clarity.

## R2: Swipe-to-Delete Pattern for History

**Decision**: Use Flutter's built-in `Dismissible` widget with a confirmation dialog and `SnackBar` undo.

**Rationale**:
- `Dismissible` is a first-party Flutter widget — no additional dependency needed.
- It provides the swipe gesture with configurable direction, background, and dismiss threshold.
- The flow: swipe → `confirmDismiss` callback shows an `AlertDialog` → on confirm, delete from DB → show `SnackBar` with "Undo" action for 5 seconds → on undo, re-insert the entry from in-memory copy.

**Alternatives considered**:
- **`flutter_slidable`**: Provides more sophisticated swipe actions (multiple buttons, configurable panels). Rejected because the PRD only requires a single delete action — `Dismissible` is sufficient and avoids adding a dependency.
- **Long-press context menu**: Less discoverable than swipe. Rejected because the PRD explicitly specifies "swipe to delete" (FR-007).

**Implementation notes**:
- `confirmDismiss` returns `Future<bool>` — show `AlertDialog` and return user's choice.
- On dismiss, store the deleted `SleepEntry` in a local variable before calling `db.deleteEntry(id)`.
- Show `SnackBar` with 5-second duration and "Undo" action. On undo, call `db.createEntry()` with the stored entry's data to re-insert.
- If a new deletion occurs while a previous undo SnackBar is showing, the previous SnackBar is dismissed (standard `ScaffoldMessenger` behaviour) and the previous deletion becomes permanent.

## R3: State Management for Home and History Data

**Decision**: Use Riverpod `FutureProvider` for Home data and `StreamProvider` (or `FutureProvider` with refresh) for History data.

**Rationale**:
- The existing codebase uses `FutureProvider.family` for single-entry fetch (`sleepEntryProvider`). This pattern extends naturally.
- Home needs two queries: (1) today's summary entry and (2) last 7 days' durations for the chart. Both are read-once-on-load with refresh-on-return.
- History needs all entries listed. A `FutureProvider` with `ref.invalidate()` on return from edit/delete handles data freshness without the complexity of a reactive stream.

**Alternatives considered**:
- **Drift `watch()` streams + Riverpod `StreamProvider`**: Provides real-time reactivity when the DB changes. More elegant but adds complexity. Rejected for now — the screens are not multi-window and only need to refresh on explicit user actions (navigate back, delete). If future features need live updates, this can be migrated.
- **`StateNotifierProvider` with manual state management**: More control but more boilerplate. Rejected because the data flow is simple (fetch → display → re-fetch on action).

**Implementation notes**:
- `todaySummaryProvider`: `FutureProvider<SleepEntry?>` — calls `db.listEntries(fromDate: today, toDate: today, limit: 1)` and returns the first result (already ordered by `wakeTs` descending).
- `recentDurationsProvider`: `FutureProvider<List<({String date, int minutes})>>` — calls `db.listEntries(fromDate: sevenDaysAgo, toDate: today)` and maps to date/duration pairs for the chart. Fills missing days with 0.
- `allEntriesProvider`: `FutureProvider<List<SleepEntry>>` — calls `db.listEntries()` with no filters for the History list.
- All providers are invalidated when the user returns from the Log Entry screen or performs a delete, using `ref.invalidate()`.

## R4: Today Determination and Refresh

**Decision**: Use `DateTime.now()` to determine "today" at the time the provider executes. Wrap in a testable abstraction if needed.

**Rationale**:
- The PRD and spec define "today" as the device's current local date when the screen loads.
- For testing, providers can be overridden with a fixed database state — no need to mock `DateTime.now()` in widget tests.
- Unit tests for the provider logic can use a `Clock` abstraction if needed, but the simpler approach is to seed test data with known dates and verify the query logic.

**Alternatives considered**:
- **Inject a `Clock` dependency via Riverpod**: More testable but adds indirection for a simple `DateTime.now()` call. Deferred unless testing proves difficult.

## R5: Data Refresh Strategy

**Decision**: Invalidate providers on navigation return using `GoRouter`'s `onExit` or by checking state after `await context.push('/log')`.

**Rationale**:
- `context.push('/log')` returns a `Future` that completes when the pushed route is popped. After the future completes, `ref.invalidate()` on the relevant providers triggers a re-fetch.
- This pattern is already implicit in the codebase — the Home and History screens will re-build when their providers are invalidated.

**Implementation notes**:
- Home: The FAB (in `ShellScaffold`) already navigates with `context.push('/log')`. After the push completes, invalidate `todaySummaryProvider` and `recentDurationsProvider`.
- History: After `context.push('/log?id=$entryId')` for edit, invalidate `allEntriesProvider`. After delete + undo timeout, invalidate `allEntriesProvider`.
- The `ShellScaffold` FAB push needs a minor update to trigger invalidation on return. This can be done by wrapping the push in the screen's own callback or by using a `ref.listen` pattern.

## R6: fl_chart Audit for Network Activity

**Decision**: `fl_chart` is safe to use — confirmed no network activity.

**Rationale**:
- `fl_chart` (`pub.dev/packages/fl_chart`) is a pure-Dart charting library.
- Its `pubspec.yaml` declares only `flutter` and `equatable` as dependencies — no `http`, `dio`, or any networking package.
- No analytics, telemetry, or tracking code in the source.
- Compatible with Principle I (Offline-First) and Principle II (On-Device Privacy).
