import 'dart:io';

import 'package:Koinos/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/member_model.dart';
import '../../providers/member_provider.dart';
import '../../providers/network_provider.dart';
import '../../theme/design_constants.dart';
import '../../widgets/button.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/member_profile_image.dart';
import '../../widgets/nav_shell.dart';
import '../../widgets/no_connection_widget.dart';

class CreateMember extends StatefulWidget {
  final Member? memberToEdit;
  const CreateMember({Key? key, this.memberToEdit}) : super(key: key);

  @override
  State<CreateMember> createState() => _CreateMemberState();
}

class _CreateMemberState extends State<CreateMember> {
  // --- Propiedades y Controladores ---
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  DateTime? _selectedBirthDate;
  String? _selectedNetworkId;
  File? _selectedImage;
  bool _photoDeleted = false;

  bool get _isEditing => widget.memberToEdit != null;

  // --- Ciclo de Vida ---
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NetworkProvider>(context, listen: false).fetchNetworks();
    });

    if (_isEditing) {
      final m = widget.memberToEdit!;
      _nameController.text = m.name;
      _lastNameController.text = m.lastName;
      _phoneController.text = m.phone;
      _addressController.text = m.address;
      _selectedBirthDate = m.birthdate;
      _selectedNetworkId = m.networkId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // --- Selección de Imagen ---
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (file != null) {
      setState(() {
        _selectedImage = File(file.path);
        _photoDeleted = false;
      });
    }
  }

  // --- Lógica de Negocio ---
  Future<void> _saveMember() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedNetworkId == null) {
      _showSnackBar('Por favor, selecciona una red', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);

    String? memberId;
    bool success = false;

    try {
      if (_isEditing) {
        success = await memberProvider.updateMember(
          id: widget.memberToEdit!.id,
          name: _nameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          address: _addressController.text.trim(),
          phone: _phoneController.text.trim(),
          birthdate: _selectedBirthDate,
          enabled: widget.memberToEdit!.enabled,
          networkId: _selectedNetworkId!,
        );
        memberId = widget.memberToEdit!.id;
      } else {
        memberId = await memberProvider.addMemberAndGetId(
          name: _nameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          address: _addressController.text.trim(),
          phone: _phoneController.text.trim(),
          birthdate: _selectedBirthDate,
          networkId: _selectedNetworkId!,
        );
        success = memberId != null;
      }

      // Si se guardó el texto y hay una foto seleccionada, subirla
      if (success && _selectedImage != null) {
        await memberProvider.uploadMemberPhoto(memberId!, _selectedImage!);
      }

      if (mounted && success) {
        await memberProvider.fetchMembers(page: 0);
        _showSnackBar(_isEditing ? 'Miembro actualizado' : 'Miembro creado');
        Navigator.pop(context);
      } else if (mounted) {
        _showSnackBar('Error al guardar los datos.', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? negativeColor : accentColor,
      ),
    );
  }

  // --- Construcción de Interfaz ---
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    final netProvider = context.watch<NetworkProvider>();
    final memberProvider = context.watch<MemberProvider>();

    if (netProvider.error == "SIN_CONEXION" ||
        memberProvider.error == "SIN_CONEXION") {
      return NavShell(
        isSecondary: true,
        title: _isEditing ? 'Editar miembro' : 'Crear miembro',
        body: NoConnectionWidget(onRefresh: () => netProvider.fetchNetworks()),
      );
    }

    if (netProvider.isLoading && netProvider.networks.isEmpty) {
      return NavShell(
        isSecondary: true,
        title: _isEditing ? 'Editar miembro' : 'Crear miembro',
        body: const Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    return NavShell(
      isSecondary: true,
      title: _isEditing ? 'Editar miembro' : 'Crear miembro',
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: isMobile ? MediaQuery.of(context).size.width * 0.9 : 600,
            padding: EdgeInsets.all(isMobile ? 20.0 : 30.0),
            child: _buildForm(isMobile, memberProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(bool isMobile, MemberProvider mp) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          // Sección de foto interactiva
          Center(
            child: Stack(
              children: [
                MemberProfileImage(
                  imageUrl: _photoDeleted
                      ? null
                      : widget.memberToEdit?.photoUrl,
                  localFile: _selectedImage,
                  radius: 50,
                ),
                if (_selectedImage != null ||
                    (widget.memberToEdit?.photoUrl != null && !_photoDeleted))
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selectedImage = null;
                        _photoDeleted = true;
                      }),
                      child: const Tooltip(
                        message: 'Quitar foto',
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: errorColor,
                              child: Icon(
                                Icons.delete,
                                size: 16,
                                color: infoColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _pickImage,
            icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.onSurface),
            label: Text(
              "Subir foto",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          const SizedBox(height: 10.0),
          CustomTextFormField(
            labelText: 'Nombre',
            controller: _nameController,
            isRequired: true,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'El nombre es obligatorio'
                : null,
          ),
          const SizedBox(height: 16.0),
          CustomTextFormField(
            labelText: 'Apellidos',
            controller: _lastNameController,
            isRequired: true,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Los apellidos son obligatorios'
                : null,
          ),
          const SizedBox(height: 16.0),
          CustomTextFormField(
            labelText: 'Dirección',
            controller: _addressController,
            isRequired: true,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'La dirección es obligatoria'
                : null,
          ),
          const SizedBox(height: 16.0),
          CustomTextFormField(
            labelText: 'Teléfono',
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: _phoneController,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 16.0),
          _buildNetworkDropdown(),
          const SizedBox(height: 16.0),
          _buildDatePicker(),
          const SizedBox(height: 10.0),
          Button(
            size: Size(
              isMobile ? MediaQuery.of(context).size.width * 0.9 : 180,
              50,
            ),
            text: _isEditing ? 'Actualizar' : 'Guardar',
            isLoading: _isSaving,
            onPressed: _saveMember,
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkDropdown() {
    return Consumer<NetworkProvider>(
      builder: (context, netProvider, _) {
        return DropdownButtonFormField<String>(
          value: _selectedNetworkId,
          hint: const Text('Seleccionar red'),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                DesignConstants.borderRadiusDropdown,
              ),
              borderSide: const BorderSide(color: alternateColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                DesignConstants.borderRadiusDropdown,
              ),
              borderSide: const BorderSide(color: alternateColor, width: 2),
            ),
          ),
          items: netProvider.networks.map((net) {
            return DropdownMenuItem(value: net.id, child: Text(net.name));
          }).toList(),
          onChanged: (value) => setState(() => _selectedNetworkId = value),
          validator: (value) =>
              value == null ? 'Debe seleccionar una red' : null,
        );
      },
    );
  }

  Widget _buildDatePicker() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_today, color: primaryColor),
      title: const Text('Fecha de Nacimiento (Opcional)'),
      subtitle: Text(
        _selectedBirthDate == null
            ? 'No seleccionada'
            : DateFormat('dd/MM/yyyy', 'es_ES').format(_selectedBirthDate!),
      ),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedBirthDate ?? DateTime.now(),
          firstDate: DateTime(1920),
          lastDate: DateTime.now(),
        );
        if (picked != null) setState(() => _selectedBirthDate = picked);
      },
    );
  }
}
