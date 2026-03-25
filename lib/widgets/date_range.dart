import 'package:flutter/material.dart';

import 'date.dart';

class DateRange extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Function(DateTime) onStartDateSelected;
  final Function(DateTime) onEndDateSelected;

  const DateRange({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartDateSelected,
    required this.onEndDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                "Desde:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            DateWidget(
              initialDate: startDate,
              onDateSelected: (date) {
                // Ejecución segura
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onStartDateSelected(date);
                });
              },
            ),
          ],
        ),

        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  "Hasta:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              DateWidget(
                initialDate: endDate,
                onDateSelected: (picked) {
                  // Validación y ejecución segura
                  Future.microtask(() {
                    if (picked.isBefore(startDate)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "La fecha 'Hasta' no puede ser anterior a 'Desde'",
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    } else {
                      onEndDateSelected(picked);
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
