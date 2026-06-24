import 'package:flutter/material.dart';

import '../colors.dart';

/// Píldora de estado que combina color + ícono + texto (nunca solo color),
/// para que el estado sea legible también para usuarios con daltonismo.
class StatusPill extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  const StatusPill({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  /// Estado "Activo" (verde tonal).
  factory StatusPill.active([String label = 'Activo']) => StatusPill(
        label: label,
        background: successContainer,
        foreground: onSuccessContainer,
        icon: Icons.check_circle_rounded,
      );

  /// Estado "Inactivo" (ámbar tonal).
  factory StatusPill.inactive([String label = 'Inactivo']) => StatusPill(
        label: label,
        background: warningContainer,
        foreground: onWarningContainer,
        icon: Icons.pause_circle_filled_rounded,
      );

  /// Estado de error/bloqueo (rojo tonal).
  factory StatusPill.error(String label) => StatusPill(
        label: label,
        background: errorContainerColor,
        foreground: onErrorContainer,
        icon: Icons.error_rounded,
      );

  /// Estado neutro / informativo.
  factory StatusPill.neutral(String label, {IconData? icon}) => StatusPill(
        label: label,
        background: neutralContainer,
        foreground: onNeutralContainer,
        icon: icon,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
