// lib/widgets/date.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateWidget extends StatelessWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  const DateWidget({
    Key? key,
    required this.initialDate,
    required this.onDateSelected,
  }) : super(key: key);

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,

      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
      selectableDayPredicate: (DateTime day) {
        return !day.isAfter(today);
      },
    );

    if (picked != null && picked != initialDate) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.yMMMMd('es_ES').format(initialDate);

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade400, width: 1.5),
        padding: EdgeInsets.all(20),
        elevation: 1,
      ),
      onPressed: () => _selectDate(context),
      icon: Icon(Icons.calendar_today, color: Colors.grey.shade700, size: 20),
      label: Text(
        formattedDate,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey.shade800,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
