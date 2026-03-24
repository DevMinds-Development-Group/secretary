import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/home/home.dart';
import '../services/auth_service.dart';

class RouteGuard {
  static Widget checkAuth(BuildContext context, Widget destination) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return FutureBuilder<String?>(
      future: authService.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // SI NO HAY TOKEN: Redirección forzosa al Home (Login)
        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return const Home();
        }

        // SI HAY TOKEN: Permitir ver la pantalla de destino
        return destination;
      },
    );
  }
}
