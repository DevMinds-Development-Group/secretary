import 'package:app/widgets/button.dart';
import 'package:app/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/ministry_model.dart';
import '../../providers/leader_provider.dart';
import '../../providers/ministry_provider.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/multi_select_dialog.dart';

class CreateMinistry extends StatefulWidget {
  final MinistryModel? ministryToEdit;

  const CreateMinistry({super.key, this.ministryToEdit});

  @override
  State<CreateMinistry> createState() => _CreateMinistryState();
}

class _CreateMinistryState extends State<CreateMinistry> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  Set<String> _selectedLeaderIds = {};
  bool get _isEditing => widget.ministryToEdit != null;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LeaderProvider>(context, listen: false).fetchLeaders();
    });
    if (widget.ministryToEdit != null) {
      final ministry = widget.ministryToEdit!;
      _nameController.text = ministry.name;
      _descriptionController.text = ministry.description;

      _selectedLeaderIds = ministry.leaders.map((l) => l.id).toSet();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveMinistry() async {
    if (!_formKey.currentState!.validate()) return;

    final ministryProvider = Provider.of<MinistryProvider>(
      context,
      listen: false,
    );
    final List<String> selectedIds = _selectedLeaderIds.toList();

    try {
      if (widget.ministryToEdit != null) {
        await ministryProvider.updateMinistry(
          widget.ministryToEdit!.id,
          _nameController.text.trim(),
          _descriptionController.text.trim(),
          selectedIds,
        );
      } else {
        await ministryProvider.addMinistry(
          _nameController.text.trim(),
          _descriptionController.text.trim(),
          selectedIds,
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ministerio guardado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al conectar con el servidor'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    final leaderProvider = Provider.of<LeaderProvider>(context, listen: false);
    final ministryProvider = context.watch<MinistryProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: _isEditing ? 'Editar Ministerio' : 'Crear Ministerio',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 30 : 70),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Center(
                    child: const Text(
                      'Detalles del Ministerio',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  CustomTextFormField(
                    controller: _nameController,
                    labelText: 'Nombre del Ministerio',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, ingrese un nombre.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    controller: _descriptionController,
                    labelText: 'Descripción',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingrese descripción del ministerio';
                      }
                      return null;
                    },
                    //maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: () async {
                      final Set<String>? result = await showDialog<Set<String>>(
                        context: context,
                        builder: (ctx) => MultiSelectDialog<String>(
                          title: 'Seleccionar Pastores',
                          items: leaderProvider.leaders
                              .map((p) => p.id)
                              .toList(),
                          initialSelectedItems: _selectedLeaderIds,
                          displayItem: (id) => leaderProvider.findById(id).name,
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _selectedLeaderIds = result;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Líderes del Ministerio',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      child: _selectedLeaderIds.isEmpty
                          ? Text(
                              'Ninguno seleccionado',
                              style: TextStyle(color: Colors.grey.shade600),
                            )
                          : Text(
                              leaderProvider.leaders
                                  .where(
                                    (p) => _selectedLeaderIds.contains(p.id),
                                  )
                                  .map((p) => '${p.name} ${p.lastName}')
                                  .join(', '),
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Button(
                        size: Size(130, 45),
                        text: widget.ministryToEdit != null
                            ? 'Actualizar'
                            : 'Guardar',
                        isLoading: ministryProvider.isLoading,
                        onPressed: _saveMinistry,
                      ),
                    ],
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
