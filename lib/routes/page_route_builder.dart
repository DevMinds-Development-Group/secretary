import 'package:flutter/material.dart';

import '../widgets/tenant_scoped_page.dart';

// Función que crea una ruta con transición de Fundido (Fade) LENTA y SUAVE
Route createFadeRoute(Widget page, {int durationMillis = 400}) {
  return PageRouteBuilder(
    opaque: true,
    // Atada al alcance de inquilino igual que las rutas con nombre: son los dos únicos
    // sitios donde nacen las pantallas.
    pageBuilder: (context, animation, secondaryAnimation) =>
        TenantScopedPage(child: page),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation, // O opacity: curvedAnimation si usas la curva
        child: child,
      );
    },

    transitionDuration: Duration(milliseconds: durationMillis),
  );
}
