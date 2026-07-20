import 'package:flutter/material.dart';

import '../colors.dart';
import '../models/member_model.dart';
import '../theme/design_constants.dart';
import '../utils/window_size.dart';
import 'action_buttons.dart';
import 'member_list_tile.dart';
import 'status_pill.dart';

/// Tabla de miembros reutilizable (estilo pantalla Miembros): contenedor con
/// borde + fila de encabezado + filas con avatar cuadrado, teléfono, pastilla
/// de estado y acciones editar/eliminar (iconos en web, menú `⋮` en móvil).
///
/// Debe colocarse dentro de un `Expanded`/altura acotada: rellena la altura.
class MemberTable extends StatelessWidget {
  final List<Member> members;
  final void Function(Member) onEdit;
  final void Function(Member) onDelete;

  /// Si se provee, muestra la acción "Ver perfil" antes de editar/eliminar.
  final void Function(Member)? onView;

  /// Muestra la columna "Red" (útil en la pantalla global; redúndate dentro de
  /// una sola red).
  final bool showNetworkColumn;

  /// Si se provee, envuelve la lista en un `RefreshIndicator`.
  final Future<void> Function()? onRefresh;

  const MemberTable({
    super.key,
    required this.members,
    required this.onEdit,
    required this.onDelete,
    this.onView,
    this.showNetworkColumn = true,
    this.onRefresh,
  });

  static const double _statusColWidth = 100;
  double get _actionsColWidth => onView != null ? 144 : 96;

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;

    final list = ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: members.length,
      itemBuilder: (_, i) => _buildMemberRow(context, members[i], isCompact),
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(DesignConstants.borderRadiusCard),
        border: Border.all(color: alternateColor, width: 1),
      ),
      child: Column(
        children: [
          _buildHeaderRow(context, isCompact),
          Expanded(
            child: onRefresh != null
                ? RefreshIndicator(onRefresh: onRefresh!, child: list)
                : list,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, bool isCompact) {
    final labelStyle = Theme.of(context)
        .textTheme
        .labelMedium
        ?.copyWith(color: secondaryText, fontWeight: FontWeight.w600);

    return Container(
      color: surfaceSubtle,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.md,
      ),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text('Nombre', style: labelStyle)),
          if (!isCompact && showNetworkColumn)
            Expanded(flex: 2, child: Text('Red', style: labelStyle)),
          SizedBox(
            width: _statusColWidth,
            child: Text('Estado', style: labelStyle),
          ),
          if (!isCompact) SizedBox(width: _actionsColWidth),
          if (isCompact) const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildMemberRow(BuildContext context, Member member, bool isCompact) {
    final statusPill =
        member.enabled ? StatusPill.active() : StatusPill.inactive();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: MemberListTile(
              member: member,
              subtitle: memberPhoneSubtitle(member),
              padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
            ),
          ),
          if (!isCompact && showNetworkColumn)
            Expanded(
              flex: 2,
              child: Text(
                member.networkName ?? 'Sin red',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: secondaryText),
              ),
            ),
          SizedBox(
            width: _statusColWidth,
            child: Align(alignment: Alignment.centerLeft, child: statusPill),
          ),
          if (!isCompact)
            SizedBox(
              width: _actionsColWidth,
              child: ActionButtons(
                onView: onView == null ? null : () => onView!(member),
                onEdit: () => onEdit(member),
                onDelete: () => onDelete(member),
              ),
            )
          else
            _buildRowMenu(member),
        ],
      ),
    );
  }

  Widget _buildRowMenu(Member member) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: secondaryText),
      onSelected: (value) {
        if (value == 'view') {
          onView?.call(member);
        } else if (value == 'edit') {
          onEdit(member);
        } else if (value == 'delete') {
          onDelete(member);
        }
      },
      itemBuilder: (_) => [
        if (onView != null)
          const PopupMenuItem(value: 'view', child: Text('Ver perfil')),
        const PopupMenuItem(value: 'edit', child: Text('Editar')),
        const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
      ],
    );
  }
}
