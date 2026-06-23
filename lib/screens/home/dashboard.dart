import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/dashboard_model.dart';
import '../../providers/dashboard_provider.dart';
import '../../services/auth_service.dart';
import '../../services/update_service.dart';
import '../../theme/chart_theme.dart';
import '../../theme/design_constants.dart';
import '../../utils/window_size.dart';
import '../../widgets/body_width.dart';
import '../../widgets/custom_card_container.dart';
import '../../widgets/event_feed_item.dart';
import '../../widgets/nav_destinations.dart';
import '../../widgets/nav_shell.dart';
import '../../widgets/states/app_skeleton.dart';
import '../../widgets/states/empty_state.dart';
import '../../widgets/states/error_state.dart';
import '../../widgets/status_pill.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DashboardProvider>().fetchSummary();
      UpdateService().checkForUpdates(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final summary = dashboardProvider.summary;

    return PopScope(
      canPop: false,
      child: NavShell(
        current: NavSection.dashboard,
        title: 'Inicio',
        body: _buildBodyContent(dashboardProvider, summary),
      ),
    );
  }

  Widget _buildBodyContent(DashboardProvider provider, DashboardModel? summary) {
    if (provider.isLoading) {
      return const AppSkeleton.dashboard();
    }
    if (provider.error != null && summary == null) {
      return ErrorState(
        error: provider.error,
        onRetry: () => provider.fetchSummary(),
      );
    }
    if (summary == null) {
      return const EmptyState(
        icon: Icons.dashboard_outlined,
        title: 'No hay datos disponibles',
      );
    }
    return _buildMainContent(summary);
  }

  // ---------------------------------------------------------------------------
  // CONTENIDO PRINCIPAL
  // ---------------------------------------------------------------------------
  Widget _buildMainContent(DashboardModel summary) {
    final isCompact = context.isCompact;

    return RefreshIndicator(
      onRefresh: () => context.read<DashboardProvider>().fetchSummary(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: isCompact ? Spacing.lg : Spacing.xl),
        child: BodyWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(),
              const SizedBox(height: Spacing.xl),
              _buildKpiGrid(summary),
              const SizedBox(height: Spacing.xl),
              _GrowthChartCard(growth: summary.membershipGrowth),
              const SizedBox(height: Spacing.xl),
              _buildBottomBand(summary, isCompact),
              const SizedBox(height: Spacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  // --- a) Saludo ---
  Widget _buildGreeting() {
    final auth = context.watch<AuthService>();
    final textTheme = Theme.of(context).textTheme;
    final name = auth.userName?.trim();
    final role = auth.userRole?.trim();
    final greeting = (name != null && name.isNotEmpty) ? 'Hola, $name' : 'Hola';
    final subtitleParts = [
      if (role != null && role.isNotEmpty) role,
      _todayLabel(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(greeting, style: textTheme.headlineMedium),
        const SizedBox(height: Spacing.xxs),
        Text(
          subtitleParts.join(' · '),
          style: textTheme.bodyMedium?.copyWith(color: secondaryText),
        ),
      ],
    );
  }

  // --- b) Cuadrícula de KPIs ---
  Widget _buildKpiGrid(DashboardModel summary) {
    final cards = <_KpiData>[
      _KpiData(
        'Total Miembros',
        summary.totalMembers.toString(),
        Icons.groups_rounded,
        primaryContainer,
        onPrimaryContainer,
        primaryText,
        'members',
        isPrimary: true,
      ),
      _KpiData(
        'Activos',
        summary.activeMembers.toString(),
        Icons.check_circle_rounded,
        successContainer,
        onSuccessContainer,
        onSuccessContainer,
        'members',
      ),
      _KpiData(
        'Inactivos',
        summary.inactiveMembers.toString(),
        Icons.pause_circle_filled_rounded,
        warningContainer,
        onWarningContainer,
        onWarningContainer,
        'members',
      ),
      _KpiData(
        'Redes',
        summary.totalNetworks.toString(),
        Icons.hub_rounded,
        primaryContainer,
        onPrimaryContainer,
        primaryText,
        'networks',
      ),
      _KpiData(
        'Ministerios',
        summary.totalMinistries.toString(),
        Icons.diversity_3_rounded,
        neutralContainer,
        onNeutralContainer,
        primaryText,
        'ministries',
      ),
    ];

    final size = context.windowSize;
    final columns = switch (size) {
      WindowSize.compact => 2,
      WindowSize.medium => 3,
      WindowSize.expanded => 5,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = Spacing.md;
        final maxWidth = constraints.maxWidth;
        final itemWidth = (maxWidth - (columns - 1) * gap) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final c in cards)
              SizedBox(
                width: (size == WindowSize.compact && c.isPrimary)
                    ? maxWidth
                    : itemWidth,
                child: _kpiCard(c),
              ),
          ],
        );
      },
    );
  }

  Widget _kpiCard(_KpiData c) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(DesignConstants.borderRadiusCard),
      onTap: () => Navigator.pushNamed(context, c.route),
      child: CustomCardContainer(
        raised: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c.container,
                borderRadius:
                    BorderRadius.circular(DesignConstants.borderRadiusChip),
              ),
              child: Icon(c.icon, size: 22, color: c.onContainer),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              c.value,
              style: textTheme.headlineMedium?.copyWith(color: c.valueColor),
            ),
            const SizedBox(height: Spacing.xxs),
            Text(c.label, style: textTheme.labelMedium),
          ],
        ),
      ),
    );
  }

  // --- d) Banda inferior: dona de actividad + servicios de la semana ---
  Widget _buildBottomBand(DashboardModel summary, bool isCompact) {
    final activity = _ActivityCard(
      active: summary.activeMembers,
      inactive: summary.inactiveMembers,
    );
    final services = _ServicesCard(
      events: summary.weeklyEvents,
      onSeeAll: () => Navigator.pushNamed(context, 'services'),
      onTapEvent: () => Navigator.pushNamed(context, 'services'),
    );

    if (isCompact) {
      return Column(
        children: [
          activity,
          const SizedBox(height: Spacing.xl),
          services,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: activity),
        const SizedBox(width: Spacing.xl),
        Expanded(flex: 3, child: services),
      ],
    );
  }
}

