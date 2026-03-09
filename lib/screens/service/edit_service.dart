import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/member_model.dart';
import '../../../models/service_model.dart';
import '../../../providers/service_provider.dart';
import '../../../providers/service_type_provider.dart';
import '../../../widgets/button.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/member_autocomplete_field.dart';

class EditService extends StatefulWidget {
  final ServiceModel serviceToEdit;
  const EditService({Key? key, required this.serviceToEdit}) : super(key: key);

  @override
  _EditServiceState createState() => _EditServiceState();
}

class _EditServiceState extends State<EditService> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _preacherController;
  late TextEditingController _worshipMinisterController;
  late String _selectedTitle;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  Member? _selectedPreacherMember;
  Member? _selectedWorshipMinisterMember;

  @override
  void initState() {
    super.initState();
    _selectedTitle = widget.serviceToEdit.title;
    _selectedDate = widget.serviceToEdit.date;
    _selectedTime = widget.serviceToEdit.time;
  }

  @override
  void dispose() {
    _preacherController.dispose();
    _worshipMinisterController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedService = ServiceModel(
        type: '',
        description: '',
        id: widget.serviceToEdit.id,
        title: _selectedTitle,
        date: _selectedDate,
        time: _selectedTime,
      );
      Provider.of<ServiceProvider>(
        context,
        listen: false,
      ).updateService(updatedService);
      Navigator.of(context).pop();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      //barrierColor: Colors.blue.shade200,
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    final serviceTypeProvider = Provider.of<ServiceTypeProvider>(
      context,
      listen: false,
    );
    final serviceNames = serviceTypeProvider.serviceTypes
        .map((type) => type.name)
        .toList();

    if (!serviceNames.contains(_selectedTitle)) {
      serviceNames.insert(0, _selectedTitle);
    }

    final String formattedDate = DateFormat(
      'EEEE, dd \'de\' MMMM',
      'es',
    ).format(_selectedDate);
    final String formattedTime = _selectedTime.format(context);

    return Scaffold(
      appBar: CustomAppBar(title: 'Editar Servicio'),
      body: Center(
        heightFactor: isMobile ? 1 : 1,
        child: Container(
          padding: const EdgeInsets.all(24.0),
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedTitle,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Servicio',
                    ),
                    items: serviceNames
                        .map(
                          (name) =>
                              DropdownMenuItem(value: name, child: Text(name)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedTitle = value);
                    },
                    validator: (value) =>
                        value == null ? 'Selecciona un nombre' : null,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          isMobile ? '$formattedDate' : 'Fecha: $formattedDate',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _selectDate(context),
                        child: const Text('Cambiar'),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.grey),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Hora: $formattedTime',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _selectTime(context),
                        child: const Text('Cambiar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  MemberAutocompleteField(
                    controller: _preacherController,
                    labelText: 'Predicador(a)',
                    onMemberSelected: (member) =>
                        _selectedPreacherMember = member,
                  ),
                  const SizedBox(height: 30),
                  MemberAutocompleteField(
                    controller: _worshipMinisterController,
                    labelText: 'Ministro de Alabanza',
                    onMemberSelected: (member) =>
                        _selectedWorshipMinisterMember = member,
                  ),
                  const SizedBox(height: 30),
                  Button(
                    text: 'Actualizar',
                    onPressed: _submitForm,
                    size: const Size(150, 45),
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
