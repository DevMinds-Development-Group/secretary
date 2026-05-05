import 'dart:io' show File;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener intl en pubspec.yaml
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';
import '../../utils/download_stub.dart'
    if (dart.library.html) '../../utils/download_web.dart';
import '../../widgets/action_buttons.dart';
import '../../widgets/button.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/date.dart';
import '../../widgets/menu.dart';
import '../../widgets/pagination.dart';
import '../../widgets/search_text_field.dart';
import '../../widgets/showDeleteConfirmationDialog.dart';
import 'attendance.dart';
import 'attendance_details.dart';

class AttendanceHistory extends StatefulWidget {
  const AttendanceHistory({super.key});

  @override
  State<AttendanceHistory> createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {
  DateTime? _filterDate;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AttendanceProvider>(
        context,
        listen: false,
      ).fetchAttendanceHistory();
    });
  }

  Future<void> _downloadPdf(String recordId) async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();

    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preparando descarga...'),
        duration: Duration(minutes: 1),
      ),
    );

    try {
      final token = await secureStorage.read(key: 'auth_token');
      final url =
          'https://vri-secretary-backend-production.up.railway.app/api/v1/event-attendances/$recordId/pdf';
      final dio = Dio();

      final response = await dio.get(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          responseType: ResponseType.bytes,
        ),
      );

      if (mounted) ScaffoldMessenger.of(context).removeCurrentSnackBar();

      if (kIsWeb) {
        WebDownloadHelper.downloadWebFile(
          response.data,
          "asistencia_$recordId.pdf",
        );
      } else {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/asistencia_$recordId.pdf';
        final file = File(filePath);
        await file.writeAsBytes(response.data);
        await OpenFilex.open(filePath);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Descarga completada!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: negativeColor),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final provider = Provider.of<AttendanceProvider>(context);

    final records = provider.recordsList.where((r) {
      final matchesSearch =
          (r.definitionName?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false) ||
          (r.networkName?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false);

      final matchesDate =
          _filterDate == null ||
          (r.date.year == _filterDate!.year &&
              r.date.month == _filterDate!.month &&
              r.date.day == _filterDate!.day);

      return matchesSearch && matchesDate;
    }).toList();

    records.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Asistencias', isDrawerEnabled: isMobile),
      drawer: isMobile ? Drawer(child: Menu()) : null,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 15 : 0),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (!isMobile) Menu(),
                    Expanded(
                      child: Column(
                        children: [
                          _buildHeader(isMobile),
                          const SizedBox(height: 20),
                          Expanded(
                            child: _buildRecordsList(
                              records,
                              provider.isLoading,
                            ),
                          ),
                          SizedBox(height: 10),
                          if (provider.totalPages > 0 && !provider.isLoading)
                            Pagination(
                              currentPage: provider.currentPage,
                              totalPages: provider.totalPages,
                              itemsPerPage: provider.pageSize,
                              onPageChanged: (page) =>
                                  provider.onPageChanged(page),
                              onItemsPerPageChanged: (size) =>
                                  provider.onItemsPerPageChanged(size),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 5 : 16),
      child: isMobile
          ? Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: SearchTextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  child: _dateWidget(),
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: 60,
                ),
                const SizedBox(height: 15),
                Button(
                  text: 'Tomar Asistencia',
                  size: Size(
                    MediaQuery.of(context).size.width * 0.95,
                    isMobile ? 50 : 45,
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Attendance(),
                      ),
                    );
                    if (mounted) {
                      Provider.of<AttendanceProvider>(
                        context,
                        listen: false,
                      ).fetchAttendanceHistory();
                    }
                  },
                  icon: Icons.how_to_reg,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: SearchTextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 15),
                _dateWidget(),
                const SizedBox(width: 15),
                Button(
                  text: 'Tomar Asistencia',
                  size: Size(220, isMobile ? 50 : 45),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Attendance(),
                      ),
                    );
                    if (mounted) {
                      Provider.of<AttendanceProvider>(
                        context,
                        listen: false,
                      ).fetchAttendanceHistory();
                    }
                  },
                  icon: Icons.how_to_reg,
                ),
              ],
            ),
    );
  }

  DateWidget _dateWidget() {
    return DateWidget(
      initialDate: _filterDate ?? DateTime.now(),
      onDateSelected: (newDate) {
        setState(() => _filterDate = newDate);
      },
    );
  }

  void _handleDelete(BuildContext context, AttendanceModel record) async {
    final provider = Provider.of<AttendanceProvider>(context, listen: false);

    final success = await provider.deleteRecord(record.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Registro eliminado' : 'Error al eliminar'),
          backgroundColor: success ? accentColor : negativeColor,
        ),
      );
    }
  }

  Widget _buildRecordsList(List<AttendanceModel> records, bool isLoading) {
    if (isLoading)
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    if (records.isEmpty)
      return const Center(child: Text("No hay registros encontrados"));
    bool isMobile = MediaQuery.of(context).size.width < 700;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 10.0 : 20.0),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 3),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListView.separated(
          padding: EdgeInsets.all(5),
          itemCount: records.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final record = records[index];
            return ListTile(
              isThreeLine: (isMobile) ? true : false,
              leading: isMobile
                  ? null
                  : Icon(Icons.assignment_turned_in, color: Colors.green),
              title: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [_buildName(record), _buildNetwork(record)],
                    )
                  : Row(
                      children: [
                        _buildName(record),
                        const Text(' | ', style: TextStyle(fontSize: 16)),
                        _buildNetwork(record),
                      ],
                    ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, d MMMM yyyy', 'es').format(record.date),
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Presentes: ${record.presentMemberIds.length} | Visitas: ${record.visitorsCount} \nVisitas Pastorales: ${record.pastoralVisitsCount} \nNuevos convertidos: ${record.newConvert}',
                    style: TextStyle(fontSize: 16),
                  ),
                  if (isMobile) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _iconPdf(record),
                        _actionButtons(context, record),
                      ],
                    ),
                  ],
                ],
              ),
              trailing: isMobile
                  ? null
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _iconPdf(record),
                        _actionButtons(context, record),
                      ],
                    ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AttendanceDetail(record: record),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Text _buildNetwork(AttendanceModel record) {
    return Text(
      record.networkName ?? 'Sin Red',
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  Text _buildName(AttendanceModel record) {
    return Text(
      record.definitionName ?? 'Evento sin nombre',
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  ActionButtons _actionButtons(BuildContext context, AttendanceModel record) {
    return ActionButtons(
      onEdit: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Attendance(existingRecord: record),
          ),
        );
        if (mounted) {
          Provider.of<AttendanceProvider>(
            context,
            listen: false,
          ).fetchAttendanceHistory();
        }
      },
      onDelete: () {
        showDeleteConfirmationDialog(
          context: context,
          itemName: 'Asistencia del ${DateFormat('d/MM').format(record.date)}',
          onConfirm: () => _handleDelete(context, record),
        );
      },
    );
  }

  IconButton _iconPdf(AttendanceModel record) {
    return IconButton(
      icon: const Icon(Icons.picture_as_pdf, color: negativeColor),
      tooltip: 'Descargar PDF',
      onPressed: () => _downloadPdf(record.id),
    );
  }
}
