import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleeplog/routing/app_router.dart';
import 'package:sleeplog/screens/history_screen.dart';
import 'package:sleeplog/screens/home_screen.dart';
import 'package:sleeplog/screens/insights_screen.dart';
import 'package:sleeplog/screens/log_entry_screen.dart';
import 'package:sleeplog/theme/app_theme.dart';

void main() {
  testWidgets('initial route renders HomeScreen with BottomNavigationBar and FAB', (tester) async {
    final router = createRouter();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router, theme: AppTheme.dark),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('tapping FAB navigates to LogEntryScreen', (tester) async {
    final router = createRouter();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router, theme: AppTheme.dark),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(LogEntryScreen), findsOneWidget);
  });

  testWidgets('tapping History tab shows HistoryScreen', (tester) async {
    final router = createRouter();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router, theme: AppTheme.dark),
      ),
    );
    await tester.pumpAndSettle();

    final bottomNav = find.byType(BottomNavigationBar);
    await tester.tap(find.descendant(of: bottomNav, matching: find.text('History')));
    await tester.pumpAndSettle();

    expect(find.byType(HistoryScreen), findsOneWidget);
  });

  testWidgets('tapping Insights tab shows InsightsScreen', (tester) async {
    final router = createRouter();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router, theme: AppTheme.dark),
      ),
    );
    await tester.pumpAndSettle();

    final bottomNav = find.byType(BottomNavigationBar);
    await tester.tap(find.descendant(of: bottomNav, matching: find.text('Insights')));
    await tester.pumpAndSettle();

    expect(find.byType(InsightsScreen), findsOneWidget);
  });

  testWidgets('LogEntry covers bottom nav bar (pushed on root navigator)', (tester) async {
    final router = createRouter();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router, theme: AppTheme.dark),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(LogEntryScreen), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
  });

  testWidgets('back from LogEntry returns to shell', (tester) async {
    final router = createRouter();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router, theme: AppTheme.dark),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(LogEntryScreen), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });

  testWidgets('/log?id=abc123 passes entryId to LogEntryScreen', (tester) async {
    final router = createRouter();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router, theme: AppTheme.dark),
      ),
    );
    await tester.pumpAndSettle();

    router.push('/log?id=abc123');
    await tester.pumpAndSettle();

    expect(find.text('Edit Entry'), findsOneWidget);
  });
}
