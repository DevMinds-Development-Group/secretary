import 'package:flutter/material.dart';

import '../colors.dart';

/// Tokens tipográficos del sistema de diseño (ver design.md §2).
///
/// Figtree → display / headline.
/// Plus Jakarta Sans → title / body / label.
class AppTypography {
  AppTypography._();

  static const String fontDisplay = 'Figtree';
  static const String fontBody = 'Plus Jakarta Sans';

  /// [TextTheme] completo del modo claro (la app es solo light).
  static TextTheme get textTheme {
    const Color textPrimary = primaryText;
    const Color textSecondary = secondaryText;

    return TextTheme(
      // Display (Figtree)
      displayLarge: TextStyle(
        fontFamily: fontDisplay,
        fontSize: 48,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      ),
      displayMedium: TextStyle(
        fontFamily: fontDisplay,
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      displaySmall: TextStyle(
        fontFamily: fontDisplay,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      // Headline (Figtree)
      headlineLarge: TextStyle(
        fontFamily: fontDisplay,
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontDisplay,
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontDisplay,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      // Title (Plus Jakarta Sans)
      titleLarge: TextStyle(
        fontFamily: fontBody,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontFamily: fontBody,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      titleSmall: TextStyle(
        fontFamily: fontBody,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      // Body (Plus Jakarta Sans)
      bodyLarge: TextStyle(
        fontFamily: fontBody,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontBody,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      bodySmall: TextStyle(
        fontFamily: fontBody,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      // Label (Plus Jakarta Sans)
      labelLarge: TextStyle(
        fontFamily: fontBody,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      labelMedium: TextStyle(
        fontFamily: fontBody,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      labelSmall: TextStyle(
        fontFamily: fontBody,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
    );
  }
}
