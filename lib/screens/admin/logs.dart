// lib/screens/admin/logs.dart

import 'package:app/colors.dart';
import 'package:app/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/log_model.dart';
import '../../providers/log_provider.dart';
import '../../widgets/pagination.dart';

class Logs extends StatefulWidget {
  const Logs({Key? key}) : super(key: key);

  @override
  State<Logs> createState() => _LogsState();
}

class _LogsState extends State<Logs> {
  bool _isInitialLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 2. PROTEGER LA LLAMADA INICIAL
    // Solo ejecutaremos fetchLogs si es la carga inicial.
    // didChangeDependencies es un lugar más seguro que initState para esto.
    if (_isInitialLoad) {
      Provider.of<LogProvider>(context, listen: false).fetchLogs();
      // 3. DESACTIVAR LA BANDERA
      // Después de la primera llamada, ponemos la bandera en false
      // para que esto no se vuelva a ejecutar nunca más para esta pantalla.
      _isInitialLoad = false;
    }
  }

  @override
  void initState() {
    super.initState();

    // Cargar los datos iniciales sigue siendo correcto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LogProvider>(context, listen: false).fetchLogs();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LogProvider>(
      builder: (context, logProvider, child) {
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: CustomAppBar(title: 'Registros de Actividad'),
          body: RefreshIndicator(
            onRefresh: () => logProvider.fetchLogs(),
            child: Column(
              children: [
                SizedBox(height: 30),
                Expanded(
                  child: logProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : logProvider.logs.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay registros para mostrar.',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            return constraints.maxWidth < 700
                                ? _buildMobileLayout(logProvider.logs)
                                : _buildWebLayout(context, logProvider.logs);
                          },
                        ),
                ),

                if (logProvider.totalPages > 0 && !logProvider.isLoading)
                  Pagination(
                    currentPage: logProvider.currentPage,
                    totalPages: logProvider.totalPages,
                    itemsPerPage: logProvider.pageSize,

                    onPageChanged: (page) {
                      logProvider.onPageChanged(page);
                    },
                    onItemsPerPageChanged: (size) {
                      logProvider.onItemsPerPageChanged(size);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // El layout móvil ahora es un ListView simple, sin controller
  Widget _buildMobileLayout(List<Log> logs) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        final formattedDate = DateFormat(
          'dd/MM/yyyy, HH:mm',
        ).format(log.timestamp);
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: ListTile(
            title: Text(log.details),
            subtitle: Text(
              '${log.action.replaceAll('_', ' ')} por ${log.username}\n$formattedDate',
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  // El layout web ahora es un SingleChildScrollView simple, sin controller
  Widget _buildWebLayout(BuildContext context, List<Log> logs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1500),
          child: Card(
            elevation: 5,
            color: Colors.white,
            child: DataTable(
              columnSpacing: MediaQuery.of(context).size.width * 0.1,
              columns: [
                DataColumn(label: Text('Fecha', style: _headerStyle())),

                DataColumn(label: Text('Usuario', style: _headerStyle())),

                DataColumn(label: Text('Módulo', style: _headerStyle())),

                DataColumn(label: Text('Acción', style: _headerStyle())),
                DataColumn(label: Text('Detalles', style: _headerStyle())),
              ],
              rows: logs.map((log) {
                final formattedDate = DateFormat(
                  'dd/MM/yyyy HH:mm:ss',
                ).format(log.timestamp);
                return DataRow(
                  cells: [
                    DataCell(Text(formattedDate)),
                    DataCell(Text(log.username)),
                    DataCell(Text(log.module)),
                    DataCell(Text(log.action.replaceAll('_', ' '))),
                    DataCell(
                      SizedBox(
                        child: Text(log.details, maxLines: 2),
                        width: MediaQuery.of(context).size.width * 0.25,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _headerStyle() {
    return const TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
  }
}
