import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../screens/home/dashboard.dart';
import '../../screens/home/home.dart';
import '../../services/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos al AuthService global
    final authService = Provider.of<AuthService>(context);

    return FutureBuilder<String?>(
      // Usamos el método del servicio que ya está en el Provider
      future: authService.getToken(),
      builder: (context, snapshot) {
        // 1. Mientras carga el token del disco
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Si hay un token válido, mostramos el Dashboard
        // Nota: También verificamos que userName no sea null para asegurar que el perfil cargó
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.isNotEmpty) {
          return const Dashboard();
        }

        // 3. Si el token es null o está vacío, mostramos el Login (Home)
        return const Home();
      },
    );
  }
}
