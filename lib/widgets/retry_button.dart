import 'package:flutter/material.dart';

import '../colors.dart'; // Asegúrate de que la ruta sea correcta para acceder a primaryColor y cardColor

class RetryButton extends StatelessWidget {
  final VoidCallback onRefresh;

  const RetryButton({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor, // Fondo azul de la app
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
      onPressed: onRefresh,
      icon: const Icon(Icons.refresh, color: cardColor), // Icono blanco
      label: const Text(
        "Reintentar",
        style: TextStyle(
          color: cardColor, // Texto blanco
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