// =============================================================================
// KPI data holder
// =============================================================================
class _KpiData {
  final String label;
  final String value;
  final IconData icon;
  final Color container;
  final Color onContainer;
  final Color valueColor;
  final String route;
  final bool isPrimary;

  _KpiData(
    this.label,
    this.value,
    this.icon,
    this.container,
    this.onContainer,
    this.valueColor,
    this.route, {
    this.isPrimary = false,
  });
}

// =============================================================================
// c) Gráfico de crecimiento de miembros (línea simple)
// =============================================================================
class _GrowthChartCard extends StatelessWidget {
  final List<MembershipGrowthPoint> growth;

  const _GrowthChartCard({required this.growth});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CustomCardContainer(
      raised: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Crecimiento de miembros', style: textTheme.titleLarge),
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

// =============================================================================
// d.1) Dona de actividad (activos vs inactivos)
// =============================================================================
class _ActivityCard extends StatelessWidget {
  final int active;
  final int inactive;

  const _ActivityCard({required this.active, required this.inactive});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total = active + inactive;

    return CustomCardContainer(
      raised: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Actividad de miembros', style: textTheme.titleLarge),
          const Divider(height: Spacing.xl),
          if (total == 0)
            const SizedBox(
              height: 160,
              child: Center(
                child: Text(
                  'Sin miembros para mostrar',
                  style: TextStyle(color: secondaryText),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 56,
                      startDegreeOffset: -90,
                      sections: [
                        PieChartSectionData(
                          value: active.toDouble(),
                          color: accentColor,
                          radius: 22,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: inactive.toDouble(),
                          color: warningColor,
                          radius: 22,
                          showTitle: false,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$total', style: textTheme.headlineSmall),
                      Text('Miembros', style: textTheme.labelMedium),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.lg),
            _legendRow(
              context,
              StatusPill.active('Activos'),
              active,
              _percent(active, total),
            ),
            const SizedBox(height: Spacing.sm),
            _legendRow(
              context,
              StatusPill.inactive('Inactivos'),
              inactive,
              _percent(inactive, total),
            ),
          ],
        ],
      ),
    );
  }

  Widget _legendRow(
    BuildContext context,
    Widget pill,
    int count,
    double pct,
  ) {
    return Row(
      children: [
        pill,
        const Spacer(),
        Text(
          '$count · ${pct.toStringAsFixed(0)}%',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: secondaryText),
        ),
      ],
    );
  }
}

// =============================================================================
// d.2) Servicios de la semana (agrupados por día)
// =============================================================================
class _ServicesCard extends StatelessWidget {
  final List<WeeklyEvent> events;
  final VoidCallback onSeeAll;
  final VoidCallback onTapEvent;

