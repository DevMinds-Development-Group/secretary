import 'package:flutter/material.dart';

import '../colors.dart';
import '../theme/design_constants.dart';
import 'custom_card_container.dart';

/// Tarjeta de métrica (KPI): badge de icono + valor + etiqueta.
/// Mismo lenguaje visual que las tarjetas del dashboard de inicio.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color container;
  final Color onContainer;
  final Color? valueColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.container = primaryContainer,
    this.onContainer = onPrimaryContainer,
    this.valueColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final card = CustomCardContainer(
      raised: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: container,
              borderRadius:
                  BorderRadius.circular(DesignConstants.borderRadiusChip),
            ),
            child: Icon(icon, size: 22, color: onContainer),
          ),
          const SizedBox(height: Spacing.md),
          Text(
            value,
            style: textTheme.headlineMedium
                ?.copyWith(color: valueColor ?? primaryText),
          ),
          const SizedBox(height: Spacing.xxs),
          Text(label, style: textTheme.labelMedium),
        ],
      ),
    );

    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(DesignConstants.borderRadiusCard),
      onTap: onTap,
      child: card,
    );
  }
}
