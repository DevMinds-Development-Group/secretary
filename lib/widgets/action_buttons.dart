import 'package:Koinos/colors.dart';
import 'package:flutter/material.dart';

import '../services/tenant_scope.dart';

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
    // En modo consulta se conserva «ver» y desaparecen editar y borrar.
    final canWrite = TenantScope.canWriteChurchData;
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
        if (canWrite)
          IconButton(
            icon: Icon(Icons.edit, color: primaryColor.withOpacity(0.8)),
            onPressed: onEdit,
            tooltip: 'Editar',
          ),
        if (canWrite)
          IconButton(
            icon: Icon(Icons.delete, color: negativeColor.withOpacity(0.8)),
            onPressed: onDelete,
            tooltip: 'Eliminar',
          ),
      ],
    );
  }
}
