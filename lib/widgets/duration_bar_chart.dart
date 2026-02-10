import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/home_providers.dart';

class DurationBarChart extends StatelessWidget {
  const DurationBarChart({super.key, required this.data});

  /// Exactly 7 [DurationDataPoint]s sorted oldest → newest.
  final List<DurationDataPoint> data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelSmall;

    final maxMinutes =
        data.fold<int>(0, (m, p) => p.durationMinutes > m ? p.durationMinutes : m);
    final maxY = (maxMinutes > 480 ? maxMinutes : 480).toDouble();

    // Compute average of non-zero durations for accessibility label.
    final nonZero = data.where((d) => d.durationMinutes > 0).toList();
    final avgMinutes = nonZero.isEmpty
        ? 0
        : nonZero.fold<int>(0, (sum, d) => sum + d.durationMinutes) ~/ nonZero.length;
    final avgH = avgMinutes ~/ 60;
    final avgM = avgMinutes % 60;
    final semanticsLabel = 'Sleep duration bar chart for the last 7 days. Average: ${avgH}h ${avgM}m';

    return Semantics(
      label: semanticsLabel,
      child: SizedBox(
      height: 200,
      child: ExcludeSemantics(child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          barTouchData: const BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: 240, // 4 hours.
                getTitlesWidget: (value, meta) {
                  final hours = value ~/ 60;
                  return SideTitleWidget(
                    meta: meta,
                    child: Text('${hours}h', style: labelStyle),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox.shrink();
                  }
                  final date = DateTime.tryParse(data[index].date);
                  final label =
                      date != null ? DateFormat.E().format(date) : '';
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(label, style: labelStyle),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 240,
            getDrawingHorizontalLine: (value) => FlLine(
              color: colorScheme.outline.withValues(alpha: 0.3),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(data.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i].durationMinutes.toDouble(),
                  color: colorScheme.primary,
                  width: 24,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }),
        ),
      )),
    ),
    );
  }
}
