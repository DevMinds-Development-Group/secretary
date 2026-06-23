import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/member_model.dart';
import '../../models/service_model.dart';
import '../../providers/member_provider.dart';
import '../../providers/service_provider.dart';
import '../../theme/design_constants.dart';
import '../../utils/app_log.dart';
import '../../widgets/button.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/member_autocomplete_field.dart';
import '../../widgets/nav_shell.dart';
import '../../widgets/no_connection_widget.dart';

class CreateService extends StatefulWidget {
  final ServiceModel? serviceToEdit;

  const CreateService({super.key, this.serviceToEdit});

  @override
  State<CreateService> createState() => _CreateServiceState();
}

class _CreateServiceState extends State<CreateService> {
  String? selectedPreacherId;
  String? selectedMinisterId;

  final _formKey = GlobalKey<FormState>();

  late String name;
  late String description;
  late String type;
  late bool recurring;
  late DateTime? selectedDate;
  late TimeOfDay selectedTime;
  late int weekDay;

  late TextEditingController _preacherController;
  late TextEditingController _ministerController;

  Member? selectedPreacher;
  Member? selectedMinister;

  int _getDayNumber(dynamic day) {
    if (day == null) return 1;
    // Si ya es un número (int o String que representa un número)
    final parsed = int.tryParse(day.toString());
    if (parsed != null && parsed >= 1 && parsed <= 7) {
      return parsed;
    }

    return weekDaysMap.entries
        .firstWhere((entry) => entry.value == day.toString().toUpperCase())
        .key;
  }

  bool get _isEditing => widget.serviceToEdit != null;

  @override
  void initState() {
    super.initState();

    final isEditing = widget.serviceToEdit != null;
    final service = widget.serviceToEdit;

    name = isEditing ? service!.title : '';
    description = isEditing ? service!.description : '';
    type = isEditing ? service!.type : 'CULTO';
    recurring = (isEditing ? service?.recurring : false)!;
    selectedDate = isEditing ? service!.date : DateTime.now();
    selectedTime = isEditing
        ? service!.time
        : const TimeOfDay(hour: 18, minute: 0);
    weekDay = isEditing ? _getDayNumber(service!.weekDay) : 1;

    _preacherController = TextEditingController(
      text: isEditing ? service!.preachers.join(", ") : "",
    );
    _ministerController = TextEditingController(
      text: isEditing ? service!.worshipMinistries.join(", ") : "",
    );

    if (isEditing) {
      if (service!.preachers.isNotEmpty) {
        final p = service.preachers.first;
        _preacherController.text = '${p.name} ${p.lastName}'.trim();
        selectedPreacherId = p.id;
      }

      if (service.worshipMinistries.isNotEmpty) {
        final m = service.worshipMinistries.first;
        _ministerController.text = '${m.name} ${m.lastName}'.trim();
        selectedMinisterId = m.id;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      appLog("!!! EJECUTANDO CARGA DE MIEMBROS DESDE CREATE_SERVICE !!!");
      Provider.of<MemberProvider>(context, listen: false).fetchMembers();
    });
  }

  final List<String> serviceTypes = ['CULTO', 'REUNION', 'EVENTO', 'OTRO'];

  final Map<int, String> weekDaysMap = {
    1: 'LUNES',
    2: 'MARTES',
    3: 'MIÉRCOLES',
    4: 'JUEVES',
    5: 'VIERNES',
    6: 'SÁBADO',
    7: 'DOMINGO',
  };

  // String _getDayName(dynamic day) {
  //   if (day == null) return 'LUNES';
  //
  //   switch (day.toString()) {
  //     case '1':
  //       return 'LUNES';
  //     case '2':
  //       return 'MARTES';
  //     case '3':
  //       return 'MIÉRCOLES';
  //     case '4':
  //       return 'JUEVES';
  //     case '5':
  //       return 'VIERNES';
  //     case '6':
  //       return 'SÁBADO';
  //     case '7':
  //       return 'DOMINGO';
  //     default:
  //       return day.toString().toUpperCase(); // Por si ya viene como String
  //   }
  // }

  // BUSINESS RULES (Visibility logic)
  bool get shouldShowDate => !recurring;
  bool get shouldShowWeekDay => recurring;
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
      final isEditing = widget.serviceToEdit != null;

      final serviceData = ServiceModel(
        id: isEditing ? widget.serviceToEdit!.id : '',
        title: name,
        description: description,
        type: type,
        recurring: recurring,
        weekDay: weekDay.toString(),
        date: selectedDate ?? DateTime.now(),
        time: selectedTime,

        preacherIds: selectedPreacherId != null ? [selectedPreacherId!] : [],
        worshipMinistryIds: selectedMinisterId != null
            ? [selectedMinisterId!]
            : [],
      );

