import 'package:Koinos/colors.dart';
import 'package:flutter/material.dart';

import '../models/apostol_dashboard_model.dart';

/// Desglose por iglesia del informe consolidado del Ministerio.
///
/// No aparece al descender a una iglesia: allí el informe ya es el de esa
/// congregación y un desglose de una sola fila no dice nada.
class ChurchBreakdownTable extends StatelessWidget {
  final ConsolidatedSection consolidated;

  const ChurchBreakdownTable({super.key, required this.consolidated});

  @override
  Widget build(BuildContext context) {
    if (consolidated.churches.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_outlined, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Desglose por iglesia',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text('${consolidated.churchCount} iglesias'),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Iglesia')),
                  DataColumn(label: Text('Miembros'), numeric: true),
                  DataColumn(label: Text('Redes'), numeric: true),
                  DataColumn(label: Text('Ministerios'), numeric: true),
                  DataColumn(label: Text('Asistencia'), numeric: true),
                  DataColumn(label: Text('Visitas'), numeric: true),
                  DataColumn(label: Text('Conversiones'), numeric: true),
                ],
                rows: consolidated.churches
                    .map(
                      (church) => DataRow(
                        cells: [
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(church.churchName),
                                if (!church.enabled)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: Text(
                                      'deshabilitada',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: negativeColor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          DataCell(Text('${church.members}')),
                          DataCell(Text('${church.networks}')),
                          DataCell(Text('${church.ministries}')),
                          DataCell(Text('${church.memberAttendance}')),
                          DataCell(Text('${church.visitors}')),
                          DataCell(Text('${church.newConverts}')),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
