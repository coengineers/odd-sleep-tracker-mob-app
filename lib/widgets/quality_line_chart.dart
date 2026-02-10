import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/insights_calculator.dart';

class QualityLineChart extends StatelessWidget {
  const QualityLineChart({super.key, required this.data});

  /// 0–30 [QualityDataPoint]s sorted oldest → newest.
  final List<QualityDataPoint> data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelSmall;
    final theme = Theme.of(context);

    if (data.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text('No quality data', style: theme.textTheme.bodyMedium),
        ),
      );
    }

    // Map data points to FlSpot using index as x-coordinate.
    final spots = <FlSpot>[];
    for (var i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i].averageQuality));
    }

    // Show x-axis labels at roughly weekly intervals.
    final labelInterval = data.length <= 7 ? 1 : (data.length / 4).ceil();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 1,
          maxY: 5,
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          lineTouchData: const LineTouchData(enabled: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value == value.roundToDouble() &&
                      value >= 1 &&
                      value <= 5) {
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        value.toInt().toString(),
                        style: labelStyle,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: labelInterval.toDouble(),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox.shrink();
                  }
                  final date = DateTime.tryParse(data[index].date);
                  final label =
                      date != null ? DateFormat.MMMd().format(date) : '';
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
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: colorScheme.outline.withValues(alpha: 0.3),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: colorScheme.primary,
              barWidth: 2,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 4,
                  color: colorScheme.primary,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
