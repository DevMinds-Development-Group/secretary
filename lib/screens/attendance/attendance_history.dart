import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';
import '../../theme/design_constants.dart';
import '../../utils/download_stub.dart'
    if (dart.library.html) '../../utils/download_web.dart';
import '../../utils/window_size.dart';
import '../../widgets/attendance_card.dart';
import '../../widgets/body_width.dart';
import '../../widgets/button.dart';
import '../../widgets/date.dart';
import '../../widgets/nav_destinations.dart';
import '../../widgets/nav_shell.dart';
import '../../widgets/pagination.dart';
import '../../widgets/search_text_field.dart';
import '../../widgets/showDeleteConfirmationDialog.dart';
import '../../widgets/states/app_skeleton.dart';
import '../../widgets/states/empty_state.dart';
import '../../widgets/states/error_state.dart';
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
            backgroundColor: accentColor,
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

  void _confirmDelete(AttendanceModel record) {
    showDeleteConfirmationDialog(
      context: context,
      itemName:
          'Asistencia del ${record.date.day}/${record.date.month}',
      onConfirm: () => _handleDelete(context, record),
    );
  }

  Future<void> _editRecord(AttendanceModel record) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => Attendance(existingRecord: record)),
    );
    if (mounted) {
      Provider.of<AttendanceProvider>(
        context,
        listen: false,
      ).fetchAttendanceHistory();
    }
  }

  Future<void> _takeAttendance() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const Attendance()),
    );
    if (mounted) {
      Provider.of<AttendanceProvider>(
        context,
        listen: false,
      ).fetchAttendanceHistory();
    }
  }

  void _openDetails(AttendanceModel record) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AttendanceDetail(record: record)),
    );
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;
    final provider = Provider.of<AttendanceProvider>(context);

    final records = provider.recordsList.where((r) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch =
          (r.definitionName?.toLowerCase().contains(q) ?? false) ||
              (r.networkName?.toLowerCase().contains(q) ?? false);
      final matchesDate = _filterDate == null ||
          (r.date.year == _filterDate!.year &&
              r.date.month == _filterDate!.month &&
              r.date.day == _filterDate!.day);
      return matchesSearch && matchesDate;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return NavShell(
      current: NavSection.attendance,
      title: 'Asistencia',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Spacing.xl),
          BodyWidth(child: _buildHeader(isCompact)),
          const SizedBox(height: Spacing.lg),
          Expanded(
            child: BodyWidth(child: _buildRecordsList(records, provider)),
          ),
          if (provider.totalPages > 0 && !provider.isLoading)
            BodyWidth(
              child: Pagination(
                currentPage: provider.currentPage,
                totalPages: provider.totalPages,
                itemsPerPage: provider.pageSize,
                onPageChanged: (page) => provider.onPageChanged(page),
                onItemsPerPageChanged: (size) =>
                    provider.onItemsPerPageChanged(size),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isCompact) {
    final textTheme = Theme.of(context).textTheme;
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Asistencia', style: textTheme.headlineMedium),
        const SizedBox(height: Spacing.xxs),
        Text(
          'Registros de asistencia de la iglesia.',
          style: textTheme.bodyMedium?.copyWith(color: secondaryText),
        ),
      ],
    );

    final search = SearchTextField(
      hintText: 'Buscar por evento o red…',
      onChanged: (val) => setState(() => _searchQuery = val),
    );
    final date = DateWidget(
      initialDate: _filterDate ?? DateTime.now(),
      onDateSelected: (d) => setState(() => _filterDate = d),
    );
    final takeButton = Button(
      text: 'Tomar Asistencia',
      icon: Icons.how_to_reg,
      size: isCompact ? const Size(double.infinity, 48) : const Size(220, 48),
      onPressed: _takeAttendance,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        heading,
        const SizedBox(height: Spacing.lg),
        if (isCompact)
          Column(
            children: [
              search,
              const SizedBox(height: Spacing.md),
              SizedBox(height: 56, child: date),
              const SizedBox(height: Spacing.md),
              takeButton,
            ],
          )
        else
          Row(
            children: [
              Expanded(child: search),
              const SizedBox(width: Spacing.md),
              date,
              const SizedBox(width: Spacing.md),
              takeButton,
            ],
          ),
      ],
    );
  }

  Widget _buildRecordsList(
    List<AttendanceModel> records,
    AttendanceProvider provider,
  ) {
    if (provider.isLoading) {
      return const AppSkeleton.list();
    }
    if (provider.error != null) {
      return ErrorState(
        error: provider.error,
        onRetry: () => provider.fetchAttendanceHistory(),
      );
    }
    if (records.isEmpty) {
      return const EmptyState(
        icon: Icons.fact_check_outlined,
        title: 'No hay registros de asistencia',
        message: 'Ajusta la fecha o la búsqueda.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchAttendanceHistory(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
        itemCount: records.length,
        separatorBuilder: (_, __) => const SizedBox(height: Spacing.md),
        itemBuilder: (_, i) {
          final record = records[i];
          return AttendanceCard(
            record: record,
            isToday: _isToday(record.date),
            onTap: () => _openDetails(record),
            onPdf: () => _downloadPdf(record.id),
            onEdit: () => _editRecord(record),
            onDelete: () => _confirmDelete(record),
          );
        },
      ),
    );
  }
}

// La tarjeta de fecha vive ahora en lib/widgets/attendance_card.dart
// (compartida con Reportes Generales).
