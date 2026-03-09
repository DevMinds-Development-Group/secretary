import 'package:flutter/material.dart';

class CustomWebTable<T> extends StatelessWidget {
  final List<T> items;
  final List<String> columnLabels;
  final List<DataCell> Function(T item) rowBuilder;
  final double? columnSpacing;

  const CustomWebTable({
    super.key,
    required this.items,
    required this.columnLabels,
    required this.rowBuilder,
    this.columnSpacing,
  });

  TextStyle _headerStyle() {
    return const TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
  }

  TextStyle _dataStyle() {
    return const TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 14,
      color: Colors.black87,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.grey.shade200,
            dataTableTheme: DataTableThemeData(dataTextStyle: _dataStyle()),
          ),
          child: DataTable(
            showCheckboxColumn: false,
            dataTextStyle: _dataStyle(),
            headingTextStyle: _headerStyle(),

            columnSpacing:
                columnSpacing ?? MediaQuery.of(context).size.width * 0.05,
            columns: columnLabels.map((label) {
              return DataColumn(label: Text(label, style: _headerStyle()));
            }).toList(),
            rows: items.map((item) {
              return DataRow(selected: false, cells: rowBuilder(item));
            }).toList(),
          ),
        ),
      ),
    );
  }
}
