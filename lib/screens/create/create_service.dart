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

  // Estados del formulario vinculados al modelo
  String nombre = '';
  String descripcion = '';
  String tipo = 'CULTO';
  bool esRecurrente = false;
  DateTime? fecha = DateTime.now();
  TimeOfDay hora = const TimeOfDay(hour: 18, minute: 0);
  String diaSemana = 'LUNES';

  // Controladores para predicadores y ministros (se enviarán como listas)
  final TextEditingController _predicadorController = TextEditingController();
  final TextEditingController _ministroController = TextEditingController();

  final List<String> tipos = ['CULTO', 'REUNION', 'EVENTO', 'OTRO'];
  final List<String> dias = [
    'LUNES',
    'MARTES',
    'MIÉRCOLES',
    'JUEVES',
    'VIERNES',
    'SÁBADO',
    'DOMINGO',
  ];

  // REGLAS DE NEGOCIO
  bool get mostrarFecha => !esRecurrente;
  bool get mostrarDiaSemana => esRecurrente;
  bool get mostrarCamposEspeciales => tipo == 'CULTO' || tipo == 'EVENTO';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fecha ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => fecha = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: hora,
    );
    if (picked != null) setState(() => hora = picked);
  }

  void _guardarEvento() async {
    if (_formKey.currentState!.validate()) {
      final serviceProvider = Provider.of<ServiceProvider>(
        context,
        listen: false,
      );

      // Creamos el objeto basado en tu ServiceModel
      final nuevoServicio = ServiceModel(
        id: '', // El backend genera el ID
        title: nombre,
        description: descripcion,
        type: tipo,
        date: fecha ?? DateTime.now(),
        time: hora,
        // Convertimos el texto separado por comas en lista si es necesario,
        // o tomamos el valor único según tu lógica de backend
        preachers: _predicadorController.text.isNotEmpty
            ? _predicadorController.text
                  .split(',')
                  .map((e) => e.trim())
                  .toList()
            : [],
        worshipMinistries: _ministroController.text.isNotEmpty
            ? _ministroController.text.split(',').map((e) => e.trim()).toList()
            : [],
      );

      // Aquí llamarías a tu método del provider (debes implementarlo en el provider)
      // bool success = await serviceProvider.createService(nuevoServicio);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Procesando registro...'),
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
            SizedBox(height: 40),
            SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: Card(
                    color: Colors.white,
                    elevation: 5,

                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(
                              Icons.edit_calendar,
                              'Nombre del Servicio',
                            ),
                            CustomTextFormField(
                              labelText: 'Ej: Culto de Adoración',
                              validator: (val) =>
                                  val!.isEmpty ? 'Campo requerido' : null,
                              onChanged: (val) => setState(() => nombre = val),
                            ),
                            const SizedBox(height: 20),
                            _buildLabel(Icons.description, 'Descripción'),
                            CustomTextFormField(
                              labelText: 'Detalles adicionales...',
                              onChanged: (val) =>
                                  setState(() => descripcion = val),
                            ),
                            const SizedBox(height: 20),
                            _buildLabel(Icons.category, 'Tipo de Actividad'),
                            DropdownButtonFormField<String>(
                              value: tipo,
                              decoration: _inputDecoration(''),
                              items: tipos
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(t),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) => setState(() => tipo = val!),
                            ),
                            const SizedBox(height: 30),
                            // Switch Recurrente
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.black54),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.repeat, color: primaryColor),
                                      SizedBox(width: 10),
                                      Text(
                                        '¿Es Recurrente?',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Switch(
                                    value: esRecurrente,
                                    activeColor: primaryColor,
                                    onChanged: (val) =>
                                        setState(() => esRecurrente = val),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            if (mostrarFecha) ...[
                              _buildLabel(
                                Icons.calendar_today,
                                'Fecha específica',
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
                                        fecha == null
                                            ? 'Seleccionar'
                                            : DateFormat(
                                                'dd/MM/yyyy',
                                              ).format(fecha!),
                                      ),
                                      const Icon(
                                        Icons.event,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            if (mostrarDiaSemana) ...[
                              _buildLabel(
                                Icons.calendar_month,
                                'Día programado',
                              ),
                              DropdownButtonFormField<String>(
                                value: diaSemana,
                                decoration: _inputDecoration(''),
                                items: dias
                                    .map(
                                      (d) => DropdownMenuItem(
                                        value: d,
                                        child: Text(d),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => diaSemana = val!),
                              ),
                              const SizedBox(height: 20),
                            ],

                            _buildLabel(Icons.access_time, 'Hora de inicio'),
                            InkWell(
                              onTap: () => _selectTime(context),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: _boxDecorationStyle(),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(hora.format(context)),
                                    const Icon(
                                      Icons.schedule,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (mostrarCamposEspeciales) ...[
                              const Divider(height: 20),
                              _buildLabel(Icons.person, 'Predicadores'),
                              TextFormField(
                                controller: _predicadorController,
                                decoration: _inputDecoration(
                                  'Nombres (separados por coma)',
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildLabel(
                                Icons.music_note,
                                'Ministerios de Alabanza',
                              ),
                              TextFormField(
                                controller: _ministroController,
                                decoration: _inputDecoration(
                                  'Nombres de los ministerios',
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Button(
                                  size: Size(
                                    isMobile
                                        ? MediaQuery.of(context).size.width *
                                              0.88
                                        : 130,
                                    isMobile ? 50 : 45,
                                  ),
                                  text: 'Guardar',
                                  onPressed: _guardarEvento,
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
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(IconData? icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          if (icon != null)
            Icon(icon, size: 16, color: const Color(0xFF45566E)),
          if (icon != null) const SizedBox(width: 6),
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 1.1,
            ),
          ),
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

// Helper simple para formatear fecha si no usas intl
class DateFormat {
  final String pattern;
  final String locale;
  DateFormat(this.pattern, [this.locale = '']);
  String format(DateTime date) =>
      "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
}