      bool success;
      if (isEditing) {
        success = await serviceProvider.updateService(serviceData);
      } else {
        success = await serviceProvider.addService(serviceData);
      }

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Servicio actualizado con éxito'
                  : 'Servicio creado con éxito',
            ),
            backgroundColor: accentColor,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(serviceProvider.error ?? 'Error al guardar'),
            backgroundColor: negativeColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    final serviceProvider = context.watch<ServiceProvider>();
    final memberProvider = context.watch<MemberProvider>();

    if (serviceProvider.error == "SIN_CONEXION" ||
        memberProvider.error == "SIN_CONEXION") {
      return NavShell(
        isSecondary: true,
        title: _isEditing ? 'Editar servicio' : 'Crear servicio',
        body: NoConnectionWidget(
          onRefresh: () {
            serviceProvider.clearError();
            memberProvider.clearError();
            if (_isEditing) {
              serviceProvider.fetchServices();
            }
          },
        ),
      );
    }

    return NavShell(
      isSecondary: true,
      title: _isEditing ? 'Editar servicio' : 'Crear servicio',
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: isMobile ? 20 : 40),
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isMobile
                        ? MediaQuery.of(context).size.width * 0.9
                        : 600,
                  ),
                  child: Card(
                    color: Theme.of(context).colorScheme.surface,
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Form(
                        key: _formKey,
                        autovalidateMode:
                            AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextFormField(
                              labelText: 'Nombre del Servicio',
                              isRequired: true,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) =>
                                  FocusScope.of(context).nextFocus(),
                              initialValue: name,
                              validator: (val) =>
                                  val!.isEmpty ? 'Campo requerido' : null,
                              onChanged: (val) => setState(() => name = val),
                            ),
                            const SizedBox(height: 20),
                            CustomTextFormField(
                              labelText: 'Descripción',
                              textInputAction: TextInputAction.done,
                              initialValue: description,
                              onChanged: (val) =>
                                  setState(() => description = val),
                            ),
                            const SizedBox(height: 20),
                            _buildLabel(
                              Icons.category,
                              'Tipo de Actividad',
                              primaryColor,
                            ),
                            DropdownButtonFormField<String>(
                              value: type,
                              isExpanded: true,
                              decoration: _inputDecoration(''),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 15,
                              ),
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
                              decoration: _boxDecorationStyle(),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                    value: recurring,
                                    activeColor: primaryColor,
                                    onChanged: (bool val) {
                                      setState(() {
                                        recurring = val;
                                        appLog(
                                          "DEBUG: Switch cambiado a $recurring",
                                        );
                                        if (recurring) {
                                          selectedDate = null;
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            if (shouldShowDate) ...[
                              _buildLabel(
                                Icons.calendar_today,
                                'Fecha',
                                negativeColor,
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
                                      const Icon(
                                        Icons.event,
                                        color: secondaryText,
                                      ),
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
                                primaryColor,
                              ),
                              DropdownButtonFormField<int>(
                                style: _headerStyle(),
                                value: weekDay,
                                isExpanded: true,
                                decoration: _inputDecoration(''),
                                items: weekDaysMap.entries.map((entry) {
                                  return DropdownMenuItem<int>(
                                    value: entry.key,
                                    child: Text(entry.value),
                                  );
                                }).toList(),
                                onChanged: (int? val) {
                                  if (val != null) {
                                    setState(() => weekDay = val);
                                  }
                                },
                              ),
                              const SizedBox(height: 20),
                            ],

                            _buildLabel(
                              Icons.access_time,
                              'Hora de inicio',
                              primaryColor,
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
                                      color: primaryColor2.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (shouldShowSpecialFields) ...[
                              const Divider(height: 30),
                              MemberAutocompleteField(
                                controller: _preacherController,
                                labelText: 'Predicador',
                                onMemberSelected: (member) {
                                  if (member != null) {
                                    setState(() {
                                      selectedPreacherId = member.id;
                                      _preacherController.text =
                                          '${member.name} ${member.lastName}'
                                              .trim();
                                    });
                                  } else
                                    selectedPreacherId = null;
                                },
                              ),
                              const SizedBox(height: 20),
                              MemberAutocompleteField(
                                controller: _ministerController,
                                labelText: 'Ministro de Alabanza',
                                onMemberSelected: (member) {
                                  if (member != null) {
                                    setState(() {
                                      selectedMinisterId = member.id;
                                      _ministerController.text =
                                          '${member.name} ${member.lastName}'
                                              .trim();
                                    });
                                  } else
                                    selectedMinisterId = null;
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Button(
                                  size: Size(
                                    isMobile
                                        ? MediaQuery.of(context).size.width *
                                              0.7
                                        : 130,
                                    isMobile ? 50 : 45,
                                  ),
                                  text: widget.serviceToEdit != null
                                      ? 'Actualizar'
                                      : 'Guardar',
                                  isLoading: serviceProvider.isLoading,
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
      fillColor: secondaryBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          DesignConstants.borderRadiusDropdown,
        ),
        borderSide: const BorderSide(color: primaryColor, width: 1),
      ),
    );
  }

  BoxDecoration _boxDecorationStyle() {
    return BoxDecoration(
      color: secondaryBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: alternateColor),
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
  return TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: primaryText,
  );
}
