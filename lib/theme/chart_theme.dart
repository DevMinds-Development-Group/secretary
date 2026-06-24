import 'package:flutter/material.dart';

import '../colors.dart';

/// Paleta y estilos para gráficos (fl_chart), mapeados a los tokens del
/// sistema de diseño para mantener coherencia visual.
class ChartTheme {
  ChartTheme._();

  /// Paleta categórica en orden estable para series de datos.
  static const List<Color> categorical = [
    primaryColor,
    accentColor,
    tertiaryColor,
    warningColor,
    errorColor,
    Color(0xFF8B5CF6), // violeta de apoyo
  ];

  /// Color para una categoría por índice (cicla si se excede).
  static Color colorAt(int index) => categorical[index % categorical.length];

  /// Color de líneas de grilla/ejes.
  static const Color grid = alternateColor;

  /// Estilo de texto para etiquetas de ejes/leyendas.
  static const TextStyle axisLabel = TextStyle(
    color: secondaryText,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  /// Fondo de tooltips.
  static const Color tooltipBackground = primaryText;
  static const Color tooltipText = infoColor;
}
