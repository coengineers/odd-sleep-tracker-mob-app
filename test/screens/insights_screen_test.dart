import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sleeplog/screens/insights_screen.dart';
import 'package:sleeplog/theme/app_theme.dart';

void main() {
  testWidgets('displays Insights title', (tester) async {
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

    expect(find.text('Insights'), findsOneWidget);
  });

  testWidgets('displays placeholder body text', (tester) async {
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

    expect(find.text('Sleep insights will appear here.'), findsOneWidget);
  });
}
