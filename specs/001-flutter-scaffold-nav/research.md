# Research: Flutter Scaffold & Navigation (D0)

**Branch**: `001-flutter-scaffold-nav` | **Date**: 2026-02-09 | **Spec**: `specs/001-flutter-scaffold-nav/spec.md`

---

## 1. go_router Route Structure

### Decision

Use a **flat GoRoute tree** (no ShellRoute) with Home as the root route at `/`. Child screens are defined as nested sub-routes under Home. LogEntry uses a **query parameter** (`?id=<uuid>`) for the optional edit ID rather than a path parameter. Navigation between screens uses `context.push()` exclusively (never `context.go()`) to preserve the back stack.

Route table:

| Route Path       | Screen   | Notes                                        |
|------------------|----------|----------------------------------------------|
| `/`              | Home     | Initial location, root of the tree           |
| `/log`           | LogEntry | New entry mode (no `id` query param)         |
| `/log?id=<uuid>` | LogEntry | Edit mode (future D2, `id` query param)      |
| `/history`       | History  | Push from Home                               |
| `/insights`      | Insights | Push from Home                               |

Nested route structure in code:

```dart
GoRouter createRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'log',
          builder: (context, state) {
            final id = state.uri.queryParameters['id'];
            return LogEntryScreen(entryId: id);
          },
        ),
        GoRoute(
          path: 'history',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: 'insights',
          builder: (context, state) => const InsightsScreen(),
        ),
      ],
    ),
  ],
);
```

History navigates to LogEntry for editing via `context.push('/log?id=$entryId')`. This reuses the same route (FR-D0-004).

### Rationale

1. **No ShellRoute needed.** ShellRoute exists to provide persistent UI (e.g., a bottom navigation bar that stays visible across tabs). The SleepLog app uses a Home-centric hub pattern where Home provides links/buttons to child screens, not a persistent bottom tab bar. ShellRoute would add structural complexity with zero benefit.

2. **Nested sub-routes under `/`.** Nesting `/log`, `/history`, and `/insights` under the root route means go_router understands the parent-child relationship. When a user navigates to `/log`, go_router knows `/` is the parent, which enables proper back navigation even if the app is deep-linked directly to `/log`.

3. **Query parameter for optional `id`.** go_router path parameters (`:id`) are required -- the route only matches if the segment is present. Using a query parameter (`?id=<uuid>`) makes the parameter truly optional: `/log` = new entry, `/log?id=abc` = edit entry. This avoids needing two separate routes or an awkward optional path segment syntax. Query parameters are also recommended over `extra` because they survive deep linking and browser back navigation (relevant if the app ever moves to web).

4. **`context.push()` not `context.go()`.** The spec requires push-style navigation with back button support (FR-D0-010). `context.go()` replaces the navigation stack, destroying the ability to go back. `context.push()` adds to the stack, preserving back navigation.

5. **Factory function `createRouter()`.** Returns a new GoRouter instance each call. Required for test isolation (see Topic 5). A global singleton GoRouter leaks state between tests.

### Alternatives Considered

| Alternative | Why Rejected |
|-------------|-------------|
| **ShellRoute with bottom nav bar** | PRD and spec explicitly state Home-centric hub navigation, not persistent bottom tabs. ShellRoute adds complexity for a pattern not used in v1. |
| **Path parameter `/log/:id`** | Path parameters are required in go_router. Would need a separate `/log` route for "new" mode and `/log/:id` for "edit" mode, duplicating route definitions. Query parameter is cleaner for optional data. |
| **`extra` parameter for passing ID** | `extra` does not survive deep linking, browser back button, or app process death/restore. Query parameters are the recommended approach for data that identifies a resource. |
| **Separate routes for new vs edit** | `/log/new` and `/log/edit/:id` would work but violates the spec requirement to reuse the same route for both create and edit (FR-D0-004). |

---

## 2. Flutter Project Creation

### Decision

```bash
flutter create \
  --org com.coengineers \
  --platforms ios,android \
  --project-name sleeplog \
  sleep_log
```

Then immediately update the generated `pubspec.yaml` with the correct dependencies and remove the default `widget_test.dart` (which will fail after rewriting `main.dart`).

### Rationale

1. **`--org com.coengineers`** sets the reverse-domain identifier used in the Android `applicationId` (`com.coengineers.sleeplog`) and iOS `bundleIdentifier` (`com.coengineers.sleeplog`). Setting this at creation time avoids manual editing of `build.gradle` and `Info.plist` later.

