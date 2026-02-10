import 'package:drift/native.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sleeplog/database/app_database.dart';
import 'package:sleeplog/models/sleep_entry_model.dart';
import 'package:sleeplog/providers/database_providers.dart';
import 'package:sleeplog/screens/insights_screen.dart';
import 'package:sleeplog/services/insights_calculator.dart';
import 'package:sleeplog/theme/app_theme.dart';
import 'package:sleeplog/widgets/duration_bar_chart.dart';
import 'package:sleeplog/widgets/pattern_summary_card.dart';
import 'package:sleeplog/widgets/quality_line_chart.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Widget buildTestApp({AppDatabase? database}) {
    final router = GoRouter(
      initialLocation: '/insights',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(),
          routes: [
            GoRoute(
              path: 'insights',
              builder: (context, state) => const InsightsScreen(),
            ),
            GoRoute(
              path: 'log',
              builder: (context, state) =>
                  const Scaffold(body: Text('Log Entry')),
            ),
          ],
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

  Future<void> seedEntries(AppDatabase db, int count,
      {int startDaysBack = 0}) async {
    for (var i = 0; i < count; i++) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final wakeDay = today.subtract(Duration(days: startDaysBack + i));
      final wakeTs = DateTime(wakeDay.year, wakeDay.month, wakeDay.day, 7, 0);
      final bedtimeTs =
          wakeTs.subtract(Duration(hours: 6 + (i % 4), minutes: (i * 13) % 60));
      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: bedtimeTs,
        wakeTs: wakeTs,
        quality: (i % 5) + 1,
      ));
    }
  }

  group('DurationBarChart widget', () {
    testWidgets('renders BarChart with 7 data points', (tester) async {
      final data = List.generate(7, (i) {
        final day = DateTime(2025, 3, 9 + i);
        final date =
            '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        return (date: date, durationMinutes: (i + 1) * 60);
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(body: DurationBarChart(data: data)),
        ),
      );

      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('renders with all-zero data', (tester) async {
      final data = List.generate(7, (i) {
        final day = DateTime(2025, 3, 9 + i);
        final date =
            '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        return (date: date, durationMinutes: 0);
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(body: DurationBarChart(data: data)),
        ),
      );

      expect(find.byType(BarChart), findsOneWidget);
    });
  });

  group('QualityLineChart widget', () {
    testWidgets('renders LineChart with data points', (tester) async {
      final data = List.generate(15, (i) {
        final day = DateTime(2025, 3, 1 + i);
        final date =
            '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        return (date: date, averageQuality: 1.0 + (i % 5));
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(body: QualityLineChart(data: data)),
        ),
      );

      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('renders with single data point', (tester) async {
      final data = [
        (date: '2025-03-15', averageQuality: 4.0),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(body: QualityLineChart(data: data)),
        ),
      );

      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('shows "No quality data" for empty data', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: QualityLineChart(data: []),
          ),
        ),
      );

      expect(find.text('No quality data'), findsOneWidget);
      expect(find.byType(LineChart), findsNothing);
    });
  });

  group('PatternSummaryCard widget', () {
    testWidgets('displays all 6 metrics', (tester) async {
      const summary = PatternSummary(
        avgDuration7d: 420,
        avgDuration30d: 450,
        avgQuality30d: 3.8,
        consistencyText: 'Your bedtime is very consistent',
        bestDay: 'Saturday',
        worstDay: 'Wednesday',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: PatternSummaryCard(summary: summary),
            ),
          ),
        ),
      );

      expect(find.text('Patterns'), findsOneWidget);
      expect(find.text('Avg duration (7d)'), findsOneWidget);
      expect(find.text('7h 0m'), findsOneWidget);
      expect(find.text('Avg duration (30d)'), findsOneWidget);
      expect(find.text('7h 30m'), findsOneWidget);
      expect(find.text('Avg quality (30d)'), findsOneWidget);
      expect(find.text('3.8 / 5'), findsOneWidget);
      expect(find.text('Bedtime consistency'), findsOneWidget);
      expect(find.text('Your bedtime is very consistent'), findsOneWidget);
      expect(find.text('Best day'), findsOneWidget);
      expect(find.text('Saturday'), findsOneWidget);
      expect(find.text('Worst day'), findsOneWidget);
      expect(find.text('Wednesday'), findsOneWidget);
    });

    testWidgets('shows dash for null bestDay/worstDay', (tester) async {
      const summary = PatternSummary(
        avgDuration7d: 0,
        avgDuration30d: 0,
        avgQuality30d: 0.0,
        consistencyText: 'Not enough data for consistency',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: PatternSummaryCard(summary: summary),
            ),
          ),
        ),
      );

      // Em-dash for null days.
      expect(find.text('\u2014'), findsNWidgets(2));
    });
  });

  group('InsightsScreen empty state', () {
    testWidgets('shows empty message and CTA when zero entries', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(
        find.text('Not enough data for insights yet.'),
        findsOneWidget,
      );
      expect(
        find.text('Log a few nights of sleep to start seeing patterns.'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(ElevatedButton, 'Log sleep'),
        findsOneWidget,
      );
      expect(find.byType(BarChart), findsNothing);
      expect(find.byType(LineChart), findsNothing);
    });

    testWidgets('CTA navigates to /log', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Log sleep'));
      await tester.pumpAndSettle();

      expect(find.text('Log Entry'), findsOneWidget);
    });
  });

  group('InsightsScreen with data', () {
    testWidgets('displays Insights title', (tester) async {
      await seedEntries(db, 7);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Insights'), findsOneWidget);
    });

    testWidgets('shows bar chart with seeded data', (tester) async {
      await seedEntries(db, 7);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(BarChart), findsOneWidget);
      expect(find.text('Last 7 days'), findsOneWidget);
    });

    testWidgets('shows line chart with seeded data', (tester) async {
      await seedEntries(db, 10);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(LineChart), findsOneWidget);
      expect(find.text('Quality trend (30 days)'), findsOneWidget);
    });

    testWidgets('shows pattern summaries with seeded data', (tester) async {
      await seedEntries(db, 10);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Patterns'), findsOneWidget);
      expect(find.text('Avg duration (7d)'), findsOneWidget);
      expect(find.text('Avg duration (30d)'), findsOneWidget);
      expect(find.text('Avg quality (30d)'), findsOneWidget);
      expect(find.text('Bedtime consistency'), findsOneWidget);
      expect(find.text('Best day'), findsOneWidget);
      expect(find.text('Worst day'), findsOneWidget);
    });
  });
}
