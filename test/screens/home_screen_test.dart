import 'package:drift/native.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sleeplog/database/app_database.dart';
import 'package:sleeplog/models/sleep_entry_model.dart';
import 'package:sleeplog/providers/database_providers.dart';
import 'package:sleeplog/screens/home_screen.dart';
import 'package:sleeplog/theme/app_theme.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Widget buildTestApp({AppDatabase? database}) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/log',
          builder: (context, state) => const Scaffold(body: Text('Log Entry')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database ?? db),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.dark,
      ),
    );
  }

  group('Home screen with data', () {
    testWidgets('displays SleepLog title', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('SleepLog'), findsOneWidget);
    });

    testWidgets('shows today summary with seeded entry', (tester) async {
      final now = DateTime.now();
      final todayWake = DateTime(now.year, now.month, now.day, 7, 30);
      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: todayWake.subtract(const Duration(hours: 8, minutes: 30)),
        wakeTs: todayWake,
        quality: 4,
      ));

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('8h 30m'), findsOneWidget);
      expect(find.text('Quality: 4 / 5'), findsOneWidget);
      expect(find.text("Today's sleep"), findsOneWidget);
    });

    testWidgets('shows mini chart with data', (tester) async {
      final now = DateTime.now();
      final todayWake = DateTime(now.year, now.month, now.day, 7, 0);
      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: todayWake.subtract(const Duration(hours: 8)),
        wakeTs: todayWake,
        quality: 3,
      ));

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(BarChart), findsOneWidget);
      expect(find.text('Last 7 days'), findsOneWidget);
    });

    testWidgets('shows no-today-entry card when no entry for today', (
      tester,
    ) async {
      // Seed an entry for yesterday only.
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final wake = DateTime(yesterday.year, yesterday.month, yesterday.day, 7);
      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: wake.subtract(const Duration(hours: 8)),
        wakeTs: wake,
        quality: 3,
      ));

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('No sleep logged for today'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Log sleep'), findsOneWidget);
    });
  });

  group('Home screen empty state', () {
    testWidgets('shows empty state when no entries at all', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('No sleep logged yet.'), findsOneWidget);
      expect(
        find.text("Add last night's sleep to start tracking."),
        findsOneWidget,
      );
      expect(find.widgetWithText(ElevatedButton, 'Log sleep'), findsOneWidget);
    });

    testWidgets('CTA navigates to /log', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Log sleep'));
      await tester.pumpAndSettle();

      expect(find.text('Log Entry'), findsOneWidget);
    });
  });

  // Note: Loading state test omitted — in-memory DB resolves synchronously,
  // so the FutureProvider settles before the first frame renders.
}
