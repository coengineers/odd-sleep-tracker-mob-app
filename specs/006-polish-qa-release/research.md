# Research: D5 — Polish, QA & Release Readiness

## R1: Flutter Integration Testing Strategy

**Decision**: Use the `integration_test` package with `IntegrationTestWidgetsFlutterBinding` for end-to-end journey tests.

**Rationale**: The project currently has 12 unit/widget test files using `flutter_test` with in-memory databases. These test individual components in isolation. D5 requires end-to-end tests that exercise the full app (real navigation, real widget interactions across screens). Flutter's `integration_test` package runs on real devices/emulators and supports the full widget interaction API (`tester.tap`, `tester.fling`, `tester.enterText`) while using a real app instance.

**Alternatives considered**:
- `flutter_driver` — legacy approach, less powerful interaction API, being deprecated in favour of `integration_test`
- Widget tests with full app — technically possible but doesn't exercise platform-level behaviour (e.g., actual database persistence) and doesn't run on real devices
- Patrol (third-party) — more powerful but adds a dependency; overkill for 2–3 journey tests

**Key implementation notes**:
- Add `integration_test` as a dev dependency (Flutter SDK package, no external network dependency)
- Tests live in `integration_test/` directory at project root
- Each test uses `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`
- Database must use real SQLite (not in-memory) for true E2E, but can use a test-specific database name to avoid polluting user data
- Run with `flutter test integration_test/`

## R2: Seed Data Tool — Dev-Only Access Pattern

**Decision**: Use Dart's `kDebugMode` constant combined with a long-press gesture on the app title in the Home screen AppBar to toggle a dev menu. The seed function itself lives in a separate `lib/dev/` directory.

**Rationale**: `kDebugMode` is a compile-time constant that the Dart compiler tree-shakes in release builds. Code guarded by `if (kDebugMode)` is completely removed from release binaries — no runtime overhead and no accidental production exposure. A long-press gesture is discoverable for developers but invisible to users.

**Alternatives considered**:
- Separate entry point (`main_dev.dart`) — more isolated but requires maintaining two launch configurations and complicates CI
- Environment variable / `--dart-define` flag — requires build-time configuration, easy to misconfigure
- Hidden drawer or settings screen — requires navigation changes and additional routing
- Conditional import (`import 'package:sleeplog/dev/seed.dart' if (dart.library.io) 'package:sleeplog/dev/seed_stub.dart'`) — overengineered for a simple seed function

**Implementation notes**:
- `lib/dev/seed_data.dart` — pure function `seedSampleEntries(AppDatabase db, {int days = 90})` that generates realistic entries
- Uses `dart:math` Random for varied durations (300–600 minutes) and quality ratings (1–5)
- Generates one entry per day going back N days from today
- Wraps in `kDebugMode` check at the call site
- Optional notes on ~30% of entries for realism

## R3: Accessibility Audit — Current Gaps and Fix Strategy

**Decision**: Add `Semantics` wrappers to all interactive controls across all screens, add accessibility descriptions to all three chart widgets, and add a `tooltip` to the FAB.

**Rationale**: The accessibility audit reveals:
- **Log Entry screen** and **Quality Selector** have good semantics (dynamic labels, `liveRegion: true` for errors)
- **Home screen**, **History screen**, **Insights screen**, **Shell Scaffold** have zero `Semantics` wrappers
- All three chart widgets (`MiniDurationChart`, `DurationBarChart`, `QualityLineChart`) are completely inaccessible to screen readers
- `PatternSummaryCard` has accessible text content but no structural semantics

**Fix strategy (per component)**:
1. **Shell Scaffold**: Add `tooltip: 'Log sleep'` to FloatingActionButton
2. **Home screen**: Add Semantics to loading/error states; chart gets Semantics wrapper via widget fix
3. **History screen**: Add Semantics to each `_EntryTile` with descriptive label (date, duration, quality); add label to loading/error states
4. **Insights screen**: Add Semantics labels to chart card containers; loading/error labels
5. **Chart widgets**: Wrap each in `Semantics(label: '...')` with a dynamic summary of the data being visualised (e.g., "Last 7 days sleep duration. Average: 7 hours 30 minutes.")
6. **Pattern summary card**: Add structural Semantics label to card container

**Text scaling note**: Flutter's `TextTheme` sizes defined in the theme ARE respected by the system text scaler by default (`MediaQuery.textScaleFactor`). The theme sets base sizes but Flutter automatically scales them. The quality selector's hardcoded `fontSize: 16` should be replaced with a theme reference. No additional text scaling work is needed beyond this one fix.

## R4: Release Checklist — Content and Format

**Decision**: Create `docs/release-checklist.md` with structured QA verification steps, known limitations, and build instructions.

**Rationale**: The PRD explicitly requires a release checklist (D5 artifacts). A markdown file in `docs/` is version-controlled, easily reviewable, and accessible to all team members.

**Content outline**:
1. **Pre-release QA steps** — manual verification checklist for each key journey
2. **Automated test gates** — commands to run unit, widget, and integration tests
3. **Known limitations** — DST behaviour, multiple entries per day, no cloud sync
4. **Build instructions** — iOS and Android release build commands
5. **Accessibility verification** — manual TalkBack/VoiceOver walkthrough steps
6. **Privacy verification** — code audit checklist for zero network calls

## R5: Integration Test Database Strategy

**Decision**: Use `AppDatabase.forTesting(NativeDatabase.memory())` within integration tests, overriding the `appDatabaseProvider` via `ProviderScope`.

**Rationale**: Integration tests need a clean database per test run. Using in-memory SQLite avoids file system cleanup and ensures test isolation. The existing provider override pattern (`appDatabaseProvider.overrideWithValue(db)`) works identically in integration tests as it does in widget tests.

**Alternatives considered**:
- File-based test database — requires cleanup, risk of stale data between runs
- Production database with pre-seed — could corrupt user data if run on a device with existing data
- Mock database — defeats the purpose of integration testing

**Implementation notes**:
- Create a custom `integrationTestApp()` function that returns a `ProviderScope`-wrapped `SleepLogApp` with an overridden database provider
- Each integration test file creates a fresh in-memory database in its setup
