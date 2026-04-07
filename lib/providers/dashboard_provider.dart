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
      } else {
        _error = "Error del servidor: ${response.statusCode}";
      }
    } catch (e) {
      _error = "No se pudo conectar con el servidor para obtener el resumen.";
      print("DASHBOARD_ERROR: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
