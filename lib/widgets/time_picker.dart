import 'package:Koinos/widgets/small_button.dart';
import 'package:flutter/material.dart';

class TimePicker extends StatefulWidget {
  final Function(TimeOfDay)? onTimeSelected;
  final TimeOfDay? initialTime;

  const TimePicker({super.key, required this.onTimeSelected, this.initialTime});

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  TimeOfDay? _selectedTime; // Cambiamos a nullable

  // Variables de estado para la hora, el minuto y AM/PM
  int? _selectedHour;
  int? _selectedMinute;
  String? _selectedAmPm;

  // Listas de opciones
  final List<int> _hours = List.generate(
    12,
    (index) => index == 0 ? 12 : index,
  ); // 1-12
  final List<int> _minutes = List.generate(60, (index) => index); // 0-59
  final List<String> _amPm = ['AM', 'PM'];

  @override
  void initState() {
    super.initState();
    // Inicializar el estado de la hora si ya hay una hora seleccionada
    if (_selectedTime != null) {
      _selectedHour = _selectedTime!.hourOfPeriod;
      _selectedMinute = _selectedTime!.minute;
      _selectedAmPm = _selectedTime!.period == DayPeriod.am ? 'AM' : 'PM';
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayTime = 'Seleccionar hora de inicio';
    if (_selectedTime != null) {
      final hour = _selectedTime!.hourOfPeriod == 0
          ? 12
          : _selectedTime!.hourOfPeriod;
      final minute = _selectedTime!.minute.toString().padLeft(2, '0');
      final period = _selectedTime!.period == DayPeriod.am ? 'AM' : 'PM';
      displayTime = '$hour:$minute $period';
    }

    return InkWell(
      onTap: () {
        _showCustomTimePicker(context);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.access_time),
        ),
        child: Text(displayTime, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  void _showCustomTimePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Seleccionar hora'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Selector de hora
                  DropdownButton<int>(
                    value: _selectedHour,
                    hint: const Text('Hora'),
                    items: _hours.map((int hour) {
                      return DropdownMenuItem<int>(
                        value: hour,
                        child: Text(hour.toString().padLeft(2, '0')),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedHour = newValue;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  const Text(':'),
                  const SizedBox(width: 10),
                  // Selector de minutos
                  DropdownButton<int>(
                    value: _selectedMinute,
                    hint: const Text('Min'),
                    items: _minutes.map((int minute) {
                      return DropdownMenuItem<int>(
                        value: minute,
                        child: Text(minute.toString().padLeft(2, '0')),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedMinute = newValue;
                      });
                    },
                  ),
                  const SizedBox(width: 20),
                  // Selector de AM/PM
                  DropdownButton<String>(
                    value: _selectedAmPm,
                    hint: const Text('AM/PM'),
                    items: _amPm.map((String ampm) {
                      return DropdownMenuItem<String>(
                        value: ampm,
                        child: Text(ampm),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedAmPm = newValue;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            SmallButton(
              onPressed: () {
                if (_selectedHour != null &&
                    _selectedMinute != null &&
                    _selectedAmPm != null) {
                  int hour24 = _selectedHour!;
                  if (_selectedAmPm == 'PM' && hour24 != 12) {
                    hour24 += 12;
                  }
                  if (_selectedAmPm == 'AM' && hour24 == 12) {
                    hour24 = 0;
                  }
                  final selectedTime = TimeOfDay(
                    hour: hour24,
                    minute: _selectedMinute!,
                  );
                  // Llama al callback para notificar al padre sobre la hora seleccionada
                  widget.onTimeSelected!(selectedTime);
                  Navigator.of(context).pop();
                }
              },
              text: 'Aceptar',
            ),
          ],
        );
      },
    );
  }
}
