import 'package:flutter/material.dart';

class CustomWebTable<T> extends StatelessWidget {
  final List<T> items;
  final List<String> columnLabels;
  final List<DataCell> Function(T item) rowBuilder;
  final double? columnSpacing;
  final Color? headerColor;

  const CustomWebTable({
    super.key,
    required this.items,
    required this.columnLabels,
    required this.rowBuilder,
    this.columnSpacing,
    this.headerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 3),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(15), // Radio de los bordes
        border: Border.all(color: Colors.grey.shade500, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Theme(
            data: Theme.of(
              context,
            ).copyWith(dividerColor: Colors.grey.shade300),
            child: DataTable(
              showCheckboxColumn: false,
              headingRowColor: WidgetStateProperty.all(
                headerColor ?? Colors.blue.shade100,
              ),
              headingRowHeight: 45,
              dataRowMinHeight: 40,
              dataRowMaxHeight: 50,
              columnSpacing: columnSpacing ?? 40,
              horizontalMargin: 20,
              columns: columnLabels.map((label) {
                return DataColumn(
                  label: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                );
              }).toList(),
              rows: List<DataRow>.generate(items.length, (index) {
                final item = items[index];
                return DataRow(
                  color: WidgetStateProperty.resolveWith<Color?>((states) {
                    if (index.isOdd)
                      return Colors.grey.shade50.withOpacity(0.5);
                    return null;
                  }),
                  cells: rowBuilder(item),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
