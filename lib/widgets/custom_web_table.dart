import 'package:flutter/material.dart';

import '../colors.dart';
import '../utils/window_size.dart';
import 'custom_card_container.dart';

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
    if (context.isCompact) {
      return _buildCardList(context);
    }
    return _buildDataTable(context);
  }

  /// Layout compacto (móvil): cada fila se renderiza como una tarjeta apilada
  /// con pares etiqueta: valor, derivados de los mismos `columnLabels` y celdas
  /// que usa la `DataTable`.
  Widget _buildCardList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List<Widget>.generate(items.length, (index) {
        final cells = rowBuilder(items[index]);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CustomCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List<Widget>.generate(columnLabels.length, (i) {
                final value = i < cells.length
                    ? cells[i].child
                    : const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: i == columnLabels.length - 1 ? 0 : 8,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        columnLabels[i],
                        style: const TextStyle(
                          color: secondaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: value,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        );
      }),
    );
  }

  /// Layout estándar (web/tablet): `DataTable` plana con borde hairline.
  Widget _buildDataTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: secondaryBackground,
        borderRadius: BorderRadius.circular(12), // Radio de los bordes
        border: Border.all(color: alternateColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicWidth(
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: alternateColor),
              child: DataTable(
                showCheckboxColumn: false,
                headingRowColor: WidgetStateProperty.all(
                  headerColor ?? accent1,
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
                      if (index.isOdd) return surfaceSubtle;
                      return null;
                    }),
                    cells: rowBuilder(item),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
