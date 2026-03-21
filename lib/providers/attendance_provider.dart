// lib/providers/attendance_provider.dart
import 'package:flutter/material.dart';

import '../models/attendance_record_model.dart';

class AttendanceProvider with ChangeNotifier {
  final Map<String, AttendanceRecord> _records = {};
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, AttendanceRecord> get records => _records;

  List<AttendanceRecord> get recordsList {
    final list = _records.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date)); // Orden descendente
    return list;
  }

  String _generateId(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> saveRecord(AttendanceRecord record) async {
    _isLoading = true;
    notifyListeners();

    // Simulamos un pequeño delay como si fuera una API
    await Future.delayed(const Duration(milliseconds: 500));

    _records[record.id] = record;

    _isLoading = false;
    notifyListeners();
    print("Registro guardado: ${record.id}");
  }

  // Método para obtener un registro para una fecha específica
  AttendanceRecord? getRecordForDate(DateTime date) {
    return _records[_generateId(date)];
  }

  void deleteRecord(String id) {
    if (_records.containsKey(id)) {
      _records.remove(id);
      notifyListeners();
    }
  }

  List<AttendanceRecord> searchRecords(String query) {
    if (query.isEmpty) return recordsList;
    return recordsList.where((record) {
      return record.id.contains(query);
    }).toList();
  }
}
