import 'package:flutter/material.dart';

import '../theme/design_constants.dart';
import '../utils/window_size.dart';

/// Regla de ancho de contenido responsiva.
///
/// - En web (no compacto): centra el contenido al [factor] (90% por defecto)
///   del ancho del cuerpo de la app (el área a la derecha del riel), dejando
///   ~5% de margen a cada lado. Reemplaza los topes fijos de `maxWidth`.
/// - En móvil ([context.isCompact]): ancho completo con un padding horizontal
///   estándar ([compactPadding]).
///
/// `Center(ConstrainedBox(maxWidth))` se ajusta en altura tanto dentro de un
/// `Expanded` (listas) como de un `SingleChildScrollView` (dashboard).
class BodyWidth extends StatelessWidget {
  final Widget child;
  final double factor;
  final double compactPadding;

  const BodyWidth({
    super.key,
    required this.child,
    this.factor = 0.9,
    this.compactPadding = Spacing.lg,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isCompact) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: compactPadding),
        child: child,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth) return child;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * factor),
            child: child,
          ),
        );
      },
    );
  }
}
