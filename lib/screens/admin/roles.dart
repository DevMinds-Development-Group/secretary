// lib/screens/admin/roles.dart

import 'package:app/colors.dart';
import 'package:app/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import '../../models/permission_model.dart'; // <-- 1. ELIMINAMOS ESTA IMPORTACIÓN INNECESARIA
import '../../models/role_model.dart';
import '../../providers/role_provider.dart';
import '../../routes/page_route_builder.dart';
import '../../widgets/add_button.dart';
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
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Roles'),
      body: Consumer<RoleProvider>(
        builder: (context, roleProvider, child) {
          if (roleProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (roleProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${roleProvider.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => roleProvider.fetchRoles(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          final roles = roleProvider.roles;
          return RefreshIndicator(
            onRefresh: () => roleProvider.fetchRoles(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return constraints.maxWidth < 700
                    ? _buildMobileLayout(context, roles)
                    : _buildWebLayout(context, roles);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, List<Role> roles) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.center,
            child: AddButton(
              size: Size(MediaQuery.of(context).size.width * 0.9, 50),
              onPressed: () {
                Navigator.push(context, createFadeRoute(const CreateRole()));
              },
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: roles.length,
            itemBuilder: (context, index) {
              final role = roles[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: ListTile(
                  title: Text(role.displayName),
                  subtitle: Text(
                    '${role.permissions.length} permisos asignados',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            createFadeRoute(CreateRole(roleToEdit: role)),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDelete(context, role);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    _showPermissionsDialog(context, role);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWebLayout(BuildContext context, List<Role> roles) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AddButton(
                onPressed: () {
                  Navigator.push(context, createFadeRoute(const CreateRole()));
                },
              ),
              const SizedBox(width: 35),
            ],
          ),
          SizedBox(height: 20),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1500),
              child: Card(
                elevation: 5,
                color: Colors.white,
                child: DataTable(
                  columnSpacing: MediaQuery.of(context).size.width * 0.1,
                  columns: [
                    DataColumn(
                      label: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.15,
                        child: Text('Nombre de rol', style: _headerStyle()),
                      ),
                    ),
                    DataColumn(
                      label: Text('Descripción', style: _headerStyle()),
                    ),

                    DataColumn(label: Text('Permisos', style: _headerStyle())),
                    DataColumn(label: Text('Acciones', style: _headerStyle())),
                  ],
                  rows: roles.map((role) {
                    final permissionsText = role.permissions.isEmpty
                        ? 'Ninguno'
                        : role.permissions.join(', ');

                    return DataRow(
                      cells: [
                        DataCell(Text(role.displayName)),
                        DataCell(
                          Text(
                            role.description,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DataCell(
                          Tooltip(
                            message: permissionsText,
                            child: Text(
                              maxLines: 2,
                              permissionsText,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    createFadeRoute(
                                      CreateRole(roleToEdit: role),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  _showDelete(context, role);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionsDialog(BuildContext context, Role role) {
    // Este diálogo ya estaba correcto, no se necesita ningún cambio aquí.
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Permisos de "${role.displayName}"'),
          content: SingleChildScrollView(
            child: ListBody(
              children: role.permissions.isEmpty
                  ? [const Text('Este rol no tiene permisos asignados.')]
                  : role.permissions.map((String permission) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text('• $permission'),
                      );
                    }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('CERRAR'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleDelete(BuildContext context, Role role) async {
    final roleProvider = Provider.of<RoleProvider>(context, listen: false);

    final success = await roleProvider.deleteRole(role.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Rol "${role.displayName}" eliminado correctamente.'
                : roleProvider.error ?? 'Error al eliminar el rol',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _showDelete(BuildContext context, Role role) {
    return showDeleteConfirmationDialog(
      context: context,
      itemName: role.displayName,
      onConfirm: () => _handleDelete(context, role),
    );
  }

  TextStyle _headerStyle() {
    return const TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
  }
}
