import 'package:flutter/material.dart';

import '../colors.dart';
import '../theme/design_constants.dart';
import 'app_chip.dart';

/// Estilo visual por tipo de evento.
class _EventTypeStyle {
  final Color color;
  final Color container;
  final IconData icon;
  final String label;
  const _EventTypeStyle(this.color, this.container, this.icon, this.label);
}

_EventTypeStyle _styleFor(String type) {
  switch (type) {
    case 'CULTO':
      return const _EventTypeStyle(
        primaryColor,
        primaryContainer,
        Icons.church_rounded,
        'Culto',
      );
    case 'REUNION':
      return const _EventTypeStyle(
        accentColor,
        successContainer,
        Icons.groups_rounded,
        'Reunión',
      );
    default:
      return const _EventTypeStyle(
        warningColor,
        warningContainer,
        Icons.event_rounded,
        'Otro',
      );
  }
}

/// Ítem de feed para un evento/servicio, al estilo de un timeline de
/// notificaciones: avatar cuadrado con borde por tipo + título coloreado +
/// tarjeta anidada (etiqueta de tipo + título + descripción citada + chips) +
/// línea de horario. Los eventos de "hoy" se resaltan.
///
/// Es agnóstico de la fuente de datos: el llamador arma los strings, de modo
/// que puede usarse con `ServiceModel` (pantalla Servicios) o `WeeklyEvent`
/// (dashboard).
class EventFeedItem extends StatelessWidget {
  final String title;
  final String type;
  final String? description;
  final String scheduleLabel;
  final List<String> preacherNames;
  final List<String> worshipNames;
  final bool isToday;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EventFeedItem({
    super.key,
    required this.title,
    required this.type,
    required this.scheduleLabel,
    this.description,
    this.preacherNames = const [],
    this.worshipNames = const [],
    this.isToday = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  bool get _hasActions => onEdit != null || onDelete != null;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = _styleFor(type);

    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _typeAvatar(style),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _titleLine(context, style, textTheme),
                const SizedBox(height: Spacing.sm),
                _nestedCard(context, style, textTheme),
                const SizedBox(height: Spacing.sm),
                Text(
                  scheduleLabel,
                  style: textTheme.labelMedium?.copyWith(color: secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignConstants.borderRadiusCard),
      child: content,
    );
  }

  Widget _typeAvatar(_EventTypeStyle style) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: style.container,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: style.color, width: 1.5),
      ),
      child: Icon(style.icon, color: style.color, size: 22),
    );
  }

  Widget _titleLine(
    BuildContext context,
    _EventTypeStyle style,
    TextTheme textTheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              color: style.color,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isToday) ...[
          const SizedBox(width: Spacing.sm),
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: style.color,
              shape: BoxShape.circle,
            ),
          ),
        ],
        if (_hasActions)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: secondaryText),
            onSelected: (value) {
              if (value == 'edit') onEdit?.call();
              if (value == 'delete') onDelete?.call();
            },
            itemBuilder: (_) => [
              if (onEdit != null)
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
              if (onDelete != null)
                const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
            ],
          ),
      ],
    );
  }

  Widget _nestedCard(
    BuildContext context,
    _EventTypeStyle style,
    TextTheme textTheme,
  ) {
    final desc = description?.trim() ?? '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: isToday ? style.container : surfaceSubtle,
        borderRadius: BorderRadius.circular(DesignConstants.borderRadiusCard),
        border: Border.all(
          color: isToday ? style.color : alternateColor,
          width: isToday ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            style.label.toUpperCase(),
            style: TextStyle(
              color: style.color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            title,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (desc.isNotEmpty) ...[
            const SizedBox(height: Spacing.xs),
            Text(
              '"$desc"',
              style: textTheme.bodySmall?.copyWith(
                color: secondaryText,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (preacherNames.isNotEmpty)
            _chipRow(context, 'Predica:', preacherNames),
          if (worshipNames.isNotEmpty)
            _chipRow(context, 'Ministra:', worshipNames),
        ],
      ),
    );
  }

  Widget _chipRow(BuildContext context, String label, List<String> names) {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.sm),
      child: Wrap(
        spacing: Spacing.sm,
        runSpacing: Spacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: secondaryText,
                  fontWeight: FontWeight.w600,
                ),
          ),
          for (final name in names) AppChip(label: name),
        ],
      ),
    );
  }
}
