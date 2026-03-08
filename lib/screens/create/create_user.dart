// lib/screens/create/create_user.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/member_model.dart';
import '../../models/role_model.dart';
import '../../models/user_model.dart';
import '../../providers/member_provider.dart';
import '../../providers/role_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/button.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_text_form_field.dart';

class CreateUser extends StatefulWidget {
  final User? userToEdit;
  const CreateUser({Key? key, this.userToEdit}) : super(key: key);

  @override
  _CreateUserState createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _userNameController;
  late TextEditingController _passwordController;
  late TextEditingController _memberAutocompleteController;

  String? _selectedRoleId;
  String? _selectedMemberId;
  bool _isSaving = false;

  bool get _isEditing => widget.userToEdit != null;

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(
      text: widget.userToEdit?.username ?? '',
    );
    _passwordController = TextEditingController();
    _memberAutocompleteController = TextEditingController();
    _selectedMemberId = widget.userToEdit?.memberId;

    // Usamos un Future para asegurar que el provider esté listo antes de inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MemberProvider>(context, listen: false).fetchMembers();
      _initializeFields();
    });
  }

  void _initializeFields() {
    final roleProvider = Provider.of<RoleProvider>(context, listen: false);

    // Si estamos editando, intentamos preseleccionar los campos
    if (_isEditing) {
      // Preselección de miembro
      if (_selectedMemberId != null) {
        final memberProvider = Provider.of<MemberProvider>(
          context,
          listen: false,
        );
        try {
          final member = memberProvider.allMembers.firstWhere(
            (m) => m.id == _selectedMemberId,
          );
          _memberAutocompleteController.text = member.name;
        } catch (e) {
          _selectedMemberId = null;
        }
      }

      // Preselección de rol
      if (roleProvider.roles.isNotEmpty) {
        try {
          final role = roleProvider.roles.firstWhere(
            (r) => r.displayName == widget.userToEdit!.role,
          );
          // Usamos setState para que la UI se actualice con el valor preseleccionado
          setState(() {
            _selectedRoleId = role.id;
          });
        } catch (e) {
          print('Error al preseleccionar rol: ${e.toString()}');
        }
      }
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    _memberAutocompleteController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un rol.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // --- LÍNEA DE DEPURACIÓN ---
    // Esto nos dirá exactamente qué ID estamos enviando.
    print('--- GUARDANDO USUARIO ---');
    print('Username: ${_userNameController.text.trim()}');
    print('Rol ID Seleccionado: $_selectedRoleId');
    print('-------------------------');

    setState(() => _isSaving = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    bool success = false;

    if (_isEditing) {
      success = await userProvider.updateUser(
        username: widget.userToEdit!.username,
        password: _passwordController.text.isNotEmpty
            ? _passwordController.text
            : null,
        roleIds: [_selectedRoleId!],
        memberId: _selectedMemberId,
      );
    } else {
      success = await userProvider.addUser(
        username: _userNameController.text.trim(),
        password: _passwordController.text,
        roleIds: [_selectedRoleId!],
        memberId: _selectedMemberId,
      );
    }

    setState(() => _isSaving = false);

    if (success && mounted) {
      await Provider.of<UserProvider>(context, listen: false).fetchUsers();
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userProvider.error ?? 'Ocurrió un error desconocido.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      appBar: CustomAppBar(
        title: _isEditing ? 'Editar Usuario' : 'Crear Usuario',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 30 : 70),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.account_circle,
                    size: 120,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    controller: _userNameController,
                    labelText: 'Nombre de usuario',
                    readOnly: _isEditing,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'El nombre de usuario no puede estar vacío.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    controller: _passwordController,
                    labelText: _isEditing
                        ? 'Nueva Contraseña (Opcional)'
                        : 'Contraseña',
                    obscureText: true,
                    validator: (v) => (!_isEditing && (v == null || v.isEmpty))
                        ? 'La contraseña no puede estar vacía.'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // --- WIDGET DE ROL CON CONSUMER PARA MÁXIMA ROBUSTEZ ---
                  Consumer<RoleProvider>(
                    builder: (context, roleProvider, child) {
                      if (roleProvider.isLoading ||
                          (roleProvider.roles.isEmpty &&
                              roleProvider.error == null)) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (roleProvider.error != null) {
                        return Text(
                          'Error al cargar roles: ${roleProvider.error}',
                        );
                      }

                      return DropdownButtonFormField<String>(
                        value: _selectedRoleId,
                        hint: const Text('Selecciona un rol'),
                        decoration: const InputDecoration(
                          labelText: 'Rol',
                          border: OutlineInputBorder(),
                        ),
                        items: roleProvider.roles.map((Role role) {
                          return DropdownMenuItem<String>(
                            value: role.id,
                            child: Text(role.displayName),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedRoleId = newValue;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Debes seleccionar un rol' : null,
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  Consumer<MemberProvider>(
                    builder: (context, memberProvider, child) {
                      return Autocomplete<Member>(
                        displayStringForOption: (Member option) =>
                            '${option.name} ${option.lastName}',
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<Member>.empty();
                          }
                          return memberProvider.members.where((Member m) {
                            final fullName = '${m.name} ${m.lastName}'
                                .toLowerCase();
                            return fullName.contains(
                              textEditingValue.text.toLowerCase(),
                            );
                          });
                        },
                        onSelected: (Member selection) => setState(() {
                          {
                            _selectedMemberId = selection.id;
                            _memberAutocompleteController.text =
                                '${selection.name} ${selection.lastName}';
                          }
                        }),
                        fieldViewBuilder:
                            (
                              context,
                              fieldController,
                              focusNode,
                              onFieldSubmitted,
                            ) {
                              if (_isEditing &&
                                  _selectedMemberId != null &&
                                  fieldController.text.isEmpty) {
                                try {
                                  final m = memberProvider.members.firstWhere(
                                    (element) =>
                                        element.id == _selectedMemberId,
                                  );
                                  fieldController.text =
                                      '${m.name} ${m.lastName}';
                                } catch (_) {}
                              }
                              return TextFormField(
                                controller: fieldController,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  labelText: 'Asociar a Miembro (Opcional)',
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      fieldController.clear();
                                      setState(() => _selectedMemberId = null);
                                      focusNode.unfocus();
                                    },
                                  ),
                                ),
                              );
                            },
                      );
                    },
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
                          text: _isEditing ? 'Guardar' : 'Crear Usuario',
                          onPressed: _saveUser,
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
