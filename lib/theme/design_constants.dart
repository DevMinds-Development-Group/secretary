import 'package:flutter/material.dart';

import '../colors.dart';

/// Constantes de diseño del sistema "FF Expandable-Menu" (ver design.md §6).
class DesignConstants {
  DesignConstants._();

  // Border Radius
  static const double borderRadiusButton = 12.0;
  static const double borderRadiusInput = 12.0;
  static const double borderRadiusCard = 12.0;
  static const double borderRadiusDropdown = 12.0;
  static const double borderRadiusChip = 12.0;

  // Button Heights
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 44.0;
  static const double buttonHeightLarge = 48.0;

  // Button Padding (horizontal)
  static const double buttonPaddingSmall = 16.0;
  static const double buttonPaddingMedium = 24.0;
  static const double buttonPaddingLarge = 44.0;

  // Input Padding
  static const double inputPaddingHorizontal = 20.0;
  static const double inputPaddingVertical = 14.0;

  // Container Padding
  static const double containerPaddingHorizontal = 16.0;

  // Border Width
  static const double borderWidthDefault = 2.0;
  static const double borderWidthCard = 1.0;

  // Elevation
  static const double elevationButton = 1.0;
  static const double elevationDropdown = 2.0;
  static const double elevationChipSelected = 4.0;

  // Card Max Width
  static const double cardMaxWidth = 770.0;

  // Chip Spacing
  static const double chipSpacing = 8.0;

  // Loading Indicator
  static const double loadingIndicatorSize = 50.0;

  // Animation
  static const Duration animationDuration = Duration(milliseconds: 100);
}

/// Escala de espaciado base 4/8. Reemplaza los valores ad-hoc (10/15/18/20/24).
class Spacing {
  Spacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16; // padding interno estándar de card / list-item
  static const double xl = 24; // padding horizontal (web), gap de sección
  static const double xxl = 32;
  static const double xxxl = 40; // respiro al final del scroll
}

// ============================================================================
// SISTEMA DE ELEVACIÓN — 3 niveles
//   L0: plano + borde hairline (sin sombra)  → contenedores de contenido
//   L1: borde + sombra suave                 → cards interactivas/realzadas
//   L2: solo sombra, mayor blur              → diálogos, menús, popovers
// ============================================================================

/// Nivel 1 — sombra suave (reemplaza la antigua cardShadow pesada).
const List<BoxShadow> elevationLow = [
  BoxShadow(color: Color(0x0F101828), blurRadius: 2, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x14101828), blurRadius: 6, offset: Offset(0, 2)),
];

/// Nivel 2 — diálogos / menús / popovers.
const List<BoxShadow> elevationHigh = [
  BoxShadow(color: Color(0x1F101828), blurRadius: 16, offset: Offset(0, 8)),
];

/// Alias histórico (Elevation 1) — ahora con sombra suave. Preferir
/// [elevationLow] en código nuevo.
const BoxShadow cardShadow = BoxShadow(
  color: shadowColor,
  blurRadius: 6,
  offset: Offset(0, 2),
);

/// Alias histórico (Elevation 2). Preferir [elevationHigh] en código nuevo.
const BoxShadow cardShadowElevated = BoxShadow(
  color: shadowColor,
  blurRadius: 16,
  offset: Offset(0, 8),
);
