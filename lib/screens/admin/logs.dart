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

    if (_isInitialLoad) {
      Provider.of<LogProvider>(context, listen: false).fetchLogs();

      _isInitialLoad = false;
    }
  }

  @override
  void initState() {
    super.initState();

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
    bool isMobile = MediaQuery.of(context).size.width < 700;
    return Consumer<LogProvider>(
      builder: (context, logProvider, child) {
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: CustomAppBar(
            title: isMobile ? 'Registros Actividad' : 'Registros de Actividad',
          ),
          body: SafeArea(
            child: RefreshIndicator(
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
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
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
        final logEntry = logs[index];
        final formattedDate = DateFormat(
          'dd/MM/yyyy, HH:mm',
        ).format(logEntry.timestamp);
        return Card(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16.0),
          child: ListTile(
            title: Text(logEntry.details),
            subtitle: Text('$formattedDate'),
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
              rows: logs.map((logEntry) {
                final formattedDate = DateFormat(
                  'dd/MM/yyyy HH:mm:ss',
                ).format(logEntry.timestamp);
                return DataRow(
                  cells: [
                    DataCell(Text(formattedDate)),
                    DataCell(Text(logEntry.username)),
                    DataCell(Text(logEntry.module)),
                    DataCell(Text(logEntry.action.replaceAll('_', ' '))),
                    DataCell(
                      SizedBox(
                        child: Text(logEntry.details, maxLines: 2),
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
