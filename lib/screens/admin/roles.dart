import 'package:Koinos/widgets/action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/role_model.dart';
import '../../providers/role_provider.dart';
import '../../routes/page_route_builder.dart';
import '../../widgets/add_button.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_web_table.dart';
import '../../widgets/showDeleteConfirmationDialog.dart';
import '../create/create_role.dart';

class Roles extends StatefulWidget {
  const Roles({Key? key}) : super(key: key);

  @override
  State<Roles> createState() => _RolesState();
}

class _RolesState extends State<Roles> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RoleProvider>(context, listen: false).fetchRoles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final roleProvider = context.watch<RoleProvider>();
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Roles'),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                alignment: isMobile ? Alignment.center : Alignment.centerRight,
                child: AddButton(
                  size: isMobile
                      ? Size(MediaQuery.of(context).size.width * 0.9, 50)
                      : null,
                  onPressed: () => Navigator.push(
                    context,
                    createFadeRoute(const CreateRole()),
                  ),
                ),
              ),
            ),
            SizedBox(height: isMobile ? 20 : 5),
            Expanded(
              child: roleProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : roleProvider.roles.isEmpty
                  ? const Center(child: Text('No hay roles para mostrar.'))
                  : Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(),
                        child: _buildMainContent(
                          context,
                          isMobile,
                          roleProvider.roles,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    bool isMobile,
    List<Role> roles,
  ) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: isMobile
          ? ClipRRect(
              // Solo envuelve al móvil si lo necesitas
              borderRadius: BorderRadius.circular(12),
              child: _buildMobileList(roles),
            )
          : CustomWebTable<Role>(
              items: roles,
              columnLabels: [
                'Nombre de rol',
                'Descripción',
                'Permisos',
                'Acciones',
              ],
              columnSpacing: MediaQuery.of(context).size.width * 0.1,
              rowBuilder: (role) {
                final permissionsText = role.permissions.isEmpty
                    ? 'Ninguno'
                    : role.permissions.join(', ');
                return [
                  DataCell(Text(role.displayName)),
                  DataCell(
                    SizedBox(
                      width: 200,
                      child: Text(
                        role.description,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Tooltip(
                      message: permissionsText,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: Text(
                          permissionsText,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  DataCell(_buildActions(context, role)),
                ];
              },
            ),
    );
  }

  Widget _buildMobileList(List<Role> roles) {
    return ListView.separated(
      padding: const EdgeInsets.all(10),
      itemCount: roles.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final role = roles[index];
        return ListTile(
          title: Text(
            role.displayName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${role.permissions.length} permisos asignados'),
          onTap: () => _showPermissionsDialog(context, role),
          trailing: _buildActions(context, role),
        );
      },
    );
  }

  Widget _buildActions(BuildContext context, Role role) {
    return ActionButtons(
      onEdit: () => Navigator.push(
        context,
        createFadeRoute(CreateRole(roleToEdit: role)),
      ),
      onDelete: () => _showDelete(context, role),
    );
  }

  void _showPermissionsDialog(BuildContext context, Role role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permisos de "${role.displayName}"'),
        content: SingleChildScrollView(
          child: ListBody(
            children: role.permissions.isEmpty
                ? [const Text('Sin permisos asignados.')]
                : role.permissions.map((p) => Text('• $p')).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CERRAR'),
          ),
        ],
      ),
    );
  }

  void _showDelete(BuildContext context, Role role) {
    showDeleteConfirmationDialog(
      context: context,
      itemName: role.displayName,
      onConfirm: () async {
        final success = await Provider.of<RoleProvider>(
          context,
          listen: false,
        ).deleteRole(role.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'Rol eliminado' : 'Error al eliminar'),
              backgroundColor: success ? accentColor : negativeColor,
            ),
          );
        }
      },
    );
  }
}
