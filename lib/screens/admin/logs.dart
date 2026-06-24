import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/log_model.dart';
import '../../providers/log_provider.dart';
import '../../widgets/custom_web_table.dart';
import '../../widgets/nav_shell.dart';
import '../../widgets/pagination.dart';
import '../../widgets/states/app_skeleton.dart';
import '../../widgets/states/empty_state.dart';
import '../../widgets/states/error_state.dart';

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
        return NavShell(
          isSecondary: true,
          title: isMobile ? 'Registros Actividad' : 'Registros de Actividad',
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => logProvider.fetchLogs(),
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Expanded(
                    child: logProvider.isLoading
                        ? const AppSkeleton.list()
                        : logProvider.error != null
                        ? ErrorState(
                            error: logProvider.error,
                            onRetry: () => logProvider.fetchLogs(),
                          )
                        : logProvider.logs.isEmpty
                        ? const EmptyState(
                            icon: Icons.history,
                            title: 'No hay registros de actividad',
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
          color: cardColor,
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

  Widget _buildWebLayout(BuildContext context, List<Log> logs) {
    return SingleChildScrollView(
      // physics asegura que el RefreshIndicator funcione en Web
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(),
          child: CustomWebTable<Log>(
            items: logs,
            columnLabels: const [
              'Fecha',
              'Usuario',
              'Módulo',
              'Acción',
              'Detalles',
            ],

            columnSpacing: MediaQuery.of(context).size.width * 0.1,
            rowBuilder: (logEntry) {
              final formattedDate = DateFormat(
                'dd/MM/yyyy, HH:mm',
              ).format(logEntry.timestamp);

              return [
                DataCell(Text(formattedDate, style: _textStyle())),
                DataCell(Text(logEntry.username, style: _textStyle())),
                DataCell(Text(logEntry.module, style: _textStyle())),
                DataCell(
                  Text(
                    logEntry.action.replaceAll('_', ' '),
                    style: _textStyle(),
                  ),
                ),
                DataCell(
                  Tooltip(
                    message: logEntry.details,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Text(
                        logEntry.details,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: _textStyle(),
                      ),
                    ),
                  ),
                ),
              ];
            },
          ),
        ),
      ),
    );
  }

  TextStyle _textStyle() {
    return const TextStyle(fontSize: 14);
  }
}
