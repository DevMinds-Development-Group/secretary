import 'package:Koinos/colors.dart';
import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback? onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ActionButtons({
    super.key,
    this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onView != null)
          IconButton(
            icon: Icon(Icons.visibility_outlined,
                color: primaryColor.withOpacity(0.8)),
            onPressed: onView,
            tooltip: 'Ver perfil',
          ),
        IconButton(
          icon: Icon(Icons.edit, color: primaryColor.withOpacity(0.8)),
          onPressed: onEdit,
          tooltip: 'Editar',
        ),
        IconButton(
          icon: Icon(Icons.delete, color: negativeColor.withOpacity(0.8)),
          onPressed: onDelete,
          tooltip: 'Eliminar',
        ),
      ],
    );
  }
}
