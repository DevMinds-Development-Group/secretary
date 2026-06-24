import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/apostol_dashboard_model.dart';
import '../services/api_client.dart';

/// Provee los datos del dashboard de supervisión (apóstol/pastor).
class ApostolDashboardProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  ApostolDashboardModel? _data;
  bool _isLoading = false;
  String? _error;

  ApostolDashboardModel? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/apostol-dashboard');

      if (response.statusCode == 200 && response.data is Map) {
        _data = ApostolDashboardModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
        _error = null;
      } else {
        _error = "Error al cargar la supervisión";
      }
    } on DioException catch (e) {
      if (e.error == 'SIN_CONEXION' ||
          e.type == DioExceptionType.connectionError) {
        _error = "SIN_CONEXION";
      } else {
        _error = "Error al cargar la supervisión";
      }
    } catch (e) {
      _error = "Ocurrió un error inesperado";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
