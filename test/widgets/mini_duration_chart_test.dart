import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleeplog/providers/home_providers.dart';
import 'package:sleeplog/theme/app_theme.dart';
import 'package:sleeplog/widgets/mini_duration_chart.dart';

void main() {
  Widget buildChart(List<DurationDataPoint> data) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: MiniDurationChart(data: data)),
    );
  }

  List<DurationDataPoint> makeData({int durationMinutes = 420}) {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      final date =
          '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      return (date: date, durationMinutes: durationMinutes);
    });
  }

  testWidgets('renders without errors with valid 7-point data', (
    tester,
  ) async {
    await tester.pumpWidget(buildChart(makeData()));
    await tester.pumpAndSettle();

    expect(find.byType(BarChart), findsOneWidget);
  });

  testWidgets('renders with all-zero data', (tester) async {
    await tester.pumpWidget(buildChart(makeData(durationMinutes: 0)));
    await tester.pumpAndSettle();

    expect(find.byType(BarChart), findsOneWidget);
  });

  testWidgets('chart has fixed height of 120', (tester) async {
    await tester.pumpWidget(buildChart(makeData()));
    await tester.pumpAndSettle();

    final sizedBox = tester.widget<SizedBox>(
      find.ancestor(
        of: find.byType(BarChart),
        matching: find.byType(SizedBox),
      ),
    );
    expect(sizedBox.height, 120);
  });
}
