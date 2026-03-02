import 'package:flutter/material.dart';

// Función que crea una ruta con transición de Fundido (Fade) LENTA y SUAVE
Route createFadeRoute(Widget page, {int durationMillis = 400}) {
  return PageRouteBuilder(
    opaque: true,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation, // O opacity: curvedAnimation si usas la curva
        child: child,
      );
    },

    transitionDuration: Duration(milliseconds: durationMillis),
  );
}