  const _ServicesCard({
    required this.events,
    required this.onSeeAll,
    required this.onTapEvent,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CustomCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Servicios de la semana', style: textTheme.titleLarge),
              const Spacer(),
              TextButton(onPressed: onSeeAll, child: const Text('Ver todos')),
            ],
          ),
          const Divider(height: Spacing.lg),
          if (events.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: Spacing.xl),
              child: Center(
                child: EmptyState(
                  icon: Icons.event_busy_rounded,
                  title: 'Sin servicios esta semana',
                ),
              ),
            )
          else
            ..._buildFeed(),
        ],
      ),
    );
  }

  List<Widget> _buildFeed() {
    final sorted = [...events]..sort((a, b) {
        final byDay = a.dayOfWeek.compareTo(b.dayOfWeek);
        return byDay != 0 ? byDay : a.startTime.compareTo(b.startTime);
      });
    final shown = sorted.take(4).toList();
    final now = DateTime.now();

    final widgets = <Widget>[];
    for (var i = 0; i < shown.length; i++) {
      final e = shown[i];
      widgets.add(
        EventFeedItem(
          title: e.name,
          type: e.type,
          description: e.description,
          scheduleLabel: '${_dayFull(e.dayOfWeek)} · ${_time12h(e.startTime)}',
          isToday: e.dayOfWeek == now.weekday,
          onTap: onTapEvent,
        ),
      );
      if (i < shown.length - 1) widgets.add(const Divider(height: 1));
    }
    return widgets;
  }
}

// =============================================================================
// Helpers
// =============================================================================
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

const List<String> _monthNames = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

const List<String> _weekdayNames = [
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo',
];

/// "Junio 2026" -> "Jun".
String _monthAbbrev(String label) {
  if (label.isEmpty) return '';
  final name = label.split(' ').first;
  return _monthAbbrevMap[name] ??
      (name.length >= 3 ? name.substring(0, 3) : name);
}

/// "09:00:00" -> "9:00 AM".
String _time12h(String startTime) {
  final parts = startTime.split(':');
  if (parts.length < 2) return startTime;
  final h = int.tryParse(parts[0]) ?? 0;
  final minute = parts[1].padLeft(2, '0');
  final period = h >= 12 ? 'PM' : 'AM';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:$minute $period';
}

/// 1=Lunes … 7=Domingo.
String _dayFull(int dayOfWeek) {
  if (dayOfWeek < 1 || dayOfWeek > 7) return 'Día';
  final name = _weekdayNames[dayOfWeek - 1];
  return name[0].toUpperCase() + name.substring(1);
}

double _percent(int part, int total) =>
    total <= 0 ? 0 : (part / total * 100);

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

/// Fecha de hoy en español, sin depender de la inicialización de `intl`.
String _todayLabel() {
  final now = DateTime.now();
  final weekday = _weekdayNames[now.weekday - 1];
  final month = _monthNames[now.month - 1];
  final cap = weekday[0].toUpperCase() + weekday.substring(1);
  return '$cap, ${now.day} de $month';
}
