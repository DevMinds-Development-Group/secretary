import 'package:flutter/material.dart';

import '../colors.dart';
import '../theme/design_constants.dart';

/// Chip tonal consistente para etiquetas (líderes, predicadores, etc.).
/// Usa el contenedor tonal primario; sin borde grueso. Reemplaza los `Chip`
/// con estilos en línea dispersos por las pantallas.
class AppChip extends StatelessWidget {
  final String label;
  final Widget? avatar;
  final IconData? icon;

  const AppChip({super.key, required this.label, this.avatar, this.icon});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: avatar ??
          (icon != null
              ? Icon(icon, size: 16, color: onPrimaryContainer)
              : null),
      label: Text(label),
      labelStyle: const TextStyle(
        color: onPrimaryContainer,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: primaryContainer,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignConstants.borderRadiusChip),
      ),
    );
  }
}

/// Filter chip seleccionable (para filtros/segmentación).
class AppFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      avatar: icon != null ? Icon(icon, size: 16) : null,
      showCheckmark: true,
      backgroundColor: surfaceSubtle,
      selectedColor: primaryContainer,
      side: BorderSide(color: selected ? primaryContainer : alternateColor),
      labelStyle: TextStyle(
        color: selected ? onPrimaryContainer : secondaryText,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignConstants.borderRadiusChip),
      ),
    );
  }
}
