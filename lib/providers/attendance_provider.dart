import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/attendance_model.dart';
import '../services/api_client.dart';

class AttendanceProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  // Usaremos la lista como fuente principal para la UI
  List<AttendanceModel> _recordsList = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  int _totalPages = 0;
  int _pageSize = 10;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AttendanceModel> get recordsList => _recordsList;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get pageSize => _pageSize;

  Map<String, AttendanceModel> _records = {};
  Map<String, AttendanceModel> get records => _records;

  Future<void> fetchAttendanceHistory({int page = 0, int? size}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get(
        '/event-attendances',
        queryParameters: {
          'pageNo': page,
          'pageSize': _pageSize,
          'sortBy': 'date',
          'sortType': 'DESC',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> rawData = response.data['content'] ?? [];

        _currentPage = response.data['number'];
        _totalPages = response.data['totalPages'];
        _pageSize = response.data['size'] ?? 10;

        _recordsList = rawData
            .map((item) => AttendanceModel.fromJson(item))
            .toList();

        _recordsList.sort((a, b) => b.date.compareTo(a.date));

        print(
          "DEBUG: Se cargaron ${_recordsList.length} registros desde 'content'",
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 500 || e.type != DioExceptionType.cancel) {
        _error =
            "Ya pasó el tiempo para tomar asistencia o el servidor no está disponible";
      } else {
        _error = "No se pudo cargar el historial. Intente de nuevo.";
      }
      print("DEBUG ERROR FETCH: $e");
    } catch (e) {
      _error =
          "Ya pasó el tiempo para tomar asistencia o el servidor no está disponible";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      // Usamos microtask para evitar errores de "setState/notifyListeners during build"
      Future.microtask(() => notifyListeners());
    }
  }

  Future<void> onPageChanged(int newPage) async {
    await fetchAttendanceHistory(page: newPage);
  }

  Future<void> onItemsPerPageChanged(int newSize) async {
    _pageSize = newSize;
    await fetchAttendanceHistory(page: 0);
  }

  Future<void> nextPage() async {
    if (_currentPage < _totalPages - 1) {
      await fetchAttendanceHistory(page: _currentPage + 1);
    }
  }

  Future<void> previousPage() async {
    if (_currentPage > 0) {
      await fetchAttendanceHistory(page: _currentPage - 1);
    }
  }

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
        await fetchAttendanceHistory();
        return true;
      }
      return false;
    } on DioException catch (e) {
      _error =
          "Ya pasó el tiempo para tomar asistencia o el servidor no está disponible";
      print("DEBUG ERROR SAVE ATTENDANCE: ${e.response?.data}");
      return false;
    } catch (e) {
      _error = "Ocurrió un error inesperado al guardar";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  Future<bool> deleteRecord(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.delete('/event-attendances/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        _recordsList.removeWhere((record) => record.id == id);
        return true;
      }
      return false;
    } catch (e) {
      print("DEBUG ERROR DELETE: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<AttendanceModel> searchRecords(String query) {
    if (query.isEmpty) return _recordsList;
    return _recordsList.where((record) {
      return record.id.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
