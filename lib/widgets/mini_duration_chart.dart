import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/home_providers.dart';

class MiniDurationChart extends StatelessWidget {
  const MiniDurationChart({super.key, required this.data});

  final List<DurationDataPoint> data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelSmall;

    // Compute max Y for chart scaling (minimum 480 = 8h so bars aren't huge
    // when values are small).
    final maxMinutes = data.fold<int>(0, (m, p) => p.durationMinutes > m ? p.durationMinutes : m);
    final maxY = (maxMinutes > 480 ? maxMinutes : 480).toDouble();

    // Compute average of non-zero durations for accessibility label.
    final nonZero = data.where((d) => d.durationMinutes > 0).toList();
    final avgMinutes = nonZero.isEmpty
        ? 0
        : nonZero.fold<int>(0, (sum, d) => sum + d.durationMinutes) ~/ nonZero.length;
    final avgH = avgMinutes ~/ 60;
    final avgM = avgMinutes % 60;
    final semanticsLabel = 'Last 7 days sleep duration chart. Average: ${avgH}h ${avgM}m';

    return Semantics(
      label: semanticsLabel,
      child: SizedBox(
      height: 120,
      child: ExcludeSemantics(child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          barTouchData: const BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox.shrink();
                  }
                  final date = DateTime.tryParse(data[index].date);
                  final label = date != null ? DateFormat.E().format(date) : '';
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(label, style: labelStyle),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(data.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i].durationMinutes.toDouble(),
                  color: colorScheme.primary,
                  width: 16,
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