2. **`--platforms ios,android`** restricts generated platform folders to iOS and Android only. Without this flag, Flutter creates platform folders for all six targets (ios, android, web, windows, linux, macos), which adds clutter and unnecessary CI surface for a mobile-only app.

3. **`--project-name sleeplog`** sets the Dart package name. This appears in `import` statements, the `pubspec.yaml` `name` field, and generated platform identifiers. Using `sleeplog` (lowercase, no hyphens) follows Dart package naming conventions.

4. **Directory name `sleep_log`** (with underscore) is the folder name on disk. The `--project-name` flag overrides the Dart package name independently of the directory name, but keeping them consistent (`sleeplog` for package, `sleep_log` for directory) is a common Flutter convention.

5. **Default template (`app`).** No `--template` flag needed -- the default `app` template generates a full Flutter application with `lib/main.dart`, platform folders, and `pubspec.yaml`.

### Alternatives Considered

| Alternative | Why Rejected |
|-------------|-------------|
| **Include `--platforms web`** | App targets iOS and Android only per PRD. Web adds ~3 platform files and configuration that would need maintenance without benefit. Can be added later with `flutter create --platforms web .` if needed. |
| **Omit `--org`** | Defaults to `com.example`, which would need manual correction in build files. Setting it upfront is cleaner. |
| **Use `--template skeleton`** | The skeleton template generates a more opinionated project structure (with localization, settings, etc.) that conflicts with the project's chosen architecture. The basic `app` template gives a clean starting point. |
| **Use `very_good_cli` or `mason`** | Adds external tool dependencies for project generation. The standard `flutter create` is sufficient for D0 and avoids toolchain complexity. |

---

## 3. ThemeData Construction from Brand Tokens

### Decision

Construct `ThemeData` with a manually built `ColorScheme` (not `ColorScheme.fromSeed`) and a custom `TextTheme` using bundled Satoshi and Nunito fonts. Create a single static class `AppTheme` in `lib/theme/app_theme.dart` that exposes `AppTheme.dark` as a `ThemeData` instance. Only dark mode is implemented in D0 (per spec assumptions).

Key construction pattern:

```dart
class AppTheme {
  AppTheme._();

  // Brand colour tokens
  static const _bgApp = Color(0xFF0E0F12);
  static const _bgSurface = Color(0xFF151821);
  static const _primary = Color(0xFFF7931A);
  static const _onPrimary = Color(0xFF000000);
  static const _textPrimary = Color(0xFFE6E8EE);
  static const _textSecondary = Color(0xFFA2A8BD);
  static const _textMuted = Color(0xFF6E748A);
  static const _border = Color(0xFF23283A);
  static const _error = Color(0xFFEF4444);
  static const _success = Color(0xFF22C55E);

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: _primary,
      onPrimary: _onPrimary,
      secondary: Color(0xFF262626),
      onSecondary: Color(0xFFFAFAFA),
      error: _error,
      onError: Color(0xFFFAFAFA),
      surface: _bgSurface,
      onSurface: _textPrimary,
      outline: _border,
      outlineVariant: Color(0xFF1C2030),
    ),
    scaffoldBackgroundColor: _bgApp,
    textTheme: _textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: _bgApp,
      foregroundColor: _textPrimary,
      elevation: 0,
      titleTextStyle: const TextStyle(
        fontFamily: 'Satoshi',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 20, // -0.02em
        color: _textPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: _onPrimary,
        minimumSize: const Size(0, 44), // 44px min touch target
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // radius-lg
        ),
      ),
    ),
    // ... additional component themes
  );

  static const _textTheme = TextTheme(
    // Headings — Satoshi
    headlineLarge: TextStyle(
      fontFamily: 'Satoshi',
      fontSize: 36,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.02 * 36,
      color: _textPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Satoshi',
      fontSize: 30,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.02 * 30,
      color: _textPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Satoshi',
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.02 * 24,
      color: _textPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Satoshi',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.02 * 20,
      color: _textPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Satoshi',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.02 * 18,
      color: _textPrimary,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Satoshi',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.02 * 16,
      color: _textPrimary,
    ),
    // Body — Nunito
    bodyLarge: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: _textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: _textPrimary,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: _textSecondary,
    ),
    // Labels — Nunito
    labelLarge: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: _textPrimary,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: _textSecondary,
    ),
    labelSmall: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: _textMuted,
    ),
  );
}
```

