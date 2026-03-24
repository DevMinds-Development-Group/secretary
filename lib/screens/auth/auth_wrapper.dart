import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../screens/home/dashboard.dart';
import '../../screens/home/home.dart';
import '../../services/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return FutureBuilder<String?>(
      future: authService.getToken(),
      builder: (context, snapshot) {
        // 1. Mientras carga el token del disco
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final String? token = snapshot.data;

        if (token != null && token.isNotEmpty) {
          // SI HAY TOKEN: El usuario está autenticado, va al Dashboard
          return const Dashboard();
        } else {
          // NO HAY TOKEN: Obligatoriamente al Home (Login)
          return const Home();
        }
      },
    );
  }
}
