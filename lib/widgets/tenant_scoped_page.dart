import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tenant_provider.dart';

/// Rehace la pantalla cuando el Ministerio cambia de iglesia.
///
/// Las pantallas piden sus datos en el `initState` de su `State`, que vive por encima del
/// `NavShell`. Sin esto seguirían mostrando los de la iglesia anterior hasta navegar fuera y
/// volver: el selector cambiaba la etiqueta y nada más.
///
/// Cambiar la clave destruye y recrea la pantalla, así que su `initState` vuelve a pedir los datos
/// con el alcance nuevo. La ruta no cambia: si estabas en Miembros sigues en Miembros, ahora con
/// los de la otra iglesia.
///
/// Se aplica en los dos únicos sitios donde nacen las pantallas —`RouteGuard.checkAuth` y
/// `createFadeRoute`—, para que ninguna pueda quedarse fuera.
class TenantScopedPage extends StatelessWidget {
  final Widget child;

  const TenantScopedPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scope = context.watch<TenantProvider>().selectedChurchId ?? 'consolidado';
    return KeyedSubtree(key: ValueKey('alcance-$scope'), child: child);
  }
}
