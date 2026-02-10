import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleeplog/database/app_database.dart';
import 'package:sleeplog/providers/database_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:sleeplog/routing/app_router.dart';
import 'package:sleeplog/screens/history_screen.dart';
import 'package:sleeplog/screens/home_screen.dart';
import 'package:sleeplog/screens/insights_screen.dart';
import 'package:sleeplog/screens/log_entry_screen.dart';
import 'package:sleeplog/theme/app_theme.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Widget buildApp({GoRouter? router}) {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp.router(
        routerConfig: router ?? createRouter(),
        theme: AppTheme.dark,
      ),
    );
  }

  testWidgets(
    'initial route renders HomeScreen with BottomNavigationBar and FAB',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    },
  );

  testWidgets('tapping FAB navigates to LogEntryScreen', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(LogEntryScreen), findsOneWidget);
  });

  testWidgets('tapping History tab shows HistoryScreen', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final bottomNav = find.byType(BottomNavigationBar);
    await tester.tap(
      find.descendant(of: bottomNav, matching: find.text('History')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HistoryScreen), findsOneWidget);
  });

  testWidgets('tapping Insights tab shows InsightsScreen', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final bottomNav = find.byType(BottomNavigationBar);
    await tester.tap(
      find.descendant(of: bottomNav, matching: find.text('Insights')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(InsightsScreen), findsOneWidget);
  });

  testWidgets(
    'LogEntry covers bottom nav bar (pushed on root navigator)',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(LogEntryScreen), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
    },
  );

  testWidgets('back from LogEntry returns to shell', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(LogEntryScreen), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });

  testWidgets('/log?id=abc123 passes entryId to LogEntryScreen', (
    tester,
  ) async {
    final router = createRouter();
    await tester.pumpWidget(buildApp(router: router));
    await tester.pumpAndSettle();

    router.push('/log?id=abc123');
    // Pump once to navigate, then once more for the FutureProvider to resolve
    await tester.pump();
    await tester.pump();

    // The screen shows "Edit Entry" title (entry not found triggers pop via
    // addPostFrameCallback, but before that the title is visible)
    expect(find.text('Edit Entry'), findsOneWidget);
  });
}
