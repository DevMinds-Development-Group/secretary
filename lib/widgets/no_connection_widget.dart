import 'package:Koinos/widgets/retry_button.dart';
import 'package:flutter/material.dart';

Widget NoConnectionWidget({required VoidCallback onRefresh}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.grey),
        const SizedBox(height: 15),
        const Text(
          "Sin conexión a Internet",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text("Verifica tu red e intenta de nuevo."),
        const SizedBox(height: 20),
        RetryButton(onRefresh: onRefresh),
      ],
    ),
  );
}
