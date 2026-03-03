// lib/screens/create/create_network.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/network_model.dart';
import '../../providers/network_provider.dart';
import '../../providers/pastor_provider.dart'; // <-- Importa el PastorProvider
import '../../widgets/button.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/multi_select_dialog.dart';

class CreateNetwork extends StatefulWidget {
  final NetworkModel? networkToEdit;
  const CreateNetwork({Key? key, this.networkToEdit}) : super(key: key);

  @override
  _CreateNetworkState createState() => _CreateNetworkState();
}

class _CreateNetworkState extends State<CreateNetwork> {
  final _formKey = GlobalKey<FormState>();
  Set<String> _selectedLeaderIds = {};

  final _nameController = TextEditingController();
  final _missionController = TextEditingController();

  //List<Member> _leaders = [];

  bool get _isEditing => widget.networkToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final network = widget.networkToEdit!;
      _nameController.text = network.name;
      _missionController.text = network.mission ?? '';
      _selectedLeaderIds = network.leaders.map((l) => l.id).toSet();
      //_leaders = List.from(network.leaders);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _missionController.dispose();
    super.dispose();
  }

  void _saveNetwork() async {
    if (!_formKey.currentState!.validate()) return;
    final networkProvider = Provider.of<NetworkProvider>(
      context,
      listen: false,
    );
    try {
      if (_isEditing) {
        final updatedNetwork = widget.networkToEdit!.copyWith(
          name: _nameController.text.trim(),
          mission: _missionController.text.trim(),
          //leaders: _leaders,
        );
        networkProvider.updateNetwork(
          updatedNetwork,
          _selectedLeaderIds.toList(),
        );
      } else {
        await networkProvider.addNetwork(
          _nameController.text.trim(),
          _missionController.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar los cambios.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pastorProvider = Provider.of<PastorProvider>(context);
    final availablePastors = pastorProvider.pastors;

    bool isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      appBar: CustomAppBar(title: _isEditing ? 'Editar Red' : 'Crear Red'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 30 : 70),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: const Text(
                      'Detalles de la Red',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la Red',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'El nombre es obligatorio'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _missionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Misión / Descripción',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 40),
                  InkWell(
                    onTap: () async {
                      final Set<String>? result = await showDialog<Set<String>>(
                        context: context,
                        builder: (ctx) => MultiSelectDialog<String>(
                          title: 'Seleccionar líderes',
                          items: availablePastors.map((p) => p.id).toList(),
                          initialSelectedItems: _selectedLeaderIds,
                          displayItem: (pastorId) =>
                              pastorProvider.findById(pastorId).name,
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
                        labelText: 'Líderes',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_pin),
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
                              _selectedLeaderIds
                                  .map((id) => pastorProvider.findById(id).name)
                                  .join(', '),
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Button(
                        size: Size(150, 45),
                        text: _isEditing ? 'Actualizar' : 'Crear Red',
                        onPressed: _saveNetwork,
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