### Rationale

1. **Manual `ColorScheme` construction (not `fromSeed`).** `ColorScheme.fromSeed()` generates a harmonious palette from a single seed colour using Material 3's tonal palette algorithm. This would override the brand kit's specific hex values with algorithmically-generated alternatives. The brand kit defines exact colours for every role (background, surface, primary, text tiers, borders, semantic colours), and these must be used verbatim. Manual construction is the only way to map each brand token to its exact `ColorScheme` slot.

2. **`scaffoldBackgroundColor` set explicitly to `#0E0F12`.** The brand kit distinguishes between "app background" (`#0E0F12`) and "surface" (`#151821`). In Material's `ColorScheme`, `surface` maps to card/sheet backgrounds, but `Scaffold` uses `scaffoldBackgroundColor` by default (falling back to `colorScheme.surface` in M3). Setting it explicitly ensures the scaffold background is the darker app background, while cards and elevated surfaces use the lighter `surface` colour.

3. **`TextTheme` maps headings to Satoshi, body/labels to Nunito.** Material's `TextTheme` has three tiers: display/headline (large typographic styles), title (smaller headings), and body/label (content text). Mapping Satoshi to headline+title roles and Nunito to body+label roles matches the brand kit's rule: "Satoshi headings, Nunito body".

4. **Letter spacing computed as `-0.02 * fontSize`.** The brand kit specifies `-0.02em` for headings. Flutter's `letterSpacing` is in logical pixels, not em units. Multiplying by the font size converts em to pixels.

5. **Component themes (AppBarTheme, ElevatedButtonTheme, etc.) set explicitly.** Material 3 components derive their styles from `ColorScheme` and `TextTheme`, but some defaults (button shapes, minimum sizes, AppBar elevation) need overriding to match brand kit specifications. Setting these in `ThemeData` ensures all instances of a component automatically pick up the brand styling without per-widget overrides.

6. **`useMaterial3: true`.** Flutter 3.22+ defaults to Material 3 in most cases. Setting it explicitly documents the intent and ensures consistent behaviour across Flutter versions.

### Alternatives Considered

| Alternative | Why Rejected |
|-------------|-------------|
| **`ColorScheme.fromSeed(seedColor: Color(0xFFF7931A))`** | Generates algorithmically-derived tonal palettes. The resulting surface, background, and container colours would not match the brand kit's specific hex values. Brand compliance is a constitutional principle. |
| **`ColorScheme.dark()` then `copyWith`** | `ColorScheme.dark()` starts with Material's default dark palette, then `copyWith` overrides individual slots. This works but means you start from Material's defaults and patch them. Constructing the full `ColorScheme` from scratch is more explicit and avoids inheriting any unwanted Material defaults. |
| **Theme extensions for brand tokens** | `ThemeExtension<T>` allows custom token sets (e.g., `BrandColors.textMuted`). This is valuable for tokens that don't map to `ColorScheme` slots (like `textSecondary` vs `textMuted`). Recommended to add in D0 alongside the base `ColorScheme` for tokens that have no Material equivalent. |
| **Separate `TextStyles` class instead of `TextTheme`** | Defining styles outside `TextTheme` means Material components (AppBar, ListTile, etc.) would not pick them up automatically. Using `TextTheme` ensures components inherit the correct fonts without manual styling on each widget. |

---

## 4. Font Bundling in Flutter

### Decision

Bundle static (non-variable) `.ttf` files for both Satoshi and Nunito in `assets/fonts/`. Include only the weight variants needed by the brand kit. No italic variants for D0 (the brand kit does not specify italic usage for mobile).

**Satoshi weights needed** (for headings, per brand kit Section 4.3):
- Medium (500) -- used for `text-heading-xs`, `text-heading-sm`, `titleSmall`
- SemiBold (600) -- used for `text-heading-base`, `text-heading-lg`, `titleMedium`, `titleLarge`
- Bold (700) -- used for h1-h3, `headlineLarge/Medium/Small`

**Nunito weights needed** (for body, per brand kit Section 4.3):
- Regular (400) -- body text
- SemiBold (600) -- label emphasis, bold body
- Bold (700) -- h4-h6, strong emphasis

