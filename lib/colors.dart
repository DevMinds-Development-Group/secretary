import 'package:flutter/material.dart';

// ============================================================================
// DESIGN SYSTEM PALETTE — "FF Expandable-Menu" (ver design.md)
// ----------------------------------------------------------------------------
// Los nombres de constantes históricos se conservan para no romper los ~40
// archivos que los importan; solo cambian sus valores hacia la nueva paleta.
// La app es solo MODO CLARO. Para colores que vienen del tema, prefiera
// leer Theme.of(context).colorScheme.*.
// ============================================================================

// --- Marca / acentos principales ---
const Color primaryColor = Color(0xFF0F77FF); // Primary (marca)
const Color secondaryColor = Color(0xFF4A5159); // neutro (== secondaryText)
const Color tertiaryColor = Color(0xFFFFB560); // Tertiary
const Color accentColor = Color(0xFF27C880); // Secondary (verde)

// --- Estados ---
const Color successColor = Color(0xFF03CE9F);
const Color warningColor = Color(0xFFF9A33F);
const Color errorColor = Color(0xFFFF4D6A);
const Color negativeColor = Color(0xFFFF4D6A); // Error (alias histórico)
const Color primaryColor2 = Color(0xFFFF4D6A); // Error (alias histórico)
const Color primaryColor3 = Color(0xFFFF4D6A); // Error (alias histórico)

// --- Fondos y superficies (light) ---
const Color backgroundColor = Color(0xFFF7F8FA); // Lienzo de la app (calmado)
const Color secondaryBackground = Color(0xFFFFFFFF); // Superficie / cards
const Color cardColor = Color(0xFFFFFFFF); // Cards
const Color surfaceSubtle =
    Color(0xFFF0F2F5); // Filas zebra / hover / chip inactivo

// --- Texto y UI (light) ---
const Color primaryText = Color(0xFF1A1D21); // ~16:1 sobre blanco
const Color secondaryText = Color(0xFF4A5159); // ~7.4:1 (AAA texto pequeño)
const Color tertiaryTextColor = Color(0xFF6B727B); // hint/placeholder (~5:1)
const Color darkColor = Color(0xFF1A1D21); // Primary Text (alias histórico)
const Color alternateColor = Color(0xFFE6E8EC); // Bordes / divisores (hairline)
const Color infoColor = Color(0xFFFFFFFF); // Texto sobre color

// --- Contenedores tonales (chips, badges, estados seleccionados) ---
const Color primaryContainer = Color(0xFFE3EEFF);
const Color onPrimaryContainer = Color(0xFF0A4FB5);
const Color successContainer = Color(0xFFDCF7EF);
const Color onSuccessContainer = Color(0xFF0A7A5E);
const Color warningContainer = Color(0xFFFFF0DA);
const Color onWarningContainer = Color(0xFF9A5A00);
const Color errorContainerColor = Color(0xFFFFE2E8);
const Color onErrorContainer = Color(0xFFB11E3C);
const Color neutralContainer = Color(0xFFEEF0F3);
const Color onNeutralContainer = Color(0xFF4A5159);

// --- Acentos con transparencia (legacy; preferir contenedores tonales) ---
const Color accent1 = Color(0x4C0F77FF); // Primary 30%
const Color accent2 = Color(0x4D27C880); // Secondary 30%
const Color accent3 = Color(0x4DFFB560); // Tertiary 30%
const Color accent4 = Color(0x9AFFFFFF); // Overlay 60%
const Color circleColor = Color(0x4C0F77FF); // CircleAvatar (alias histórico)

// --- Sombra (suave / ambiental) ---
const Color shadowColor = Color(0x14000000); // ~8% negro
