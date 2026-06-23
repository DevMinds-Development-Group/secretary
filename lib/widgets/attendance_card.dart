import 'package:flutter/material.dart';

import '../colors.dart';
import '../models/attendance_model.dart';
import '../theme/design_constants.dart';

/// Tarjeta de fecha de asistencia (estilo Asistencia): día grande + evento +
/// fecha + desglose + pastilla de total, con resaltado para "hoy" y un menú `⋮`
/// que muestra solo las acciones provistas. Compartida por Asistencia y
/// Reportes Generales.
class AttendanceCard extends StatelessWidget {
  final AttendanceModel record;
  final bool isToday;
  final VoidCallback? onTap;
  final VoidCallback? onPdf;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  /// Muestra el número de día grande a la izquierda.
  final bool showLeadingDay;

  /// Muestra la línea de desglose ("X miembros · Y visitas · Red").
  final bool showDetails;

  /// Renderiza las acciones como botones de icono directos en lugar del menú `⋮`.
  final bool directActions;

  /// Muestra la pastilla con el total de asistentes.
  final bool showCountPill;

  const AttendanceCard({
    super.key,
    required this.record,
    this.isToday = false,
    this.onTap,
    this.onPdf,
    this.onEdit,
    this.onDelete,
    this.showLeadingDay = true,
    this.showDetails = true,
    this.directActions = false,
    this.showCountPill = true,
  });

  bool get _hasMenu =>
      onTap != null || onPdf != null || onEdit != null || onDelete != null;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final present = record.presentMemberIds.length;
    final visitors = record.visitorsCount;
    final total = present + visitors;

    final fg = isToday ? infoColor : primaryText;
    final fgMuted = isToday ? infoColor.withOpacity(0.85) : secondaryText;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignConstants.borderRadiusCard),
        child: Container(
          padding: const EdgeInsets.all(Spacing.lg),
          decoration: BoxDecoration(
            color: isToday ? primaryColor : secondaryBackground,
            borderRadius:
                BorderRadius.circular(DesignConstants.borderRadiusCard),
            border: Border.all(
              color: isToday ? primaryColor : alternateColor,
              width: 1,
            ),
            boxShadow: elevationLow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showLeadingDay) ...[
                SizedBox(
                  width: 48,
                  child: Text(
                    '${record.date.day}',
                    textAlign: TextAlign.center,
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isToday ? infoColor : primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      record.definitionName ?? 'Evento sin nombre',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600, color: fg),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_weekday(record.date)}, ${record.date.day} ${_month(record.date)} ${record.date.year}',
                      style: textTheme.labelMedium?.copyWith(color: fgMuted),
                    ),
                    if (showDetails) ...[
                      const SizedBox(height: 2),
                      Text(
                        '$present miembros · $visitors visitas · ${record.networkName ?? 'Sin red'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(color: fgMuted),
                      ),
                    ],
                  ],
                ),
              ),
              if (showCountPill) ...[
                const SizedBox(width: Spacing.sm),
                _countPill(total),
              ],
              if (directActions)
                ..._directActions()
              else if (_hasMenu)
                _menu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _countPill(int total) {
    final bg = isToday ? infoColor : primaryContainer;
    final fg = isToday ? primaryColor : onPrimaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$total',
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 15),
      ),
    );
  }

  List<Widget> _directActions() {
    return [
      if (onPdf != null)
        IconButton(
          tooltip: 'Descargar PDF',
          icon: Icon(
            Icons.download_rounded,
            color: isToday ? infoColor : primaryColor,
          ),
          onPressed: onPdf,
        ),
      if (onEdit != null)
        IconButton(
          tooltip: 'Editar',
          icon: Icon(
            Icons.edit_outlined,
            color: isToday ? infoColor : secondaryText,
          ),
          onPressed: onEdit,
        ),
      if (onDelete != null)
        IconButton(
          tooltip: 'Eliminar',
          icon: Icon(
            Icons.delete_outline,
            color: isToday ? infoColor : errorColor,
          ),
          onPressed: onDelete,
        ),
    ];
  }

  Widget _menu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: isToday ? infoColor : secondaryText),
      onSelected: (value) {
        switch (value) {
          case 'details':
            onTap?.call();
            break;
          case 'pdf':
            onPdf?.call();
            break;
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (_) => [
        if (onTap != null)
          const PopupMenuItem(value: 'details', child: Text('Ver detalle')),
        if (onPdf != null)
          const PopupMenuItem(value: 'pdf', child: Text('Descargar PDF')),
        if (onEdit != null)
          const PopupMenuItem(value: 'edit', child: Text('Editar')),
        if (onDelete != null)
          const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
      ],
    );
  }
}

const List<String> _weekdays = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

const List<String> _months = [
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

String _weekday(DateTime d) => _weekdays[d.weekday - 1];
String _month(DateTime d) => _months[d.month - 1];
