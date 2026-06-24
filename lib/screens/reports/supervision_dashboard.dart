import 'dart:io' show File;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/apostol_dashboard_model.dart';
import '../../providers/apostol_dashboard_provider.dart';
import '../../services/api_client.dart';
import '../../theme/design_constants.dart';
import '../../utils/download_stub.dart'
    if (dart.library.html) '../../utils/download_web.dart';
import '../../utils/window_size.dart';
import '../../widgets/app_chip.dart';
import '../../widgets/body_width.dart';
import '../../widgets/button.dart';
import '../../widgets/custom_card_container.dart';
import '../../widgets/growth_line_chart.dart';
import '../../widgets/nav_shell.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/states/app_skeleton.dart';
import '../../widgets/states/empty_state.dart';
import '../../widgets/states/error_state.dart';
import '../../widgets/status_pill.dart';

/// Dashboard de supervisión (apóstol/pastor): pinta el periodo actual
/// (~últimos 30 días) y permite exportar el informe a PDF.
class SupervisionDashboard extends StatefulWidget {
  const SupervisionDashboard({super.key});

  @override
  State<SupervisionDashboard> createState() => _SupervisionDashboardState();
}

class _SupervisionDashboardState extends State<SupervisionDashboard> {
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApostolDashboardProvider>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApostolDashboardProvider>();
    return NavShell(
      isSecondary: true,
      title: 'Supervisión',
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(ApostolDashboardProvider provider) {
    if (provider.isLoading && provider.data == null) {
      return const AppSkeleton.dashboard();
    }
    if (provider.error != null && provider.data == null) {
      return ErrorState(
        error: provider.error,
        onRetry: () => provider.fetchDashboard(),
      );
    }
    final data = provider.data;
    if (data == null) {
      return const EmptyState(
        icon: Icons.insights_outlined,
        title: 'No hay datos de supervisión',
        message: 'Aún no hay información para el periodo actual.',
      );
    }
    return _buildContent(data);
  }

  Widget _buildContent(ApostolDashboardModel d) {
    final isCompact = context.isCompact;
    return RefreshIndicator(
      onRefresh: () =>
          context.read<ApostolDashboardProvider>().fetchDashboard(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding:
            EdgeInsets.symmetric(vertical: isCompact ? Spacing.lg : Spacing.xl),
        child: BodyWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(d),
              const SizedBox(height: Spacing.xl),
              _groupHeader('Resumen general'),
              const SizedBox(height: Spacing.md),
              _buildOverviewKpis(d),
              const SizedBox(height: Spacing.xl),
              GrowthLineChart(
                growth: d.overview.membershipGrowth,
                title: 'Crecimiento de membresía',
              ),
              const SizedBox(height: Spacing.xl),
              _buildAttendanceSection(d.attendance),
              const SizedBox(height: Spacing.xl),
              _buildStructureSection(d.structure),
              const SizedBox(height: Spacing.xl),
              _buildLeaderWorkSection(d.leaderWork),
              const SizedBox(height: Spacing.xl),
              _buildEventsSection(d.events),
              const SizedBox(height: Spacing.xl),
              _buildSystemActivitySection(d.systemActivity),
              const SizedBox(height: Spacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header: periodo + exportar PDF
  // ---------------------------------------------------------------------------
  Widget _buildHeader(ApostolDashboardModel d) {
    final textTheme = Theme.of(context).textTheme;
    final isCompact = context.isCompact;

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          d.periodLabel.isEmpty ? 'Últimos 30 días' : d.periodLabel,
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: Spacing.xxs),
        Text(
          'Periodo: ${_fmtDate(d.periodStart)} – ${_fmtDate(d.periodEnd)}',
          style: textTheme.bodyMedium?.copyWith(color: secondaryText),
        ),
      ],
    );

    final exportButton = Button(
      text: 'Exportar a PDF',
      icon: Icons.picture_as_pdf_outlined,
      isLoading: _isExporting,
      size: isCompact ? const Size(double.infinity, 48) : const Size(230, 48),
      onPressed: () => _exportPdf(d),
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [info, const SizedBox(height: Spacing.lg), exportButton],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: info),
        const SizedBox(width: Spacing.lg),
        exportButton,
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Resumen general (KPIs)
  // ---------------------------------------------------------------------------
  Widget _buildOverviewKpis(ApostolDashboardModel d) {
    final o = d.overview;
    return _kpiGrid([
      StatCard(
        label: 'Miembros',
        value: '${o.totalMembers}',
        icon: Icons.groups_rounded,
      ),
      StatCard(
        label: 'Activos',
        value: '${o.activeMembers}',
        icon: Icons.check_circle_rounded,
        container: successContainer,
        onContainer: onSuccessContainer,
        valueColor: onSuccessContainer,
      ),
      StatCard(
        label: 'Inactivos',
        value: '${o.inactiveMembers}',
        icon: Icons.pause_circle_filled_rounded,
        container: warningContainer,
        onContainer: onWarningContainer,
        valueColor: onWarningContainer,
      ),
      StatCard(
        label: 'Nuevos miembros',
        value: '${d.membership.newMembers}',
        icon: Icons.person_add_alt_1_rounded,
        container: successContainer,
        onContainer: onSuccessContainer,
        valueColor: onSuccessContainer,
      ),
      StatCard(
        label: 'Redes',
        value: '${o.totalNetworks}',
        icon: Icons.hub_rounded,
      ),
      StatCard(
        label: 'Ministerios',
        value: '${o.totalMinistries}',
        icon: Icons.diversity_3_rounded,
        container: neutralContainer,
        onContainer: onNeutralContainer,
      ),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Asistencia del periodo
  // ---------------------------------------------------------------------------
  Widget _buildAttendanceSection(AttendanceSection a) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _groupHeader('Asistencia del periodo'),
        const SizedBox(height: Spacing.md),
        _kpiGrid([
          StatCard(
            label: 'Asistencia miembros',
            value: '${a.memberAttendanceTotal}',
            icon: Icons.how_to_reg_rounded,
          ),
          StatCard(
            label: 'Visitas',
            value: '${a.visitorsTotal}',
            icon: Icons.emoji_people_rounded,
            container: neutralContainer,
            onContainer: onNeutralContainer,
          ),
          StatCard(
            label: 'Visitas pastorales',
            value: '${a.pastoralVisitsTotal}',
            icon: Icons.volunteer_activism_rounded,
            container: neutralContainer,
            onContainer: onNeutralContainer,
          ),
          StatCard(
            label: 'Nuevos convertidos',
            value: '${a.newConvertsTotal}',
            icon: Icons.auto_awesome_rounded,
            container: successContainer,
            onContainer: onSuccessContainer,
            valueColor: onSuccessContainer,
          ),
        ]),
        const SizedBox(height: Spacing.lg),
        _sectionCard(
          title: 'Resumen por red',
          children: [
            for (final n in a.networkSummaries)
              _rowSummary(
                title: n.networkName,
                subtitle:
                    n.leaderDisplayName == null || n.leaderDisplayName!.isEmpty
                        ? 'Sin líder'
                        : 'Líder: ${n.leaderDisplayName}',
                primary: '${n.memberAttendanceTotal} asistencias',
                secondary:
                    '${n.visitorsTotal} visitas · ${n.attendanceRecords} reg.',
              ),
          ],
        ),
        if (a.networksWithoutRecords.isNotEmpty) ...[
          const SizedBox(height: Spacing.md),
          Text(
            'Redes sin registros',
            style: textTheme.labelLarge?.copyWith(color: secondaryText),
          ),
          const SizedBox(height: Spacing.sm),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: [
              for (final name in a.networksWithoutRecords)
                _warningPill(name),
            ],
          ),
        ],
        if (a.observations.isNotEmpty) ...[
          const SizedBox(height: Spacing.lg),
          _sectionCard(
            title: 'Observaciones',
            children: [
              for (final o in a.observations) _observationRow(o),
            ],
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Estructura
  // ---------------------------------------------------------------------------
  Widget _buildStructureSection(StructureSection s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _groupHeader('Estructura'),
        if (s.networksWithoutLeaders > 0 || s.ministriesWithoutLeaders > 0) ...[
          const SizedBox(height: Spacing.md),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: [
              if (s.networksWithoutLeaders > 0)
                _warningPill('${s.networksWithoutLeaders} redes sin líder'),
              if (s.ministriesWithoutLeaders > 0)
                _warningPill(
                    '${s.ministriesWithoutLeaders} ministerios sin líder'),
            ],
          ),
        ],
        const SizedBox(height: Spacing.md),
        _sectionCard(
          title: 'Redes',
          children: [
            for (final n in s.networks)
              _rowSummary(
                title: n.name,
                subtitle: 'Líder: ${n.leaderNames}',
                primary: '${n.totalMembers} miembros',
                secondary: '${n.activeMembers} act. · ${n.inactiveMembers} inact.',
              ),
          ],
        ),
        const SizedBox(height: Spacing.lg),
        _sectionCard(
          title: 'Ministerios',
          children: [
            for (final m in s.ministries)
              _rowSummary(
                title: m.name,
                subtitle: 'Líder: ${m.leaderNames}',
                primary: '${m.memberCount} miembros',
              ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Trabajo de líderes
  // ---------------------------------------------------------------------------
  Widget _buildLeaderWorkSection(List<LeaderWork> leaders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _groupHeader('Trabajo de líderes'),
        const SizedBox(height: Spacing.md),
        if (leaders.isEmpty)
          _sectionCard(title: 'Líderes', children: const [])
        else
          for (final l in leaders) ...[
            _leaderCard(l),
            const SizedBox(height: Spacing.md),
          ],
      ],
    );
  }

  Widget _leaderCard(LeaderWork l) {
    final textTheme = Theme.of(context).textTheme;
    final sc = l.structureScope;
    final aw = l.attendanceWork;
    final su = l.systemUsage;

    final hasDetail =
        l.eventAssignments.isNotEmpty || aw.observations.isNotEmpty;

    return CustomCardContainer(
      raised: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l.displayName, style: textTheme.titleMedium),
              ),
              const SizedBox(width: Spacing.sm),
              l.enabled
                  ? StatusPill.active()
                  : StatusPill.inactive(),
            ],
          ),
          if (l.roles.isNotEmpty) ...[
            const SizedBox(height: Spacing.sm),
            Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.xs,
              children: [
                for (final r in l.roles) AppChip(label: _prettyRole(r)),
              ],
            ),
          ],
          const SizedBox(height: Spacing.md),
          Wrap(
            spacing: Spacing.lg,
            runSpacing: Spacing.sm,
            children: [
              _miniMetric(Icons.fact_check_outlined,
                  '${aw.attendanceRecords} registros'),
              _miniMetric(Icons.groups_outlined,
                  '${sc.membersUnderResponsibility} a cargo'),
              _miniMetric(
                  Icons.bolt_outlined, '${su.totalActions} acciones'),
              _miniMetric(Icons.schedule_outlined,
                  'Últ. actividad: ${_fmtDate(su.lastActivityAt ?? '')}'),
            ],
          ),
          if (hasDetail)
            Theme(
              data: Theme.of(context)
                  .copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: Spacing.sm),
                title: Text(
                  'Ver detalle',
                  style:
                      textTheme.labelLarge?.copyWith(color: primaryColor),
                ),
                children: [
                  if (l.eventAssignments.isNotEmpty) ...[
                    _detailLabel('Asignaciones'),
                    for (final e in l.eventAssignments)
                      _assignmentRow(e),
                  ],
                  if (aw.observations.isNotEmpty) ...[
                    const SizedBox(height: Spacing.sm),
                    _detailLabel('Observaciones'),
                    for (final o in aw.observations) _observationRow(o),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Eventos
  // ---------------------------------------------------------------------------
  Widget _buildEventsSection(EventsSection e) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _groupHeader('Eventos'),
        const SizedBox(height: Spacing.md),
        _kpiGrid([
          StatCard(
            label: 'Asignaciones predicador',
            value: '${e.preacherAssignments}',
            icon: Icons.record_voice_over_rounded,
          ),
          StatCard(
            label: 'Asignaciones alabanza',
            value: '${e.worshipAssignments}',
            icon: Icons.music_note_rounded,
            container: neutralContainer,
            onContainer: onNeutralContainer,
          ),
        ]),
        const SizedBox(height: Spacing.lg),
        _sectionCard(
          title: 'Definiciones activas por tipo',
          children: e.enabledDefinitionsByType.isEmpty
              ? const []
              : [
                  Wrap(
                    spacing: Spacing.sm,
                    runSpacing: Spacing.sm,
                    children: [
                      for (final entry in e.enabledDefinitionsByType.entries)
                        AppChip(
                          label: '${_prettyType(entry.key)}: ${entry.value}',
                        ),
                    ],
                  ),
                ],
        ),
        const SizedBox(height: Spacing.lg),
        _sectionCard(
          title: 'Asignaciones del periodo',
          children: [
            for (final a in e.assignments) _assignmentRow(a),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Actividad del sistema
  // ---------------------------------------------------------------------------
  Widget _buildSystemActivitySection(SystemActivitySection s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _groupHeader('Actividad del sistema'),
        const SizedBox(height: Spacing.md),
        _sectionCard(
          title: 'Usuarios más activos',
          children: [
            for (final u in s.topUsers)
              _rowSummary(
                title: u.displayName,
                subtitle: u.username == null ? null : '@${u.username}',
                primary: '${u.totalActions} acciones',
              ),
          ],
        ),
        const SizedBox(height: Spacing.lg),
        _sectionCard(
          title: 'Acciones por módulo',
          children: _mapChips(s.actionsByModule),
        ),
        const SizedBox(height: Spacing.lg),
        _sectionCard(
          title: 'Acciones por tipo',
          children: _mapChips(s.actionsByType),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Piezas reutilizables
  // ---------------------------------------------------------------------------
  Widget _groupHeader(String title) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }

  Widget _kpiGrid(List<Widget> cards) {
    final size = context.windowSize;
    final columns = switch (size) {
      WindowSize.compact => 2,
      WindowSize.medium => 3,
      WindowSize.expanded => 4,
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = Spacing.md;
        final itemWidth =
            (constraints.maxWidth - (columns - 1) * gap) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final c in cards) SizedBox(width: itemWidth, child: c),
          ],
        );
      },
    );
  }

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
    String empty = 'Sin datos',
  }) {
    final textTheme = Theme.of(context).textTheme;
    return CustomCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleMedium),
          const Divider(height: Spacing.lg),
          if (children.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
              child: Text(
                empty,
                style: textTheme.bodyMedium?.copyWith(color: secondaryText),
              ),
            )
          else
            ..._separated(children),
        ],
      ),
    );
  }

