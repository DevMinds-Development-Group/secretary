import 'package:flutter/animation.dart';

/// Tokens de movimiento alineados a Material 3.
///
/// Duraciones cortas para feedback, estándar para cambios de estado y
/// enfatizada para transiciones de página/diálogo.
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 120); // press / hover
  static const Duration standard = Duration(milliseconds: 220); // state change
  static const Duration emphasized = Duration(milliseconds: 320); // page / hero

  static const Curve standardCurve = Curves.easeInOutCubicEmphasized;
  static const Curve decelerate = Curves.easeOutCubic; // entrando
  static const Curve accelerate = Curves.easeInCubic; // saliendo
}
