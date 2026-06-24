import 'package:flutter/material.dart';

import '../colors.dart';
import '../theme/design_constants.dart';

/// Agrupa campos de un formulario bajo un encabezado, para reducir la carga
/// cognitiva en formularios largos (p. ej. crear miembro / servicio).
class FormSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget> children;

  const FormSection({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: primaryColor),
              const SizedBox(width: Spacing.sm),
            ],
            Text(title, style: textTheme.titleMedium),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: Spacing.xxs),
          Text(
            subtitle!,
            style: textTheme.labelMedium?.copyWith(color: secondaryText),
          ),
        ],
        const SizedBox(height: Spacing.md),
        ...children,
      ],
    );
  }
}