  /// Fila genérica: título + subtítulo a la izquierda; cifras a la derecha.
  Widget _rowSummary({
    required String title,
    String? subtitle,
    required String primary,
    String? secondary,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        textTheme.labelMedium?.copyWith(color: secondaryText),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                primary,
                style:
                    textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (secondary != null) ...[
                const SizedBox(height: 2),
                Text(
                  secondary,
                  style:
                      textTheme.labelSmall?.copyWith(color: secondaryText),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _observationRow(AttendanceObservation o) {
    final textTheme = Theme.of(context).textTheme;
    final meta = [
      if (o.date != null && o.date!.isNotEmpty) _fmtDate(o.date!),
      if (o.eventName != null && o.eventName!.isNotEmpty) o.eventName!,
      if (o.networkName != null && o.networkName!.isNotEmpty) o.networkName!,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (meta.isNotEmpty)
            Text(
              meta,
              style: textTheme.labelMedium?.copyWith(color: secondaryText),
            ),
          if (o.excerpt != null && o.excerpt!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(o.excerpt!, style: textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }

  Widget _assignmentRow(LeaderEventAssignment e) {
    final textTheme = Theme.of(context).textTheme;
    final meta = [
      if (e.date != null && e.date!.isNotEmpty) _fmtDate(e.date!),
      if (e.eventName != null && e.eventName!.isNotEmpty) e.eventName!,
    ].join(' · ');
    final trailing = [
      if (e.role != null && e.role!.isNotEmpty) e.role!,
      if (e.displayName != null && e.displayName!.isNotEmpty) e.displayName!,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              meta.isEmpty ? '—' : meta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium,
            ),
          ),
          if (trailing.isNotEmpty) ...[
            const SizedBox(width: Spacing.sm),
            Flexible(
              flex: 2,
              child: Text(
                trailing,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: textTheme.labelMedium?.copyWith(color: secondaryText),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniMetric(IconData icon, String label) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: secondaryText),
        const SizedBox(width: 4),
        Text(label, style: textTheme.labelMedium?.copyWith(color: secondaryText)),
      ],
    );
  }

  Widget _detailLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xs),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: secondaryText),
      ),
    );
  }

  List<Widget> _mapChips(Map<String, int> map) {
    if (map.isEmpty) return const [];
    return [
      Wrap(
        spacing: Spacing.sm,
        runSpacing: Spacing.sm,
        children: [
          for (final entry in map.entries)
            AppChip(label: '${_prettyType(entry.key)}: ${entry.value}'),
        ],
      ),
    ];
  }

  Widget _warningPill(String label) {
    return StatusPill(
      label: label,
      background: warningContainer,
      foreground: onWarningContainer,
      icon: Icons.warning_amber_rounded,
    );
  }

  List<Widget> _separated(List<Widget> items) {
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i < items.length - 1) out.add(const Divider(height: 1));
    }
    return out;
  }

  // ---------------------------------------------------------------------------
  // Exportar PDF
  // ---------------------------------------------------------------------------
  Future<void> _exportPdf(ApostolDashboardModel d) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Preparando informe...'),
        duration: Duration(minutes: 1),
      ),
    );

    try {
      final response = await ApiClient().dio.get(
            '/apostol-dashboard/periods/pdf',
            queryParameters: {'start': d.periodStart, 'end': d.periodEnd},
            options: Options(responseType: ResponseType.bytes),
          );

      final fileName = 'Supervision_${d.periodStart}_${d.periodEnd}.pdf';

      if (kIsWeb) {
        WebDownloadHelper.downloadWebFile(response.data, fileName);
      } else {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.data);
        await OpenFilex.open(filePath);
      }

      if (!mounted) return;
      messenger.removeCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('¡Informe generado con éxito!'),
          backgroundColor: successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.removeCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error al generar el informe: $e'),
          backgroundColor: negativeColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}

