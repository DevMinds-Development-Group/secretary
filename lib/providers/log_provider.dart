// lib/providers/log_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/log_model.dart';
import '../services/api_client.dart';

class LogProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<Log> _logs = [];
  int _currentPage = 0;
  int _totalPages = 0;
  int _pageSize = 10;
  bool _isLoading = false; // Para la carga inicial o refresco
  bool _isLoadingMore = false; // Para cargar las páginas siguientes
  String? _error;

  List<Log> get logs => _logs;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get pageSize => _pageSize;

  Future<void> fetchLogs({int page = 0}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get(
        '/logs',
        queryParameters: {
          'pageNo': page,
          'pageSize': _pageSize,
          'sortBy': 'timestamp',
          'sortType': 'desc',
        },
      );

      final List<dynamic> logData = response.data['content'];
      _logs = logData.map((data) => Log.fromJson(data)).toList();

      _currentPage = response.data['number'];
      _totalPages = response.data['totalPages'];
    } on DioException catch (e) {
      _error = 'Error al cargar registros: ${e.message}';
      print(_error);
      _logs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onPageChanged(int newPage) async {
    await fetchLogs(page: newPage);
  }

  Future<void> onItemsPerPageChanged(int newSize) async {
    _pageSize = newSize;
    // Volvemos a la página 0 para evitar inconsistencias.
    await fetchLogs(page: 0);
  }

  // Métodos para navegación
  Future<void> nextPage() async {
    if (_currentPage < _totalPages - 1) {
      await fetchLogs(page: _currentPage + 1);
    }
  }

  Future<void> previousPage() async {
    if (_currentPage > 0) {
      await fetchLogs(page: _currentPage - 1);
    }
  }
}
