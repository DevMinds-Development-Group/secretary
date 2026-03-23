import 'package:app/widgets/action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener intl en pubspec.yaml
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/member_provider.dart';
import '../../widgets/button.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/date.dart';
import '../../widgets/menu.dart';
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
  DateTime _filterDate = DateTime.now();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AttendanceProvider>(
        context,
        listen: false,
      ).fetchAttendanceHistory();
      Provider.of<MemberProvider>(context, listen: false).fetchMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final attendanceProvider = Provider.of<AttendanceProvider>(context);

    final records = attendanceProvider.recordsList.where((r) {
      final matchesName = r.id.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      final matchesDate =
          (r.date.year == _filterDate!.year &&
          r.date.month == _filterDate!.month &&
          r.date.day == _filterDate!.day);
      return matchesName && matchesDate;
    }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Asistencias', isDrawerEnabled: isMobile),
      drawer: isMobile ? Drawer(child: Menu()) : null,
      body: Row(
        children: [
          if (!isMobile) Menu(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildHeader(isMobile),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _buildRecordsList(
                      records,
                      attendanceProvider.isLoading,
                    ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: isMobile
          ? Column(
              children: [
                SearchTextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 10),
                _dateWidget(),
                const SizedBox(height: 10),
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
      initialDate: _filterDate,
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
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Widget _buildRecordsList(List<AttendanceModel> records, bool isLoading) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (records.isEmpty)
      return const Center(child: Text("No hay registros encontrados"));

    return Container(
      decoration: BoxDecoration(
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
            leading: const Icon(
              Icons.assignment_turned_in,
              color: Colors.green,
            ),
            title: Row(
              children: [
                Text(
                  '${record.definitionName ?? 'Evento sin nombre'} |',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                VerticalDivider(width: 5),
                Text(
                  record.networkName ?? 'Evento sin nombre',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
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
                  'Presentes: ${record.presentMemberIds.length} | Visitas: ${record.visitorsCount}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            trailing: ActionButtons(
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
                  itemName:
                      'Asistencia del ${DateFormat('d/MM').format(record.date)}',
                  onConfirm: () => _handleDelete(context, record),
                );
              },
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
    );
  }
}
