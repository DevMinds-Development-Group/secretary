import 'package:flutter/material.dart';

import '../../colors.dart';
import '../../theme/design_constants.dart';

/// Estado vacío reutilizable: ícono + título + mensaje + CTA opcional.
///
/// Distingue "sin datos" (con CTA, p. ej. "Agregar primer miembro") de
/// "sin resultados" de un filtro/búsqueda (usar [EmptyState.filtered]).
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  /// Variante para resultados de búsqueda/filtro vacíos (sin CTA de creación).
  factory EmptyState.filtered({
    Key? key,
    String title = 'Sin resultados',
    String message = 'No encontramos coincidencias para tu búsqueda.',
    Widget? action,
  }) {
    return EmptyState(
      key: key,
      icon: Icons.search_off_rounded,
      title: title,
      message: message,
      action: action,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: onPrimaryContainer),
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge,
            ),
            if (message != null) ...[
              const SizedBox(height: Spacing.sm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: secondaryText),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: Spacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
