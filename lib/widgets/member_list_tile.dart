import 'package:flutter/material.dart';

import '../colors.dart';
import '../models/member_model.dart';
import '../theme/design_constants.dart';
import 'member_profile_image.dart';

/// Fila reutilizable de miembro: avatar cuadrado con borde + nombre (negrita)
/// + subtítulo opcional + trailing opcional (pastilla de estado, acciones,
/// checkbox…). Unidad común usada en todas las pantallas que listan miembros.
class MemberListTile extends StatelessWidget {
  final Member member;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double avatarRadius;

  const MemberListTile({
    super.key,
    required this.member,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(
      horizontal: Spacing.sm,
      vertical: Spacing.md,
    ),
    this.avatarRadius = 22,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final row = Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MemberProfileImage(
            imageUrl: member.photoUrl,
            name: member.name,
            radius: avatarRadius,
            squared: true,
            borderColor: primaryColor,
            borderWidth: 2,
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  member.fullName,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  DefaultTextStyle.merge(
                    style: textTheme.bodySmall ?? const TextStyle(),
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: Spacing.sm),
            trailing!,
          ],
        ],
      ),
    );

    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignConstants.borderRadiusCard),
      child: row,
    );
  }
}

/// Subtítulo estándar = teléfono en azul (análogo al email-link de la
/// referencia), o "Sin teléfono" en gris si está vacío.
Widget memberPhoneSubtitle(Member member) {
  final hasPhone = member.phone.trim().isNotEmpty;
  return Text(
    hasPhone ? member.phone : 'Sin teléfono',
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      color: hasPhone ? primaryColor : secondaryText,
      fontWeight: FontWeight.w500,
      fontSize: 13,
    ),
  );
}
