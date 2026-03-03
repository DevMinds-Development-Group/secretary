import 'package:app/models/service_model.dart';
import 'package:app/providers/service_type_provider.dart';
import 'package:app/widgets/custom_appbar.dart';
import 'package:app/widgets/custom_text_form_field.dart';
import 'package:app/widgets/small_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../colors.dart';
import '../../models/member_model.dart';
import '../../providers/service_provider.dart';
import '../../widgets/menu.dart';

class CreateOtherService extends StatefulWidget {
  final ServiceModel? serviceToEdit;
  const CreateOtherService({super.key, this.serviceToEdit});

  @override
  State<CreateOtherService> createState() => _CreateOtherServiceState();
}

class _CreateOtherServiceState extends State<CreateOtherService> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay? _selectedStartTime;
  DateTime? _rangeStartDay;
  DateTime? _rangeEndDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStartDay = null;
        _rangeEndDay = null;
      });
    }
    _showServiceForm(context, selectedDay);
  }

  // Este método es usado por el calendario y debe quedarse aquí.
  List<ServiceModel> _getEventsForDay(DateTime day) {
    return Provider.of<ServiceProvider>(
      context,
      listen: false,
    ).getEventsForDay(day);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    // Usamos un Consumer aquí para que la lista de 'Hoy' se actualice.
    return Consumer<ServiceProvider>(
      builder: (context, serviceProvider, child) {
        final todayEvents = serviceProvider.getEventsForDay(DateTime.now());

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: CustomAppBar(title: 'Crear otro evento'),
          drawer: isMobile ? Drawer(child: Menu()) : null,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMobile) const SizedBox(child: Menu()),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: isMobile
                      ? Column(
                          children: [
                            _buildCalendar(isMobile, context),
                            const SizedBox(height: 32),
                            _buildServices(
                              todayEvents,
                            ), // Pasamos la lista reactiva
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildCalendar(isMobile, context)),
                            const SizedBox(width: 50),
                            Expanded(
                              child: _buildServices(todayEvents),
                            ), // Pasamos la lista reactiva
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // El método ahora recibe la lista de eventos como parámetro.
  Widget _buildServices(List<ServiceModel> todayEvents) {
    return Column(
      children: [
        const Text(
          'Hoy',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (todayEvents.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'No hay eventos programados para hoy.',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: todayEvents.length,
            itemBuilder: (context, index) {
              final event = todayEvents[index];
              final formattedTime = event.time.format(context);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildServiceListItem(
                  Icons.schedule,
                  event.title,
                  formattedTime,
                ),
              );
            },
          ),
      ],
    );
  }

  // El resto de los métodos se quedan como estaban, ya que ahora tienen acceso a las variables de estado.
  Column _buildCalendar(bool isMobile, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Calendario',
            style: TextStyle(
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          color: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: TableCalendar<ServiceModel>(
              locale: 'es_ES',
              eventLoader: _getEventsForDay,
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              rangeStartDay: _rangeStartDay,
              rangeEndDay: _rangeEndDay,
              calendarFormat: _calendarFormat,
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    final tooltipMessage = events
                        .map(
                          (e) => '${e.title} a las ${e.time.format(context)}',
                        )
                        .join('\n');
                    return Tooltip(
                      message: tooltipMessage,
                      child: Container(
                        margin: const EdgeInsets.only(top: 30),
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red[700],
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceListItem(IconData icon, String title, String time) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, size: 35, color: Colors.black87),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(time, style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }

  Future<TimeOfDay?> _showCustomTimePickerDialog(
    BuildContext context,
    TimeOfDay? initialTime,
  ) async {
    int selectedHour = initialTime?.hourOfPeriod ?? 12;
    if (selectedHour == 0) selectedHour = 12;
    int selectedMinute = initialTime?.minute ?? 0;
    String selectedPeriod =
        (initialTime?.period ?? DayPeriod.am) == DayPeriod.am ? 'AM' : 'PM';

    return await showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Seleccionar hora'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DropdownButton<int>(
                    value: selectedHour,
                    items: List.generate(12, (i) => i + 1)
                        .map(
                          (h) => DropdownMenuItem(
                            value: h,
                            child: Text(h.toString().padLeft(2, '0')),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => selectedHour = value);
                    },
                  ),
                  const Text(
                    ':',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<int>(
                    value: selectedMinute,
                    items: List.generate(60, (i) => i)
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(m.toString().padLeft(2, '0')),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => selectedMinute = value);
                    },
                  ),
                  ToggleButtons(
                    isSelected: [
                      selectedPeriod == 'AM',
                      selectedPeriod == 'PM',
                    ],
                    onPressed: (index) => setState(
                      () => selectedPeriod = index == 0 ? 'AM' : 'PM',
                    ),
                    children: const [Text('AM'), Text('PM')],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(null),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                SmallButton(
                  onPressed: () {
                    int hour24 = selectedHour;
                    if (selectedPeriod == 'PM' && selectedHour != 12)
                      hour24 += 12;
                    if (selectedPeriod == 'AM' && selectedHour == 12)
                      hour24 = 0;
                    Navigator.of(
                      dialogContext,
                    ).pop(TimeOfDay(hour: hour24, minute: selectedMinute));
                  },
                  text: 'Aceptar',
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showServiceForm(
    BuildContext context,
    DateTime selectedDay,
  ) async {
    final TextEditingController predicadorController = TextEditingController();
    final TextEditingController alabanzaController = TextEditingController();
    TimeOfDay? dialogSelectedTime = _selectedStartTime;
    Member? selectedPreacherMember;
    Member? selectedWorshipMinisterMember;

    final serviceTypeProvider = Provider.of<ServiceTypeProvider>(
      context,
      listen: false,
    );
    final serviceNames = serviceTypeProvider.serviceTypes
        .map((type) => type.name)
        .toList();

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        bool isMobile = MediaQuery.of(context).size.width < 700;
        String? selectedTitle;
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: Center(
                child: Text(
                  'Nuevo evento el ${selectedDay.day}/${selectedDay.month}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 20 : 24,
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Nombre del evento',
                      ),
                      value: selectedTitle,
                      hint: const Text('Selecciona un tipo'),
                      items: serviceNames
                          .map(
                            (name) => DropdownMenuItem<String>(
                              value: name,
                              child: Text(name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          dialogSetState(() => selectedTitle = value),
                      validator: (value) =>
                          value == null ? 'Selecciona un nombre' : null,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final TimeOfDay? selectedTime =
                            await _showCustomTimePickerDialog(
                              context,
                              dialogSelectedTime,
                            );
                        if (selectedTime != null) {
                          dialogSetState(
                            () => dialogSelectedTime = selectedTime,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dialogSelectedTime != null
                                  ? 'Hora de inicio: ${dialogSelectedTime!.format(context)}'
                                  : 'Seleccionar hora de inicio',
                              style: TextStyle(
                                color: dialogSelectedTime != null
                                    ? Colors.black87
                                    : Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                            const Icon(Icons.access_time),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(labelText: 'Detalles', maxLines: 3),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                SmallButton(
                  onPressed: () {
                    if (dialogSelectedTime != null &&
                        selectedTitle != null &&
                        predicadorController.text.isNotEmpty &&
                        alabanzaController.text.isNotEmpty) {
                      final newService = ServiceModel(
                        id: '',
                        title: selectedTitle!,
                        date: selectedDay,
                        time: dialogSelectedTime!,
                        preacher: predicadorController.text,
                        worshipMinister: alabanzaController.text,
                      );
                      Provider.of<ServiceProvider>(
                        context,
                        listen: false,
                      ).addService(newService);
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Servicio guardado correctamente.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, completa todos los campos'),
                        ),
                      );
                    }
                  },
                  text: 'Guardar',
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      predicadorController.dispose();
      alabanzaController.dispose();
    });
  }
}
