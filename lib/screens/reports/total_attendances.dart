import 'dart:io' show File;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';
import '../../utils/download_stub.dart'
    if (dart.library.html) '../../utils/download_web.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_card_container.dart';
import '../../widgets/date_range.dart';
import '../../widgets/menu.dart';
import '../../widgets/search_text_field.dart';

class TotalAttendances extends StatefulWidget {
  const TotalAttendances({super.key});

  @override
  State<TotalAttendances> createState() => _TotalAttendancesState();
}

class _TotalAttendancesState extends State<TotalAttendances> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 90));
  DateTime _endDate = DateTime.now();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshReports();
    });
  }

  void _refreshReports() {
    final startStr = DateFormat('yyyy-MM-dd').format(_startDate);
    final endStr = DateFormat('yyyy-MM-dd').format(_endDate);

    Provider.of<AttendanceProvider>(
      context,
      listen: false,
    ).fetchGeneralReports(start: startStr, end: endStr);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final attendanceProvider = Provider.of<AttendanceProvider>(context);

    final filteredList = attendanceProvider.recordsList.where((r) {
      final matchesSearch =
          (r.definitionName?.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ??
          false);

      final recordDate = DateTime(r.date.year, r.date.month, r.date.day);
      final start = DateTime(_startDate.year, _startDate.month, _startDate.day);
      final end = DateTime(_endDate.year, _endDate.month, _endDate.day);

      final matchesDate =
          (recordDate.isAtSameMomentAs(start) || recordDate.isAfter(start)) &&
          (recordDate.isAtSameMomentAs(end) || recordDate.isBefore(end));

      return matchesSearch && matchesDate;
    }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(
        title: 'Reportes Generales',
        isDrawerEnabled: isMobile,
      ),
      drawer: isMobile ? const Drawer(child: Menu()) : null,
      body: Row(
        children: [
          if (!isMobile) const Menu(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildHeader(isMobile),
                  const SizedBox(height: 20),
                  Expanded(
                    child: attendanceProvider.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                            ),
                          )
                        : _buildSimpleList(filteredList),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _searchTextField(),
          const SizedBox(height: 15),
          _dateRange(),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(flex: 4, child: _searchTextField()),
        const SizedBox(width: 15),
        Expanded(flex: 5, child: _dateRange()),
      ],
    );
  }

  SearchTextField _searchTextField() {
    return SearchTextField(
      hintText: "Buscar reporte por evento...",
      onChanged: (val) => setState(() => _searchQuery = val),
    );
  }

  DateRange _dateRange() {
    return DateRange(
      startDate: _startDate,
      endDate: _endDate,
      onStartDateSelected: (date) {
        setState(() => _startDate = date);
        _refreshReports();
      },
      onEndDateSelected: (date) {
        setState(() => _endDate = date);
        _refreshReports();
      },
    );
  }

  Widget _buildSimpleList(List<AttendanceModel> records) {
    if (records.isEmpty)
      return const Center(child: Text("No se encontraron reportes."));

    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];

        return CustomCardContainer(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.folder_copy_rounded,
              color: Colors.blue,
              size: 30,
            ),
            title: Text(
              record.definitionName ?? 'Evento General',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              DateFormat('EEEE, d MMMM yyyy', 'es').format(record.date),
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.picture_as_pdf,
                color: negativeColor,
                size: 30,
              ),
              tooltip: "Descargar Reporte General",
              onPressed: () => _downloadGeneralPdf(record),
            ),
          ),
        );
      },
    );
  }

  Future<void> _downloadGeneralPdf(AttendanceModel record) async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();

    if (!mounted) return;

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preparando reporte...'),
        duration: Duration(minutes: 1),
      ),
    );

    try {
      final token = await secureStorage.read(key: 'auth_token');
      final dio = Dio();

      final String formattedDate = DateFormat('yyyy-MM-dd').format(record.date);
      final String eventName = record.definitionName ?? "";
      final String? definitionId = record.definitionId;

      const String url =
          'https://vri-secretary-backend-production.up.railway.app/api/v1/general-attendances/pdf';

      final response = await dio.get(
        url,
        queryParameters: {
          'date': formattedDate,
          'eventName': eventName,
          'definitionId': definitionId,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          responseType: ResponseType.bytes,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      }

      final fileName =
          "Reporte_General_${eventName.replaceAll(' ', '_')}_$formattedDate.pdf";

      if (kIsWeb) {
        WebDownloadHelper.downloadWebFile(response.data, fileName);
      } else {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.data);
        await OpenFilex.open(filePath);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Reporte generado con éxito!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar reporte: $e'),
            backgroundColor: negativeColor,
          ),
        );
      }
    }
  }
}
