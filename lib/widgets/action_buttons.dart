import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Color editColor;
  final Color deleteColor;

  const ActionButtons({
    super.key,
    required this.onEdit,
    required this.onDelete,
    this.editColor = Colors.blue,
    this.deleteColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit, color: editColor.withOpacity(0.8)),
          onPressed: onEdit,
          tooltip: 'Editar',
        ),
        IconButton(
          icon: Icon(Icons.delete, color: deleteColor.withOpacity(0.8)),
          onPressed: onDelete,
          tooltip: 'Eliminar',
        ),
      ],
    );
  }
}
