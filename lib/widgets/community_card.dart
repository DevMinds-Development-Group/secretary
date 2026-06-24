import 'package:flutter/material.dart';

import '../colors.dart';
import '../models/member_model.dart';
import '../theme/design_constants.dart';
import 'member_profile_image.dart';

/// Par de colores tonales (fondo, texto/acento) para el acento de la card.
class _CardTone {
  final Color bg;
  final Color on;
  const _CardTone(this.bg, this.on);
}

const List<_CardTone> _palette = [
  _CardTone(primaryContainer, onPrimaryContainer),
  _CardTone(successContainer, onSuccessContainer),
  _CardTone(warningContainer, onWarningContainer),
  _CardTone(errorContainerColor, onErrorContainer),
  _CardTone(Color(0xFFEDE9FE), Color(0xFF6D28D9)), // morado tonal
];

/// Card estilo "evento" para Redes/Ministerios: card blanca con acento de color
/// (ciclado por [colorIndex]) — ícono tonal a la izquierda, título + menú `⋮` en
/// la misma línea, bloque de descripción tonal, y una fila inferior con el
/// conteo de miembros + una pila de avatares de los líderes.
class CommunityCard extends StatelessWidget {
  final String title;
  final String? description;
  final int memberCount;
  final List<Member> leaders;
  final int colorIndex;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CommunityCard({
    super.key,
    required this.title,
    required this.memberCount,
    required this.leaders,
    required this.colorIndex,
    required this.icon,
    this.description,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  bool get _hasMenu => onEdit != null || onDelete != null;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tone = _palette[colorIndex % _palette.length];
    final desc = description?.trim() ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(Spacing.lg),
          decoration: BoxDecoration(
            color: secondaryBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: alternateColor, width: 1),
            boxShadow: elevationLow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _icon(tone),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _titleLine(textTheme, tone),
                    if (desc.isNotEmpty) ...[
                      const SizedBox(height: Spacing.sm),
                      _descriptionBlock(textTheme, tone, desc),
                    ],
                    const SizedBox(height: Spacing.md),
                    _metaLine(textTheme, tone),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icon(_CardTone tone) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: tone.bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: tone.on, size: 22),
    );
  }

  Widget _titleLine(TextTheme textTheme, _CardTone tone) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: tone.on,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (_hasMenu)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: secondaryText),
            onSelected: (v) {
              if (v == 'edit') onEdit?.call();
              if (v == 'delete') onDelete?.call();
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

  Widget _descriptionBlock(TextTheme textTheme, _CardTone tone, String desc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        //color: tone.bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        desc,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodyMedium?.copyWith(color: tone.on.withOpacity(0.85)),
      ),
    );
  }

  Widget _metaLine(TextTheme textTheme, _CardTone tone) {
    return Row(
      children: [
        Text(
          '$memberCount miembros',
          style: textTheme.labelLarge
              ?.copyWith(color: tone.on, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        _LeaderStack(leaders: leaders, tone: tone),
      ],
    );
  }
}

/// Pila de avatares de líderes superpuestos (hasta 4, luego "+N").
class _LeaderStack extends StatelessWidget {
  final List<Member> leaders;
  final _CardTone tone;

  const _LeaderStack({required this.leaders, required this.tone});

  static const double _avatar = 24; // radio (más grande)
  static const double _ring = 2;
  static const double _size = _avatar * 2 + _ring * 2;
  static const double _step = 34;

  @override
  Widget build(BuildContext context) {
    if (leaders.isEmpty) {
      return _ringed(
        child: CircleAvatar(
          radius: _avatar,
          backgroundColor: tone.bg,
          child: Icon(Icons.groups_rounded, color: tone.on, size: 24),
        ),
      );
    }

    final maxShown = leaders.length > 4 ? 3 : leaders.length;
    final extra = leaders.length - maxShown;
    final items = <Widget>[];

    for (var i = 0; i < maxShown; i++) {
      final m = leaders[i];
      items.add(
        Positioned(
          left: i * _step,
          child: _ringed(
            child: MemberProfileImage(
              imageUrl: m.photoUrl,
              name: m.name,
              radius: _avatar,
            ),
          ),
        ),
      );
    }
    if (extra > 0) {
      items.add(
        Positioned(
          left: maxShown * _step,
          child: _ringed(
            child: CircleAvatar(
              radius: _avatar,
              backgroundColor: tone.on,
              child: Text(
                '+$extra',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final count = maxShown + (extra > 0 ? 1 : 0);
    final width = _size + (count - 1) * _step;
    return SizedBox(
      width: width,
      height: _size,
      child: Stack(clipBehavior: Clip.none, children: items),
    );
  }

  Widget _ringed({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(_ring),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}
