import 'package:flutter/widgets.dart';

/// Clases de tamaño de ventana (inspiradas en los window size classes de
/// Material 3). El umbral de contenido se mantiene en 700 para no regresar los
/// layouts existentes que usaban `width < 700`.
enum WindowSize { compact, medium, expanded }

class Breakpoints {
  Breakpoints._();

  /// Por debajo de este ancho la app es "compacta" (móvil): navegación inferior.
  static const double compact = 700;

  /// A partir de este ancho se muestra el riel de navegación extendido.
  static const double expanded = 1100;

  static WindowSize of(BuildContext context) {
    return fromWidth(MediaQuery.sizeOf(context).width);
  }

  static WindowSize fromWidth(double width) {
    if (width < compact) return WindowSize.compact;
    if (width < expanded) return WindowSize.medium;
    return WindowSize.expanded;
  }
}

extension WindowSizeContext on BuildContext {
  WindowSize get windowSize => Breakpoints.of(this);

  /// Equivalente al histórico `MediaQuery.of(context).size.width < 700`.
  bool get isCompact => windowSize == WindowSize.compact;

  /// `true` en tablets/escritorio (riel de navegación visible).
  bool get isExpanded => windowSize == WindowSize.expanded;
}