**Files to download and bundle:**

```
assets/fonts/
  Satoshi-Medium.ttf
  Satoshi-Bold.ttf
  Satoshi-Black.ttf      # (optional, not used in D0 but closest to 600 if
                          #  600 not available as a separate static file)
  Nunito-Regular.ttf
  Nunito-SemiBold.ttf
  Nunito-Bold.ttf
```

**Note on Satoshi weight 600:** Satoshi from fontshare.com ships static files for Light (300), Regular (400), Medium (500), Bold (700), and Black (900). There is no dedicated SemiBold (600) static file. Two options:
- Use the **variable font** (`Satoshi-Variable.ttf`) which supports any weight from 300-900 including 600.
- Use **Medium (500)** as a close substitute for 600 in the brand kit heading roles.

The recommended approach for D0 is to use the **variable font** for Satoshi, which supports all needed weights in a single file, and static files for Nunito (since Google Fonts provides every weight as a separate static `.ttf`).

**pubspec.yaml font declaration:**

```yaml
flutter:
  uses-material-design: true

  fonts:
    - family: Satoshi
      fonts:
        - asset: assets/fonts/Satoshi-Variable.ttf

    - family: Nunito
      fonts:
        - asset: assets/fonts/Nunito-Regular.ttf
          weight: 400
        - asset: assets/fonts/Nunito-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Nunito-Bold.ttf
          weight: 700
```

If using static Satoshi files instead of the variable font:

```yaml
    - family: Satoshi
      fonts:
        - asset: assets/fonts/Satoshi-Medium.ttf
          weight: 500
        - asset: assets/fonts/Satoshi-Bold.ttf
          weight: 700
```

### Rationale

1. **Bundled as assets (no `google_fonts` package).** The constitution requires zero network requests (Principle I). The `google_fonts` package fetches fonts at runtime on first use. Bundling as assets ensures fonts load instantly with no network dependency.

2. **Variable font for Satoshi.** Satoshi's fontshare distribution lacks a static SemiBold (600) file. The variable font file (`Satoshi-Variable.ttf`) supports the full weight range, allowing Flutter to render weight 500, 600, and 700 accurately from a single asset. The file size trade-off is acceptable (~80KB for a variable font vs ~60KB per static weight).

3. **Static files for Nunito.** Google Fonts provides individual static `.ttf` files for every weight. Static files are simpler (explicit weight mapping in pubspec), and we only need three weights, keeping the total font payload small (~150KB).

4. **No italic variants in D0.** The brand kit does not specify italic usage for mobile headings or body text. Adding italic variants later is trivial (add files + pubspec entries) without breaking existing code.

5. **`assets/fonts/` directory.** Flutter convention is to place fonts under `assets/fonts/` or `fonts/` at the project root. Using `assets/fonts/` keeps all bundled assets organised under a single `assets/` parent.

### Alternatives Considered

| Alternative | Why Rejected |
|-------------|-------------|
| **`google_fonts` package** | Fetches fonts over the network at runtime. Violates constitution Principle I (zero network requests). Also adds latency on first render. |
| **Static files for all Satoshi weights** | Fontshare does not ship a static SemiBold (600) file. Would need to either skip 600 (brand kit requires it) or use the variable font. Variable font is the correct solution. |
| **Variable font for both Satoshi and Nunito** | Nunito's variable font exists but is larger (~200KB) and unnecessary when only three static weights are needed. Static files are more straightforward for Nunito. |
| **Include all Satoshi and Nunito weights (300-900)** | Adds unused font data to the app bundle. D0 screens are shells -- only the weights specified in the brand kit's heading and body roles are needed. Additional weights can be added when actual content screens are built (D2-D4). |

---

## 5. Test Isolation with go_router

### Decision

Use a **factory function** `createRouter()` that returns a new `GoRouter` instance on every call. Each widget test creates its own router instance and wraps the widget under test in `MaterialApp.router` with a `ProviderScope`. No global `GoRouter` singleton exists anywhere in the codebase.

**Router factory pattern:**

```dart
// lib/routing/app_router.dart
GoRouter createRouter() => GoRouter(
  initialLocation: '/',
  routes: [ /* ... route definitions ... */ ],
);
```

**Widget test pattern:**

