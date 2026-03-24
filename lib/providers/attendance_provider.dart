import 'package:flutter/material.dart';

import '../models/attendance_model.dart';
import '../services/api_client.dart';

class AttendanceProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  // Usaremos la lista como fuente principal para la UI
  List<AttendanceModel> _recordsList = [];
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AttendanceModel> get recordsList => _recordsList;

  Map<String, AttendanceModel> _records = {};
  Map<String, AttendanceModel> get records => _records;

  // --- MÉTODO PARA CARGAR EL HISTORIAL ---
  Future<void> fetchAttendanceHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/event-attendances');

      if (response.statusCode == 200) {
        // 1. Extraemos la lista desde la propiedad 'content' del JSON
        final List<dynamic> rawData = response.data['content'] ?? [];

        // 2. Convertimos el JSON a objetos AttendanceModel
        _recordsList = rawData
            .map((item) => AttendanceModel.fromJson(item))
            .toList();

        // 3. Ordenamos por fecha (más reciente primero)
        _recordsList.sort((a, b) => b.date.compareTo(a.date));

        print(
          "DEBUG: Se cargaron ${_recordsList.length} registros desde 'content'",
        );
      }
    } catch (e) {
      _error = "Error al cargar historial: $e";
      print("DEBUG ERROR FETCH: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- MÉTODO PARA GUARDAR ASISTENCIA ---
  Future<bool> saveRecord(AttendanceModel record) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.post(
        '/event-attendances',
        data: record.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // IMPORTANTE: Tras guardar con éxito, refrescamos la lista completa
        // Esto garantiza que veamos el nuevo registro con su ID real del servidor
        await fetchAttendanceHistory();
        return true;
      }
      return false;
    } catch (e) {
      _error = "Error al conectar con el servidor: $e";
      print("DEBUG ERROR SAVE ATTENDANCE: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- MÉTODOS DE APOYO ---

  // Busca un registro por fecha en la lista local
  AttendanceModel? getRecordForDate(DateTime date) {
    try {
      return _recordsList.firstWhere(
        (r) =>
            r.date.year == date.year &&
            r.date.month == date.month &&
            r.date.day == date.day,
      );
    } catch (_) {
      return null;
    }
  }

  // CAMBIA ESTO:
  // void deleteRecord(String id) { ... }

  // POR ESTO:
  Future<bool> deleteRecord(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Llamada al backend (ajusta el endpoint si es necesario)
      final response = await _apiClient.dio.delete('/event-attendances/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // 2. Si el servidor borró con éxito, eliminamos de la lista local
        _recordsList.removeWhere((record) => record.id == id);
        return true; // <--- DEVOLVEMOS TRUE
      }
      return false;
    } catch (e) {
      print("DEBUG ERROR DELETE: $e");
      return false; // <--- DEVOLVEMOS FALSE SI HAY ERROR
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Buscador por ID o por nombre de evento (si el modelo tiene definitionName)
  List<AttendanceModel> searchRecords(String query) {
    if (query.isEmpty) return _recordsList;
    return _recordsList.where((record) {
      return record.id.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
