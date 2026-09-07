import 'package:Koinos/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/tenant_scoped_page.dart';

import '../screens/home/home.dart';
import '../services/auth_service.dart';

class RouteGuard {
  static Widget checkAuth(BuildContext context, Widget destination) {
    return _RouteGuard(destination: destination);
  }
}

/// Comprueba que hay sesión antes de dejar ver la pantalla.
///
/// Es un `StatefulWidget` y no un `FutureBuilder` suelto porque el futuro tiene que pedirse una
/// sola vez. Pidiéndolo en el `build`, cada reconstrucción creaba un futuro nuevo, el
/// `FutureBuilder` volvía a `waiting` y la pantalla entera se cambiaba por el indicador de carga
/// para reaparecer un instante después: la página se destruía y se rehacía bajo cualquier diálogo
/// que hubiera abierto encima.
class _RouteGuard extends StatefulWidget {
  final Widget destination;

  const _RouteGuard({required this.destination});

  @override
  State<_RouteGuard> createState() => _RouteGuardState();
}

class _RouteGuardState extends State<_RouteGuard> {
  late final Future<String?> _token;

  @override
  void initState() {
    super.initState();
    _token = context.read<AuthService>().getToken();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _token,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: primaryColor)),
          );
        }

        // SI NO HAY TOKEN: Redirección forzosa al Home (Login)
        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return const Home();
        }

        // SI HAY TOKEN: Permitir ver la pantalla de destino, atada al alcance de inquilino
        return TenantScopedPage(child: widget.destination);
      },
    );
  }
}
