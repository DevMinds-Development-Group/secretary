// lib/screens/create/create_role.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/permission_model.dart';
import '../../models/role_model.dart';
import '../../providers/role_provider.dart';
import '../../widgets/button.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/multi_select_dialog.dart';

class CreateRole extends StatefulWidget {
  final Role? roleToEdit;
  const CreateRole({Key? key, this.roleToEdit}) : super(key: key);

  @override
  _CreateRoleState createState() => _CreateRoleState();
}

class _CreateRoleState extends State<CreateRole> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  Set<Permission> _selectedPermissions = {};
  bool get _isEditing => widget.roleToEdit != null;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.roleToEdit!.name;
      _descriptionController.text = widget.roleToEdit!.description;

      // --- NUEVO: Convertir List<String> del backend a Set<Permission> de Flutter ---
      _selectedPermissions = widget.roleToEdit!.permissions.map((pString) {
        return Permission.values.firstWhere(
          (e) => e.name == pString,
          orElse: () =>
              Permission.MEMBRESIA, // Valor por defecto si no coincide
        );
      }).toSet();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveRole() async {
    if (_formKey.currentState == null) {
      print('ERROR: _formKey.currentState es nulo');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      print('FORMULARIO NO VÁLIDO: Revisa los campos rojos');
      return;
    }

    print('FORMULARIO VÁLIDO: Iniciando proceso de guardado...');

    setState(() => _isSaving = true);

    try {
      final roleProvider = Provider.of<RoleProvider>(context, listen: false);
      final permissionsAsString = _selectedPermissions
          .map((p) => p.name)
          .toList();

      print('MODO EDICIÓN: $_isEditing');
      print('PERMISOS A ENVIAR: $permissionsAsString');

      bool success = false;
      if (_isEditing) {
        print('LLAMANDO A: updateRole con ID: ${widget.roleToEdit!.id}');
        success = await roleProvider.updateRole(
          id: widget.roleToEdit!.id,
          name: _nameController.text,
          description: _descriptionController.text,
          permissions: permissionsAsString,
          enabled: widget.roleToEdit!.enabled,
        );
      } else {
        print('LLAMANDO A: addRole');
        success = await roleProvider.addRole(
          name: _nameController.text,
          description: _descriptionController.text,
          permissions: permissionsAsString,
        );
      }

      print('RESULTADO DE LA OPERACIÓN: $success');

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Operación exitosa'),
            backgroundColor: Colors.green,
          ),
        );
        await roleProvider.fetchRoles();
        Navigator.of(context).pop();
      } else if (!success && mounted) {
        print('ERROR CAPTURADO EN PROVIDER: ${roleProvider.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              roleProvider.error ?? 'Error desconocido en el servidor',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stacktrace) {
      print('EXCEPCIÓN CRÍTICA: $e');
      print('STACKTRACE: $stacktrace');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      appBar: CustomAppBar(title: _isEditing ? 'Editar Rol' : 'Crear Rol'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 30 : 70),
        child: Center(
          child: Container(
            //width: isMobile ? MediaQuery.of(context).size.width * 0.8 : 600,
            //padding: const EdgeInsets.all(50.0),
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 120,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 30),
                  CustomTextFormField(
                    controller: _nameController,
                    labelText: 'Nombre del Rol',
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'El nombre es obligatorio'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    controller: _descriptionController,
                    labelText: 'Descripción',
                    //maxLines: 3,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'La descripción es obligatoria'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: () async {
                      // Muestra el diálogo y espera el resultado
                      final Set<Permission>? result =
                          await showDialog<Set<Permission>>(
                            context: context,
                            builder: (BuildContext context) {
                              return MultiSelectDialog<Permission>(
                                title: 'Seleccionar Permisos',
                                items: Permission.values,
                                displayItem: (permission) =>
                                    getPermissionName(permission),
                                initialSelectedItems: _selectedPermissions,
                              );
                            },
                          );
                      if (result != null) {
                        setState(() {
                          _selectedPermissions = result;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Permisos',
                        border: OutlineInputBorder(),
                      ),
                      child: _selectedPermissions.isEmpty
                          ? const Text('Ninguno seleccionado')
                          : Text(
                              _selectedPermissions
                                  .map((p) => getPermissionName(p))
                                  .join(', '),
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _isSaving
                      ? const Center(child: CircularProgressIndicator())
                      : Button(
                          size: Size(
                            isMobile
                                ? MediaQuery.of(context).size.width * 0.8
                                : 170,
                            isMobile ? 50 : 45,
                          ),
                          text: 'Guardar',
                          onPressed: _saveRole,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
