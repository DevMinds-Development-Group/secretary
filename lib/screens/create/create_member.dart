// En tu archivo 'add_new_member_screen.dart'

import 'package:app/widgets/button.dart';
import 'package:app/widgets/custom_appbar.dart';
import 'package:app/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/member_model.dart';
import '../../providers/member_provider.dart';
import '../../providers/network_provider.dart';

class CreateMember extends StatefulWidget {
  final Member? memberToEdit;
  const CreateMember({Key? key, this.memberToEdit}) : super(key: key);

  @override
  State<CreateMember> createState() => _CreateMemberState();
}

class _CreateMemberState extends State<CreateMember> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime? _selectedBirthDate;
  String? _selectedNetworkId;

  String? _selectedNetwork;

  bool get _isEditing => widget.memberToEdit != null;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NetworkProvider>(context, listen: false).fetchNetworks();
    });

    if (_isEditing) {
      final m = widget.memberToEdit!;

      _nameController.text = m.name;
      _lastNameController.text = m.lastName;
      _phoneController.text = m.phone;
      _addressController.text = m.address;
      _selectedNetwork = m.networkName;
      _selectedBirthDate = m.birthdate;
      _selectedNetworkId = widget.memberToEdit!.networkId;
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

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona la fecha de nacimiento'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);

    bool success = false;

    if (_isEditing) {
      success = await memberProvider.updateMember(
        id: widget.memberToEdit!.id,
        name: _nameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        birthdate: _selectedBirthDate!,
        enabled: widget.memberToEdit!.enabled,
        networkId: _selectedNetworkId!,
      );
    } else {
      success = await memberProvider.addMember(
        name: _nameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        birthdate: _selectedBirthDate!,
        networkId: _selectedNetworkId!,
      );
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Miembro actualizado con éxito'
                  : 'Miembro creado con éxito',
            ),
            backgroundColor: Colors.green,
          ),
        );
        await memberProvider.fetchMembers(); // Refrescar la lista
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar los datos. Revisa la consola.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Crear miembro'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return isMobile
              ? _buildMobileLayout(isMobile)
              : _buildWebLayout(isMobile);
        },
      ),
    );
  }

  Widget _buildMobileLayout(isMobile) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24.0),
            _buildFormFields(context, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildWebLayout(isMobile) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          width: 600,
          padding: EdgeInsets.all(30.0),
          child: _buildFormFields(context, isMobile),
        ),
      ),
    );
  }

  Widget _buildFormFields(BuildContext context, isMobile) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Center(
            child: Image.asset('assets/02.png', height: isMobile ? 100 : 120),
          ),
          SizedBox(height: isMobile ? 20 : 30.0),
          CustomTextFormField(
            labelText: 'Nombre',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es obligatorio';
              }
              if (value.length < 3) {
                return 'El nombre debe tener al menos 3 caracteres';
              }
              return null; // Válido
            },
            controller: _nameController,
          ),
          const SizedBox(height: 16.0),
          CustomTextFormField(
            labelText: 'Apellidos',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Los apellidos son obligatorios';
              }
              return null; // Válido
            },
            controller: _lastNameController,
          ),
          const SizedBox(height: 16.0),
          CustomTextFormField(
            labelText: 'Dirección',
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'La dirección es obligatoria'
                : null,
            controller: _addressController,
          ),
          const SizedBox(height: 16.0),
          CustomTextFormField(
            labelText: 'Teléfono',
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El teléfono es obligatorio';
              }
              if (value.length < 8) {
                return 'El teléfono debe tener al menos 8 números';
              }
              return null; // Válido
            },

            controller: _phoneController,
          ),
          const SizedBox(height: 16.0),
          DropDownNetwork(),
          const SizedBox(height: 16.0),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: const Text('Fecha de Nacimiento'),
            subtitle: Text(
              _selectedBirthDate == null
                  ? 'No seleccionada'
                  : DateFormat(
                      'dd/MM/yyyy',
                      'es_ES',
                    ).format(_selectedBirthDate!),
            ),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedBirthDate ?? DateTime.now(),
                firstDate: DateTime(1920),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _selectedBirthDate = picked;
                });
              }
            },
          ),
          const SizedBox(height: 30.0),
          Button(
            size: Size(
              isMobile ? MediaQuery.of(context).size.width * 0.9 : 150,
              45,
            ),
            text: 'Guardar',
            onPressed: _saveMember,
          ),
        ],
      ),
    );
  }

  Widget DropDownNetwork() {
    return Consumer<NetworkProvider>(
      builder: (context, netProvider, child) {
        return DropdownButtonFormField<String>(
          value: _selectedNetworkId,
          hint: const Text('Seleccionar red'),
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
}
