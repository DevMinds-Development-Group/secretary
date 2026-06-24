import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../colors.dart';
import '../models/dashboard_model.dart';
import '../theme/chart_theme.dart';
import '../theme/design_constants.dart';
import '../utils/window_size.dart';
import 'custom_card_container.dart';

/// Tarjeta con la serie de crecimiento de membresía (línea simple) + resumen de
/// tendencia. Compartida por el dashboard de inicio y el de supervisión.
class GrowthLineChart extends StatelessWidget {
  final List<MembershipGrowthPoint> growth;
  final String title;

  const GrowthLineChart({
    super.key,
    required this.growth,
    this.title = 'Crecimiento de miembros',
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CustomCardContainer(
      raised: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleLarge),
          const SizedBox(height: Spacing.xs),
          _buildSummary(context),
          const SizedBox(height: Spacing.lg),
          _buildChartArea(context),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (growth.isEmpty) {
      return Text(
        'Aún no hay datos de crecimiento',
        style: textTheme.bodyMedium?.copyWith(color: secondaryText),
      );
    }

    final last = growth.last.count;
    final prev = growth.length >= 2 ? growth[growth.length - 2].count : 0;
    final delta = last - prev;

    final IconData trendIcon;
    final Color trendColor;
    if (delta > 0) {
      trendIcon = Icons.trending_up_rounded;
      trendColor = accentColor;
    } else if (delta < 0) {
      trendIcon = Icons.trending_down_rounded;
      trendColor = errorColor;
    } else {
      trendIcon = Icons.trending_flat_rounded;
      trendColor = secondaryText;
    }

    final deltaText = delta == 0
        ? 'Sin cambios este mes'
        : '${delta > 0 ? '+' : ''}$delta este mes';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('$last', style: textTheme.headlineSmall),
        const SizedBox(width: Spacing.sm),
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            children: [
              Icon(trendIcon, size: 18, color: trendColor),
              const SizedBox(width: 2),
              Text(
                deltaText,
                style: textTheme.labelMedium?.copyWith(color: trendColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartArea(BuildContext context) {
    final isCompact = context.isCompact;
    final size = context.windowSize;
    final height = switch (size) {
      WindowSize.compact => 220.0,
      WindowSize.medium => 260.0,
      WindowSize.expanded => 300.0,
    };

    if (growth.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Icon(Icons.show_chart_rounded, size: 48, color: secondaryText),
        ),
      );
    }

    final maxCount =
        growth.map((g) => g.count).fold<int>(0, (a, b) => a > b ? a : b);
    final allZero = maxCount == 0;
    final maxY = allZero ? 1.0 : _niceCeil(maxCount * 1.15);
    final interval = allZero ? 1.0 : _niceInterval(maxY);

    final spots = [
      for (int i = 0; i < growth.length; i++)
        FlSpot(i.toDouble(), growth[i].count.toDouble()),
    ];

    // Densidad de etiquetas del eje X según ancho.
    final step = switch (size) {
      WindowSize.compact => 3,
      WindowSize.medium => 2,
      WindowSize.expanded => 1,
    };
    final showDots = !isCompact || growth.length == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (allZero)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: Text(
              'Sin miembros registrados aún',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: secondaryText),
            ),
          ),
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (growth.length - 1).toDouble(),
              minY: 0,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: interval,
                getDrawingHorizontalLine: (v) =>
                    const FlLine(color: ChartTheme.grid, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: interval,
                    reservedSize: 38,
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        value.toInt().toString(),
                        style: ChartTheme.axisLabel,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= growth.length) {
                        return const SizedBox.shrink();
                      }
                      if (index % step != 0) return const SizedBox.shrink();
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 6,
                        child: Text(
                          _monthAbbrev(growth[index].label),
                          style: ChartTheme.axisLabel,
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => ChartTheme.tooltipBackground,
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                    final p = growth[s.x.toInt()];
                    return LineTooltipItem(
                      '${p.label}\n${p.count} miembros',
                      const TextStyle(
                        color: ChartTheme.tooltipText,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.25,
                  preventCurveOverShooting: true,
                  color: primaryColor,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: showDots,
                    getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                      radius: 3,
                      color: primaryColor,
                      strokeWidth: 2,
                      strokeColor: secondaryBackground,
                    ),
                  ),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// "Junio 2026" -> "Jun".
const Map<String, String> _monthAbbrevMap = {
  'Enero': 'Ene',
  'Febrero': 'Feb',
  'Marzo': 'Mar',
  'Abril': 'Abr',
  'Mayo': 'May',
  'Junio': 'Jun',
  'Julio': 'Jul',
  'Agosto': 'Ago',
  'Septiembre': 'Sep',
  'Octubre': 'Oct',
  'Noviembre': 'Nov',
  'Diciembre': 'Dic',
};

String _monthAbbrev(String label) {
  if (label.isEmpty) return '';
  final name = label.split(' ').first;
  return _monthAbbrevMap[name] ??
      (name.length >= 3 ? name.substring(0, 3) : name);
}

/// Redondea hacia arriba a un valor "limpio" para el eje Y.
double _niceCeil(double v) {
  if (v <= 10) return v.ceilToDouble().clamp(1, double.infinity);
  if (v <= 50) return (v / 10).ceil() * 10;
  if (v <= 100) return (v / 20).ceil() * 20;
  if (v <= 500) return (v / 50).ceil() * 50;
  if (v <= 1000) return (v / 100).ceil() * 100;
  return (v / 500).ceil() * 500;
}

/// Intervalo de marcas del eje Y (~5-6 marcas).
double _niceInterval(double maxY) {
  final raw = maxY / 5;
  if (raw <= 1) return 1;
  if (raw <= 5) return 5;
  if (raw <= 10) return 10;
  if (raw <= 25) return 25;
  if (raw <= 50) return 50;
  if (raw <= 100) return 100;
  return 200;
}