```dart
// test/screens/home_screen_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleeplog/routing/app_router.dart';
import 'package:sleeplog/theme/app_theme.dart';

void main() {
  testWidgets('Home screen shows empty state', (tester) async {
    final router = createRouter();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.dark,
        ),
      ),
    );

    expect(find.text('No sleep logged yet.'), findsOneWidget);
  });

  testWidgets('Tapping Log sleep navigates to LogEntry', (tester) async {
    final router = createRouter();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.dark,
        ),
      ),
    );

    await tester.tap(find.text('Log sleep'));
    await tester.pumpAndSettle();

    expect(find.byType(LogEntryScreen), findsOneWidget);
  });
}
```

**Testing navigation to a specific route (e.g., History -> LogEntry):**

```dart
testWidgets('History pushes to LogEntry with id', (tester) async {
  // Create router with initialLocation set to /history
  final router = GoRouter(
    initialLocation: '/history',
    routes: [ /* same route tree */ ],
  );

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.dark,
      ),
    ),
  );

  // ... interact with History screen, verify navigation to LogEntry
});
```

### Rationale

1. **Factory function, not global singleton.** A global `GoRouter` instance retains navigation state (current location, stack) between tests. If test A navigates to `/history` and test B starts, test B may begin at `/history` instead of `/`. The factory function ensures a fresh router with a clean state for each test.

2. **`MaterialApp.router` in each test.** Each test builds a complete `MaterialApp.router` with its own router instance. This mirrors the production app setup and ensures the widget tree has access to all inherited widgets (`GoRouter.of(context)`, `Theme.of(context)`, etc.) that production screens depend on.

3. **`ProviderScope` wrapper.** Required by `flutter_riverpod` to provide the provider container. Even though D0 screens are shells with no providers, including `ProviderScope` from the start establishes the test pattern for D1+ where providers will be needed. `ProviderScope` also allows overriding providers in tests.

4. **`initialLocation` parameter for targeted tests.** When testing a screen other than Home, set `initialLocation` to that screen's path. This avoids needing to navigate through Home first, making tests faster and more focused.

5. **No mock router needed for D0.** D0 tests verify actual navigation (tap button, verify screen renders). Mocking the router would defeat the purpose. Mock routers are useful when testing a screen in isolation without its children, but D0's tests specifically validate that navigation works end-to-end.

### Alternatives Considered

| Alternative | Why Rejected |
|-------------|-------------|
| **Global `GoRouter` singleton** | Leaks navigation state between tests. Well-documented issue in go_router testing. Factory function is the standard solution. |
| **`MockGoRouter` with `mocktail`** | Useful for unit-testing individual screens in isolation. Not appropriate for D0 where the goal is to verify actual navigation between real screens. Mock routers would be introduced in D2+ for testing screen logic independently. |
| **`InheritedGoRouter` wrapper** | Some guides suggest wrapping tests with `InheritedGoRouter` to inject a mock. This is the pattern for mocking, not for integration-style navigation tests. D0 needs real navigation. |
| **Shared `setUp()` with test-scoped router** | Could use `late GoRouter router` with `setUp(() { router = createRouter(); })`. This works but the factory function is the simpler pattern -- just call `createRouter()` inline. Both are acceptable; the factory function is more portable (used in production code too). |

---

## 6. Dependencies for D0

### Decision

Minimal `pubspec.yaml` with only the packages required for D0 (routing + state management scaffolding + linting). No database, charts, date formatting, or ID generation packages.

