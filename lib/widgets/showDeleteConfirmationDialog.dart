import 'package:flutter/material.dart';

Future<void> showDeleteConfirmationDialog({
  required BuildContext context,
  required String itemName,
  required VoidCallback onConfirm,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext ctx) {
      bool isMobile = MediaQuery.of(context).size.width < 700;
      return AlertDialog(
        title: Align(
          alignment: Alignment.center,
          child: Text(
            'Confirmar Eliminación',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "$itemName"?',
          style: TextStyle(fontSize: isMobile ? 16 : 16),
        ),

        actions: <Widget>[
          TextButton(
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
            onPressed: () {
              Navigator.of(ctx).pop(); // Cierra el diálogo
            },
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Eliminar', style: TextStyle(fontSize: 18)),
            onPressed: () {
              // 1. Ejecuta la lógica de eliminación que nos pasaron.
              onConfirm();
              // 2. Cierra el diálogo.
              Navigator.of(ctx).pop();
            },
          ),
        ],
      );
    },
  );
}
