import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sleeplog/screens/log_entry_screen.dart';
import 'package:sleeplog/theme/app_theme.dart';

void main() {
  testWidgets('shows Log Entry title when no id param', (tester) async {
    final router = GoRouter(
      initialLocation: '/log',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(),
          routes: [
            GoRoute(
              path: 'log',
              builder: (context, state) {
                final id = state.uri.queryParameters['id'];
                return LogEntryScreen(entryId: id);
              },
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router, theme: AppTheme.dark),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Log Entry'), findsOneWidget);
  });

  testWidgets('shows Edit Entry title when id param is provided', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/log?id=abc123',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(),
          routes: [
            GoRoute(
              path: 'log',
              builder: (context, state) {
                final id = state.uri.queryParameters['id'];
                return LogEntryScreen(entryId: id);
              },
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router, theme: AppTheme.dark),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Entry'), findsOneWidget);
  });

  testWidgets('shows placeholder body text', (tester) async {
    final router = GoRouter(
      initialLocation: '/log',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(),
          routes: [
            GoRoute(
              path: 'log',
              builder: (context, state) {
                final id = state.uri.queryParameters['id'];
                return LogEntryScreen(entryId: id);
              },
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router, theme: AppTheme.dark),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sleep entry form coming soon.'), findsOneWidget);
  });
}
