import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener intl en pubspec.yaml
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/menu.dart';
import '../../widgets/search_text_field.dart';
import 'attendance.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final attendanceProvider = Provider.of<AttendanceProvider>(context);

    // Filtrado local (puedes mover esto al provider luego)
    final records = attendanceProvider.recordsList.where((r) {
      final matchesName = r.id.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesDate =
          _filterDate == null ||
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: isMobile
          ? Column(
              children: [
                SearchTextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 10),
                _buildDateFilter(),
                const SizedBox(height: 10),
                _buildAddButton(),
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
                _buildDateFilter(),
                const SizedBox(width: 15),
                _buildAddButton(),
              ],
            ),
    );
  }

  Widget _buildDateFilter() {
    return OutlinedButton.icon(
      icon: const Icon(Icons.calendar_today, size: 18),
      label: Text(
        _filterDate == null
            ? 'Filtrar Fecha'
            : DateFormat('dd/MM/yyyy').format(_filterDate!),
      ),
      onPressed: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        setState(() => _filterDate = date);
      },
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      icon: const Icon(Icons.how_to_reg),
      label: const Text('Tomar Asistencia'),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Attendance()),
      ),
    );
  }

  Widget _buildRecordsList(List records, bool isLoading) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (records.isEmpty)
      return const Center(child: Text("No hay registros encontrados"));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        itemCount: records.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final record = records[index];
          return ListTile(
            leading: const Icon(
              Icons.assignment_turned_in,
              color: Colors.green,
            ),
            title: Text(
              DateFormat('EEEE, d MMMM yyyy', 'es').format(record.date),
            ),
            subtitle: Text(
              'Presentes: ${record.presentMemberIds.length} | Visitas: ${record.guestCount}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Attendance()),
              );
            },
          );
        },
      ),
    );
  }
}