```yaml
name: sleeplog
description: A local sleep tracker app.
publish_to: 'none'
version: 0.1.0

environment:
  sdk: ^3.4.0

dependencies:
  flutter:
    sdk: flutter
  go_router: ^17.1.0
  flutter_riverpod: ^3.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

**Packages included:**

| Package | Version | Purpose |
|---------|---------|---------|
| `go_router` | `^17.1.0` | Declarative routing with path/query parameters |
| `flutter_riverpod` | `^3.2.1` | State management (ProviderScope in main, ConsumerWidget base for screens) |
| `flutter_test` | SDK | Widget testing framework |
| `flutter_lints` | `^5.0.0` | Recommended lint rules for Flutter projects |

**Packages explicitly deferred:**

| Package | Deliverable | Why Deferred |
|---------|-------------|-------------|
| `drift` + `sqlite3_flutter_libs` | D1 | Database not needed for screen shells |
| `fl_chart` | D4 | Charts not needed until Insights screen |
| `intl` | D2 | Date formatting not needed for shells |
| `uuid` | D1 | ID generation not needed for shells |
| `riverpod_annotation` + `riverpod_generator` + `build_runner` | D1+ | Code generation for providers not needed in D0 (no providers beyond trivial ones) |
| `freezed` + `freezed_annotation` + `json_serializable` | D1 | Data model code generation not needed for shells |

### Rationale

1. **Minimal dependency surface.** The constitution (Principle I) requires auditing every dependency for network activity. Fewer packages mean fewer audit targets. D0 is screen shells and routing -- it needs exactly two runtime packages.

2. **`go_router ^17.1.0` pinned to minor.** The `^` caret syntax allows patch updates (17.1.x) but not major (18.0.0). This matches the version specified in the constitution's Technical Constraints.

3. **`flutter_riverpod ^3.2.1`.** Even though D0 screens have no state, `ProviderScope` must wrap the app from the start. Adding Riverpod in D0 ensures the `ProviderScope` is in place for D1+ providers, and the test pattern includes `ProviderScope` from day one.

4. **`flutter_lints` (not `lints`).** `flutter_lints` extends the Dart `lints` package with Flutter-specific rules (e.g., avoiding `print()` in production, preferring `const` constructors). The constitution requires `flutter analyze` with zero warnings as a gate.

5. **No code generation packages in D0.** `riverpod_generator`, `build_runner`, `freezed`, etc. add significant dev-time complexity (code gen step, generated files). D0 has no data models, no complex providers, and no serialisation. These packages are added in D1 when the repository layer needs them.

6. **`publish_to: 'none'`.** This is a private app, not a pub.dev package. Setting `publish_to: 'none'` prevents accidental publishing and removes the need for a package description following pub conventions.

### Alternatives Considered

| Alternative | Why Rejected |
|-------------|-------------|
| **Include all eventual dependencies upfront** | Violates Principle V (incremental delivery). Adds audit burden, increases `pub get` time, and creates unused imports that trigger lint warnings. |
| **Omit `flutter_riverpod` from D0** | Would require adding it in D1 and retroactively wrapping the app in `ProviderScope`. Adding it now is trivial (one import, one widget wrapper) and establishes the pattern for all future tests. |
| **Use `very_good_analysis` instead of `flutter_lints`** | More opinionated lint set from Very Good Ventures. Good but adds a third-party dependency for linting that goes beyond the standard Flutter recommendation. `flutter_lints` is the official Flutter team package. |
| **Pin exact versions (no caret)** | Exact pinning (`go_router: 17.1.0`) prevents patch updates that include bug fixes. Caret syntax is the Dart convention and allows safe patch-level updates. |

---

## Sources

- [go_router | pub.dev](https://pub.dev/packages/go_router)
- [go_router parameters documentation](https://docs.page/csells/go_router/parameters)
- [flutter_riverpod | pub.dev](https://pub.dev/packages/flutter_riverpod)
- [Riverpod getting started](https://riverpod.dev/docs/introduction/getting_started)
- [Flutter: Create a new app](https://docs.flutter.dev/reference/create-new-app)
- [Flutter: Use a custom font](https://docs.flutter.dev/cookbook/design/fonts)
- [Flutter: Use themes to share colors and font styles](https://docs.flutter.dev/cookbook/design/themes)
- [ThemeData class - Flutter API](https://api.flutter.dev/flutter/material/ThemeData-class.html)
- [ColorScheme class - Flutter API](https://api.flutter.dev/flutter/material/ColorScheme-class.html)
- [Satoshi font - fontshare.com](https://www.fontshare.com/fonts/satoshi)
- [Nunito - Google Fonts](https://fonts.google.com/specimen/Nunito)
- [flutter_lints | pub.dev](https://pub.dev/packages/flutter_lints)
- [Testing GoRouter in Flutter](https://guillaume.bernos.dev/testing-go-router/)
- [Testing GoRouter in Flutter #2](https://guillaume.bernos.dev/testing-go-router-2/)
- [Flutter Tips - Test with GoRouter navigation](https://apparencekit.dev/flutter-tips/how-to-test-gorouter-navigation-flutter/)
- [go_router optional parameters discussion](https://github.com/csells/go_router/discussions/186)
- [Testable GoRouter with Riverpod example](https://github.com/jpoh281/testable_gorouter_with_riverpod)
