import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/attendance_filters.dart';
import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';
import '../../theme/design_constants.dart';
import '../../utils/download_stub.dart'
    if (dart.library.html) '../../utils/download_web.dart';
import '../../utils/window_size.dart';
import '../../widgets/attendance_card.dart';
import '../../widgets/body_width.dart';
import '../../widgets/button.dart';
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
  late final TextEditingController _networkCtrl;
  DateTime? _date;
  bool _filtersExpanded = false;

  @override
  void initState() {
    super.initState();
    // Sembramos los campos desde los filtros persistidos en el provider.
    final f = context.read<AttendanceProvider>().filters;
    _networkCtrl = TextEditingController(text: f.networkName);
    _date = f.date;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Recarga fresca desde página 0 conservando los filtros vigentes.
      context.read<AttendanceProvider>().loadFirstPage();
    });
  }

  @override
  void dispose() {
    _networkCtrl.dispose();
    super.dispose();
  }

  AttendanceFilters _currentFilters() =>
      AttendanceFilters(networkName: _networkCtrl.text, date: _date);

  void _applyFilters() {
    context.read<AttendanceProvider>().applyFilters(_currentFilters());
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() => _date = picked);
      _applyFilters();
    }
  }

  void _clearFilters() {
    setState(() {
      _networkCtrl.clear();
      _date = null;
    });
    context.read<AttendanceProvider>().clearFilters();
  }

  int get _activeFilterCount {
    var count = 0;
    if (_networkCtrl.text.trim().isNotEmpty) count++;
    if (_date != null) count++;
    return count;
  }

  static const List<String> _mesesAbbr = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  String _fmtDate(DateTime d) => '${d.day} ${_mesesAbbr[d.month - 1]} ${d.year}';

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

    // La lista ya viene filtrada y ordenada desde el backend.
    final records = provider.recordsList;

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              takeButton,
              const SizedBox(height: Spacing.md),
              _buildFiltersToggle(),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: _filtersExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: Spacing.md),
                  child: _buildFilterFields(isCompact: true),
                ),
              ),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildFilterFields(isCompact: false)),
              const SizedBox(width: Spacing.md),
              takeButton,
            ],
          ),
      ],
    );
  }

  Widget _buildFiltersToggle() {
    final count = _activeFilterCount;
    return OutlinedButton(
      onPressed: () => setState(() => _filtersExpanded = !_filtersExpanded),
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryText,
        side: const BorderSide(color: alternateColor),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune, size: 18, color: primaryColor),
          const SizedBox(width: Spacing.sm),
          Text(count > 0 ? 'Filtros ($count)' : 'Filtros'),
          const Spacer(),
          Icon(
            _filtersExpanded ? Icons.expand_less : Icons.expand_more,
            color: secondaryText,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterFields({required bool isCompact}) {
    final networkField = SizedBox(
      width: isCompact ? double.infinity : 240,
      child: SearchTextField(
        controller: _networkCtrl,
        hintText: 'Red…',
        onChanged: (_) => _applyFilters(),
      ),
    );
    final dateField = _buildDateField(isCompact: isCompact);
    final clear = TextButton.icon(
      onPressed: _clearFilters,
      icon: const Icon(Icons.close, size: 18),
      label: const Text('Limpiar'),
      style: TextButton.styleFrom(foregroundColor: secondaryText),
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          networkField,
          const SizedBox(height: Spacing.md),
          dateField,
          if (_activeFilterCount > 0)
            Align(alignment: Alignment.centerLeft, child: clear),
        ],
      );
    }

    return Wrap(
      spacing: Spacing.md,
      runSpacing: Spacing.md,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        networkField,
        dateField,
        if (_activeFilterCount > 0) clear,
      ],
    );
  }

  Widget _buildDateField({required bool isCompact}) {
    final hasDate = _date != null;
    return SizedBox(
      width: isCompact ? double.infinity : 200,
      height: isCompact ? 50 : 45,
      child: OutlinedButton.icon(
        onPressed: _pickDate,
        icon: const Icon(Icons.calendar_today, size: 18, color: secondaryText),
        label: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            hasDate ? _fmtDate(_date!) : 'Fecha',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: hasDate ? primaryText : secondaryText),
          ),
        ),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          side: const BorderSide(color: alternateColor),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
      ),
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
