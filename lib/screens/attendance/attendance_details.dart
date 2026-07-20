import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/attendance_model.dart';
import '../../models/member_model.dart';
import '../../providers/member_provider.dart';
import '../../theme/design_constants.dart';
import '../../utils/window_size.dart';
import '../../widgets/body_width.dart';
import '../../widgets/fluid_background.dart';
import '../../widgets/member_list_tile.dart';
import '../../widgets/nav_shell.dart';

const Color _dateRed = Color(0xFFEF4444);
const Color _dateRedSoft = Color(0xFFFEF2F2);
const Color _purple = Color(0xFF8B5CF6);
const Color _purpleSoft = Color(0xFFF3E8FF);

class AttendanceDetail extends StatelessWidget {
  final AttendanceModel record;

  const AttendanceDetail({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;
    final present = _resolvePresentMembers(context);

    return NavShell(
      isSecondary: true,
      title: 'Detalles de Asistencia',
      body: FluidBackground(
        showDots: true,
        child: SingleChildScrollView(
          child: BodyWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: Spacing.lg),
                _buildReporteBadge(),
                const SizedBox(height: Spacing.lg),
                _buildEventCard(isCompact),
                const SizedBox(height: Spacing.xl),
                _buildStatsGrid(isCompact),
                const SizedBox(height: Spacing.xl),
                _buildMembersSection(present),
                const SizedBox(height: Spacing.xxxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Fuente de verdad: los miembros embebidos en el registro (proyección
  /// histórica del backend). Se enriquecen con la foto/datos de
  /// `MemberProvider.allMembers` cuando está disponible, sin depender de él
  /// para mostrar la lista (esto arregla el bug de la lista intermitente).
  List<Member> _resolvePresentMembers(BuildContext context) {
    final all = context.watch<MemberProvider>().allMembers;

    if (record.presentMembers.isNotEmpty) {
      return record.presentMembers.map((snapshot) {
        final match = all.where((m) => m.id == snapshot.id);
        return match.isNotEmpty ? match.first : snapshot;
      }).toList();
    }

    // Respaldo (registros antiguos sin objetos embebidos): join por id.
    return all.where((m) => record.presentMemberIds.contains(m.id)).toList();
  }

  Widget _buildReporteBadge() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Text(
          'REPORTE GENERADO',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: tertiaryTextColor,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tarjeta de evento
  // ---------------------------------------------------------------------------
  Widget _buildEventCard(bool isCompact) {
    final kicker = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.groups_rounded, size: 18, color: primaryColor),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            (record.networkName ?? 'Sin red').toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: primaryColor,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );

    final title = Text(
      record.definitionName ?? 'Evento',
      style: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: primaryText,
        height: 1.1,
      ),
    );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        kicker,
        const SizedBox(height: Spacing.sm),
        title,
      ],
    );

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(56),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(56),
      ),
      child: Container(
        decoration: glassDecoration(
          const BorderRadius.only(
            topLeft: Radius.circular(56),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(56),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: primaryContainer.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Spacing.xl),
              child: isCompact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        info,
                        const SizedBox(height: Spacing.lg),
                        _buildDatePill(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: info),
                        const SizedBox(width: Spacing.lg),
                        _buildDatePill(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePill() {
    final formatted =
        DateFormat('EEEE, d MMMM yyyy', 'es').format(record.date);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: _dateRedSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _dateRed.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_rounded, size: 16, color: _dateRed),
          const SizedBox(width: 8),
          Text(
            formatted,
            style: const TextStyle(
              color: _dateRed,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Grid de estadísticas
  // ---------------------------------------------------------------------------
  Widget _buildStatsGrid(bool isCompact) {
    final total = record.presentMemberIds.length + record.visitorsCount;

    final miembros = _statCard(
      value: record.presentMemberIds.length.toString(),
      label: 'MIEMBROS',
      icon: Icons.how_to_reg_rounded,
      container: primaryContainer,
      onContainer: primaryColor,
    );
    final visitas = _statCard(
      value: record.visitorsCount.toString(),
      label: 'VISITAS',
      icon: Icons.waving_hand_rounded,
      container: _purpleSoft,
      onContainer: _purple,
    );
    final nuevos = _statCard(
      value: record.newConvert.toString(),
      label: 'NUEVOS CONV.',
      icon: Icons.star_rounded,
      container: warningContainer,
      onContainer: onWarningContainer,
    );
    final pastorales = _statCard(
      value: record.pastoralVisitsCount.toString(),
      label: 'V. PASTORALES',
      icon: Icons.home_rounded,
      container: successContainer,
      onContainer: onSuccessContainer,
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _totalCard(total),
          const SizedBox(height: Spacing.md),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: miembros),
                const SizedBox(width: Spacing.md),
                Expanded(child: visitas),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: nuevos),
                const SizedBox(width: Spacing.md),
                Expanded(child: pastorales),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: _totalCard(total)),
              const SizedBox(width: Spacing.lg),
              Expanded(child: miembros),
              const SizedBox(width: Spacing.lg),
              Expanded(child: visitas),
            ],
          ),
        ),
        const SizedBox(height: Spacing.lg),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: nuevos),
              const SizedBox(width: Spacing.lg),
              Expanded(child: pastorales),
              const SizedBox(width: Spacing.lg),
              const Expanded(flex: 2, child: SizedBox()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _totalCard(int total) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(Spacing.xl),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, Color(0xFF2563EB)],
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -18,
              bottom: -24,
              child: Icon(
                Icons.pie_chart_rounded,
                size: 130,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TOTAL DE ASISTENTES',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  total.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required String value,
    required String label,
    required IconData icon,
    required Color container,
    required Color onContainer,
  }) {
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: glassDecoration(BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: container,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: onContainer, size: 24),
          ),
          const SizedBox(height: Spacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: primaryText,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: secondaryText.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Miembros presentes
  // ---------------------------------------------------------------------------
  Widget _buildMembersSection(List<Member> present) {
    if (present.isEmpty) return _buildEmptyState();

    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: glassDecoration(BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: Spacing.xs, bottom: Spacing.sm),
            child: Text(
              'MIEMBROS PRESENTES · ${present.length}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: secondaryText.withOpacity(0.8),
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: present.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => MemberListTile(
              member: present[i],
              subtitle: memberPhoneSubtitle(present[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xl,
        vertical: Spacing.xxxl,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: alternateColor),
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: alternateColor),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.group_off_rounded,
                size: 44, color: secondaryText.withOpacity(0.4)),
          ),
          const SizedBox(height: Spacing.lg),
          const Text(
            'Lista de Registro Vacía',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: primaryText,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'No se registraron miembros presentes de manera individual para este servicio.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: secondaryText, height: 1.4),
          ),
        ],
      ),
    );
  }
}
