import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/dashboard_model.dart';
import '../services/api_client.dart';

class DashboardProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  DashboardModel? _summary;
  bool _isLoading = false;
  String? _error;

  DashboardModel? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSummary() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/dashboard/summary');

      if (response.statusCode == 200) {
        _summary = DashboardModel.fromJson(response.data);
        _error = null;
      }
    } on DioException catch (e) {
      if (e.error == 'SIN_CONEXION' ||
          e.type == DioExceptionType.connectionError) {
        _error = "SIN_CONEXION"; // Usamos una clave para la UI
      } else {
        _error = "Error al cargar dashboard";
      }
    } catch (e) {
      _error = "Ocurrió un error inesperado";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
