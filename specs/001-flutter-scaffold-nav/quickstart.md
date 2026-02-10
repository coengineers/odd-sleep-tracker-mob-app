# Quickstart: Flutter Scaffold & Navigation (D0)

**Branch**: `001-flutter-scaffold-nav` | **Date**: 2026-02-09

## Prerequisites

- Flutter SDK 3.22+ (stable channel)
- Dart SDK 3.4+
- Xcode (for iOS simulator) or Android Studio (for Android emulator)
- Git

## Setup

### 1. Create the Flutter project

```bash
flutter create \
  --org com.coengineers \
  --platforms ios,android \
  --project-name sleeplog \
  .
```

**Note**: Running `flutter create .` in the existing repo root creates
the Flutter project in-place, adding `lib/`, `test/`, `ios/`,
`android/`, `pubspec.yaml`, etc. without overwriting existing files
like `README.md`, `docs/`, or `specs/`.

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Download and bundle fonts

Download the following font files and place them in `assets/fonts/`:

- **Satoshi-Variable.ttf** from [fontshare.com/fonts/satoshi](https://www.fontshare.com/fonts/satoshi)
- **Nunito-Regular.ttf** (400), **Nunito-SemiBold.ttf** (600), **Nunito-Bold.ttf** (700) from [Google Fonts: Nunito](https://fonts.google.com/specimen/Nunito)

### 4. Verify setup

```bash
flutter analyze   # Must show zero warnings/errors
flutter test      # Must show all tests passing
flutter run       # Launch on connected device/simulator
```

## Run

```bash
# Run on iOS simulator
flutter run -d ios

# Run on Android emulator
flutter run -d android

# Run with verbose logging
flutter run --verbose
```

## Test

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/routing/app_router_test.dart

# Run tests with coverage
flutter test --coverage
```

## Lint

```bash
# Analyse code for lint issues
flutter analyze

# Format code
dart format lib/ test/
```

## Project Structure

```text
lib/
├── main.dart                      # App entry, ProviderScope + MaterialApp.router
├── routing/
│   └── app_router.dart            # createRouter() factory
├── screens/
│   ├── home_screen.dart           # Home screen with empty state + CTAs
│   ├── log_entry_screen.dart      # Log Entry shell (optional id param)
│   ├── history_screen.dart        # History shell
│   └── insights_screen.dart       # Insights shell
└── theme/
    └── app_theme.dart             # AppTheme.dark (brand tokens)

test/
├── screens/                       # Widget tests per screen
└── routing/                       # Navigation tests
```

## Key Design Decisions

1. **`createRouter()` factory** — not a global singleton. Required
   for test isolation (each test gets a fresh router).
2. **`context.push()`** — not `context.go()`. Preserves back stack
   for push-style navigation.
3. **Query parameter `?id=`** — not path parameter `:id`. Makes the
   edit ID truly optional without separate routes.
4. **Manual `ColorScheme`** — not `fromSeed()`. Exact brand hex
   values from `docs/brand-kit.md`.
5. **Bundled fonts** — not `google_fonts` package. Zero network
   requests (constitution Principle I).
