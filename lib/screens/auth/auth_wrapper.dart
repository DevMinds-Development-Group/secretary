// lib/screens/auth/auth_wrapper.dart

import 'package:app/screens/home/dashboard.dart';
import 'package:flutter/material.dart';

import '../../routes/routes.dart';
import '../../screens/home/home.dart'; // La pantalla principal de tu app
import '../../services/auth_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _checkAuth());
  }

  Future<void> _checkAuth() async {
    final token = await _authService.getToken();
    if (!mounted) return;

    if (token != null) {
      // Si hay token, SALTA al Dashboard y BORRA el Wrapper
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else {
      // Si no hay token, SALTA al Home y BORRA el Wrapper
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _authService.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Si el snapshot tiene datos (el token no es nulo), el usuario está logueado
        if (snapshot.hasData && snapshot.data != null) {
          return const Dashboard(); // Muestra la pantalla principal
        }

        // Si no hay token, muestra la pantalla de login
        return const Home();
      },
    );
  }
}
