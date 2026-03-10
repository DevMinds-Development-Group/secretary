import 'package:app/colors.dart';
import 'package:app/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/service_model.dart';
import '../../providers/service_provider.dart';
import '../../widgets/button.dart';
import '../../widgets/custom_text_form_field.dart';

class CreateService extends StatefulWidget {
  const CreateService({super.key});

  @override
  State<CreateService> createState() => _CreateServiceState();
}

class _CreateServiceState extends State<CreateService> {
  final _formKey = GlobalKey<FormState>();

  // Form states linked to the model
  String name = '';
  String description = '';
  String type = 'CULTO';
  bool isRecurring = false;
  DateTime? selectedDate = DateTime.now();
  TimeOfDay selectedTime = const TimeOfDay(hour: 18, minute: 0);
  String weekDay = 'LUNES';

  // Controllers for preachers and ministers
  final TextEditingController _preacherController = TextEditingController();
  final TextEditingController _ministerController = TextEditingController();

  final List<String> serviceTypes = ['CULTO', 'REUNION', 'EVENTO', 'OTRO'];
  final List<String> weekDays = [
    'LUNES',
    'MARTES',
    'MIÉRCOLES',
    'JUEVES',
    'VIERNES',
    'SÁBADO',
    'DOMINGO',
  ];

  // BUSINESS RULES (Visibility logic)
  bool get shouldShowDate => !isRecurring;
  bool get shouldShowWeekDay => isRecurring;
  bool get shouldShowSpecialFields => type == 'CULTO' || type == 'EVENTO';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  void _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      final serviceProvider = Provider.of<ServiceProvider>(
        context,
        listen: false,
      );

      final newService = ServiceModel(
        id: '', // Backend generates the ID
        title: name,
        description: description,
        type: type,
        date: selectedDate ?? DateTime.now(),
        time: selectedTime,
        preachers: _preacherController.text.isNotEmpty
            ? _preacherController.text.split(',').map((e) => e.trim()).toList()
            : [],
        worshipMinistries: _ministerController.text.isNotEmpty
            ? _ministerController.text.split(',').map((e) => e.trim()).toList()
            : [],
      );

      // Logic to call provider would go here:
      // await serviceProvider.addService(newService);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Processing registration...'),
          backgroundColor: Color(0xFF4F46E5),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Crear servicio'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Card(
                  color: Colors.white,
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(
                            Icons.edit_calendar,
                            'Nombre del Servicio',
                            Colors.teal,
                          ),
                          CustomTextFormField(
                            labelText: 'Ej: Culto de Adoración',
                            validator: (val) =>
                                val!.isEmpty ? 'Campo requerido' : null,
                            onChanged: (val) => setState(() => name = val),
                          ),
                          const SizedBox(height: 20),
                          _buildLabel(
                            Icons.description,
                            'Descripción',
                            Colors.deepOrange,
                          ),
                          CustomTextFormField(
                            labelText: 'Detalles adicionales...',
                            onChanged: (val) =>
                                setState(() => description = val),
                          ),
                          const SizedBox(height: 20),
                          _buildLabel(
                            Icons.category,
                            'Tipo de Actividad',
                            Colors.cyan,
                          ),
                          DropdownButtonFormField<String>(
                            value: type,
                            decoration: _inputDecoration(''),
                            items: serviceTypes
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) => setState(() => type = val!),
                          ),
                          const SizedBox(height: 30),
                          // Recurring Switch
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.black54),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.repeat, color: primaryColor),
                                    const SizedBox(width: 10),
                                    Text(
                                      '¿Es Recurrente?',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: isRecurring,
                                  activeColor: primaryColor,
                                  onChanged: (val) =>
                                      setState(() => isRecurring = val),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          if (shouldShowDate) ...[
                            _buildLabel(
                              Icons.calendar_today,
                              'Fecha específica',
                              Colors.redAccent,
                            ),
                            InkWell(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: _boxDecorationStyle(),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      style: _headerStyle(),
                                      selectedDate == null
                                          ? 'Seleccionar'
                                          : DateFormat(
                                              'dd/MM/yyyy',
                                            ).format(selectedDate!),
                                    ),
                                    const Icon(Icons.event, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          if (shouldShowWeekDay) ...[
                            _buildLabel(
                              Icons.calendar_month,
                              'Día programado',
                              Colors.indigo,
                            ),
                            DropdownButtonFormField<String>(
                              style: _headerStyle(),
                              value: weekDay,
                              decoration: _inputDecoration(''),
                              items: weekDays
                                  .map(
                                    (d) => DropdownMenuItem(
                                      value: d,
                                      child: Text(d),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => weekDay = val!),
                            ),
                            const SizedBox(height: 20),
                          ],

                          _buildLabel(
                            Icons.access_time,
                            'Hora de inicio',
                            Colors.deepPurpleAccent,
                          ),
                          InkWell(
                            onTap: () => _selectTime(context),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: _boxDecorationStyle(),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedTime.format(context),
                                    style: _headerStyle(),
                                  ),
                                  Icon(
                                    Icons.schedule,
                                    color: Colors.red.shade200,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (shouldShowSpecialFields) ...[
                            const Divider(height: 20),
                            _buildLabel(
                              Icons.person,
                              'Predicadores',
                              Colors.green,
                            ),
                            CustomTextFormField(
                              labelText: 'Nombres (separados por coma)',
                              controller: _preacherController,
                            ),
                            const SizedBox(height: 20),
                            _buildLabel(
                              Icons.music_note,
                              'Ministro de Alabanza',
                              Colors.red.shade200,
                            ),
                            CustomTextFormField(
                              labelText: 'Nombres de los ministros',
                              controller: _ministerController,
                            ),
                            const SizedBox(height: 20),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Button(
                                size: Size(
                                  isMobile
                                      ? MediaQuery.of(context).size.width * 0.88
                                      : 170,
                                  isMobile ? 50 : 45,
                                ),
                                text: 'Guardar',
                                onPressed: _saveEvent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(IconData? icon, String text, Color colorIcon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          if (icon != null) Icon(icon, size: 16, color: colorIcon),
          if (icon != null) const SizedBox(width: 6),
          Text(text.toUpperCase(), style: _headerStyle()),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Colors.black54),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Colors.black54),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: primaryColor, width: 1),
      ),
    );
  }

  BoxDecoration _boxDecorationStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: Colors.black54),
    );
  }
}

class DateFormat {
  final String pattern;
  final String locale;
  DateFormat(this.pattern, [this.locale = '']);
  String format(DateTime date) =>
      "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
}

TextStyle _headerStyle() {
  return TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
}