// ---------------------------------------------------------------------------
// Helpers de formato
// ---------------------------------------------------------------------------
const List<String> _mesesAbbr = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

/// "2026-06-23" o ISO date-time → "23 jun 2026".
String _fmtDate(String value) {
  if (value.isEmpty) return '—';
  final datePart = value.split('T').first;
  final parts = datePart.split('-');
  if (parts.length < 3) return value;
  final year = parts[0];
  final month = int.tryParse(parts[1]) ?? 0;
  final day = int.tryParse(parts[2]) ?? 0;
  if (month < 1 || month > 12) return value;
  return '$day ${_mesesAbbr[month - 1]} $year';
}

String _prettyRole(String role) {
  switch (role) {
    case 'ROLE_APOSTOL':
      return 'Apóstol';
    case 'ROLE_PASTOR':
      return 'Pastor';
    case 'ROLE_LIDER':
      return 'Líder';
    case 'ROLE_SECRETARIO':
      return 'Secretario';
    case 'ROLE_ADMIN':
      return 'Administrador';
  }
  final clean = role.startsWith('ROLE_') ? role.substring(5) : role;
  if (clean.isEmpty) return role;
  return clean[0].toUpperCase() + clean.substring(1).toLowerCase();
}

String _prettyType(String type) {
  if (type.isEmpty) return type;
  return type[0].toUpperCase() + type.substring(1).toLowerCase();
}
