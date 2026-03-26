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
    bool isMobile = MediaQuery.of(context).size.width < 700;

    return isMobile
        ? Center(
            child: SizedBox(
              width:
                  MediaQuery.of(context).size.width *
                  0.90, // <--- 90% del ancho
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateSelector(
                    "Desde:",
                    startDate,
                    onStartDateSelected,
                    context,
                  ),
                  const SizedBox(height: 15),
                  _buildDateSelector(
                    "Hasta:",
                    endDate,
                    onEndDateSelected,
                    context,
                  ),
                ],
              ),
            ),
          )
        : Row(
            children: [
              // Usamos Flexible para que en Web ocupen espacio equitativo
              Expanded(
                child: _buildDateSelector(
                  "Desde:",
                  startDate,
                  onStartDateSelected,
                  context,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildDateSelector(
                  "Hasta:",
                  endDate,
                  onEndDateSelected,
                  context,
                ),
              ),
            ],
          );
  }

  // Unificamos el constructor de cada selector para evitar errores
  Widget _buildDateSelector(
    String label,
    DateTime date,
    Function(DateTime) onSelected,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: DateWidget(
            initialDate: date,
            onDateSelected: (picked) {
              // Validación lógica de fechas
              if (label == "Hasta:" && picked.isBefore(startDate)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("La fecha 'Hasta' no puede ser anterior"),
                  ),
                );
                return;
              }
              onSelected(picked);
            },
          ),
        ),
      ],
    );
  }
}
