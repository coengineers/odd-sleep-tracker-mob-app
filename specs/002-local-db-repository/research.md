# Research: Local Database & Repository Layer

**Feature**: 002-local-db-repository
**Date**: 2026-02-09

## R1: Drift Package Version & Compatibility

**Decision**: Use drift ^2.31.0 with drift_flutter ^0.2.0

**Rationale**: drift 2.31+ is the current stable release, fully compatible with Dart 3.10+ and Flutter 3.38+. The `drift_flutter` companion package provides platform-specific database openers (replaces the older `moor_flutter`). It wraps `sqlite3_flutter_libs` for native SQLite access on iOS/Android.

**Alternatives considered**:
- `sqflite` — lower-level, no type-safe queries, no code generation, manual SQL strings. More boilerplate, more error-prone.
- `floor` — similar ORM approach but less actively maintained than drift. Drift has larger ecosystem and better documentation.
- `isar` — NoSQL approach, different paradigm. PRD specifies SQLite, and drift aligns with that.

## R2: DateTime Storage Strategy

**Decision**: Store DateTimes as ISO 8601 text strings (`store_date_time_values_as_text: true` in build.yaml)

**Rationale**: The PRD schema explicitly specifies `TEXT` columns for `bedtime_ts`, `wake_ts`, `created_at`, and `updated_at` with ISO datetime format. Drift's text mode stores DateTimes as ISO 8601 strings, which:
- Matches the PRD data contract exactly
- Is human-readable in database inspection tools
- Preserves local timezone information (no UTC conversion issues)
- Sorts correctly as text (ISO 8601 is lexicographically ordered)

**Alternatives considered**:
- Unix epoch integers (drift default) — more compact but loses timezone info and doesn't match PRD schema specification
- Custom text converter — unnecessary since drift's built-in text mode already produces ISO 8601

## R3: In-Memory Testing Strategy

**Decision**: Use `NativeDatabase.memory()` with `closeStreamsSynchronously: true`

**Rationale**: `NativeDatabase.memory()` creates a fresh in-memory SQLite database per test. The `closeStreamsSynchronously: true` flag prevents hanging stream timers in widget tests. Each test gets a clean database via setUp/tearDown, ensuring full isolation.

**Alternatives considered**:
- `VmDatabase.memory()` — deprecated alias, redirects to NativeDatabase
- File-based test database — adds filesystem dependency, slower, requires cleanup
- Mocking the database layer — loses the value of testing actual SQL execution

**Dev dependency required**: The `sqlite3_flutter_libs` package provides native SQLite for tests, but `NativeDatabase` from `drift/native.dart` can use the system SQLite on macOS/Linux for `flutter test`. No additional test-only dependencies needed beyond `drift/native.dart`.

## R4: UUID Generation

**Decision**: Use `uuid` ^4.0.0 with v4 (random) UUIDs

**Rationale**: PRD specifies `id TEXT PRIMARY KEY (uuid)`. UUID v4 is the standard choice for random unique identifiers. The `uuid` package is pure Dart with no platform dependencies or network calls (satisfies Constitution Principle I). UUIDs are generated client-side via `clientDefault` in the drift table definition.

**Alternatives considered**:
- UUID v7 (time-ordered) — better for B-tree index performance in high-write scenarios, but SleepLog writes ~1-2 entries/day. No measurable benefit.
- UUID v1 (MAC-based) — includes device MAC address, privacy concern. Rejected.
- Auto-increment integer — simpler but doesn't support future sync/merge scenarios if the app ever goes multi-device.

## R5: Repository Architecture

**Decision**: Implement repository methods directly on the drift `AppDatabase` class (no separate repository interface/implementation)

**Rationale**: Drift's database class already provides type-safe, compile-time verified queries. Adding a separate `SleepEntryRepository` interface + `SleepEntryRepositoryImpl` class creates an abstraction layer with no practical benefit:
- There is only one storage backend (local SQLite) — no need for swappable implementations
- Drift's generated code IS the type-safe repository
- Tests use in-memory SQLite directly — no mocking needed
- Adding an interface doubles the number of files and methods to maintain

The database class exposes domain-level methods (`createEntry`, `listEntries`, `updateEntry`, `deleteEntry`) that encapsulate validation + computed fields. This is effectively the repository pattern without the ceremony.

**Alternatives considered**:
- Interface + Implementation pattern — appropriate for apps with multiple backends (local + remote) or where the database layer needs to be mocked. Neither applies here.
- DAO (Data Access Object) mixin — drift supports `@DriftAccessor` mixins for splitting large databases. Overkill for a single table.

## R6: Validation Strategy

**Decision**: Validate in a pure Dart helper function, called before drift insert/update. Database CHECK constraints as safety net.

**Rationale**:
- **Application-level validation** in a pure function enables: clear error types (`invalid_time_range`, `invalid_quality`, `note_too_long`), testability without a database, and reuse from UI form validators in later deliverables.
- **Database-level CHECK constraints** on `quality` (1-5) and `duration_minutes` (1-1440) provide a safety net if validation is somehow bypassed.
- This two-layer approach follows defense-in-depth without over-engineering.

**Alternatives considered**:
- Database-only validation — CHECK constraint violations produce opaque SQLite errors, not user-friendly error types
- Validation in a separate service class — adds a layer with no benefit; the repository is the right boundary for data integrity

## R7: Riverpod Provider Strategy

**Decision**: Single `appDatabaseProvider` (Provider) for the database instance. No separate repository provider since the database IS the repository.

**Rationale**: The `AppDatabase` instance is created once and shared via a Riverpod `Provider`. It self-manages its lifecycle. UI screens will consume it via `ref.read(appDatabaseProvider)` for mutations and can create `StreamProvider` wrappers for reactive queries in later deliverables (D2-D3).

**Alternatives considered**:
- `FutureProvider` for async database initialization — adds complexity; drift handles lazy initialization internally
- Separate provider per repository method — too granular, creates provider explosion
- `StateNotifierProvider` — appropriate for UI state management (D2-D3), not for the data layer

## R8: Migration Strategy

**Decision**: Use drift's built-in `MigrationStrategy` with `schemaVersion: 1`. Prepare for future migrations by using the `onUpgrade` callback pattern.

**Rationale**: D1 is the initial schema. No migration from a previous version is needed. The `onCreate` callback creates all tables. The `onUpgrade` callback is left as a placeholder for D2+ changes. Drift's `schema dump` tool can be used pre-release to generate migration helpers.

**Alternatives considered**:
- Step-by-step migration with `drift_dev schema dump` — appropriate when multiple schema versions exist. Premature for v1.
- Manual SQL migrations — loses drift's type safety. Only needed for very complex migrations.
